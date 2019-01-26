% Features of Neurons @ Ensembles
% It gets the Neurons that participate in each ensemble
% R(F)un after Clustering only
% INPUT:
%   R_Condition:        Cell of Rasters from Selected Raster
%   Ensemble_Threshold  Cell of vectors
%   Ensembled_Labels    Cell of vectors
%   fs                 sampling frequency
% OUTPUT
%   Ensembled_Neurons
%   Ensmeble_Features
function [Features_Ensemble,Features_Condition]=get_ensembles_features(R_Condition,Ensemble_Threshold,Ensembled_Labels,fs)
%% Setup
SimMethod='hamming';
% Get Number Of Conditions
C=numel(R_Condition); % Number of Conditions
% Get Number of Different Ensmebles
Ensambles=[]; Nenscond=zeros(C,1);
for c=1:C
    Ensambles=[Ensambles;unique(Ensembled_Labels{c})];
    Nenscond(c)=numel(unique(Ensembled_Labels{c}));
end
Ensambles=unique(Ensambles);
Ne=numel(Ensambles); % TOTAL NUMBER OF ENSEMBLES (all experiment)
% Initialize OUTPUTS        Condition  x Ensembles
Ensembled_Neurons=cell(C,max(Nenscond));
Ensembles_Rate=zeros(C,max(Nenscond));
NeuronsOccupancy=zeros(C,max(Nenscond));
TimeOccupancy=zeros(C,max(Nenscond));
EnsCAGstats={};
% -> OUTPUT                 Condition
DunnIndex=zeros(1,C);
Transitions=cell(1,C);
Ntransitions=zeros(1,C);
Rate_Transitions=zeros(1,C);
Ratecycles=zeros(1,C);
CyclesTypes=zeros(3,C);
CAGstats=zeros(C,5);
% Thresholds=zeros(C,1);
ECV_Cond=zeros(C,1);
Model_Cond=cell(C,1);
MIV=zeros(C,1);
% TypeCycles(1)->Simple
% TypeCycles(2)->Closed
% TypeCycles(3)->Open
%% Main Loop to get Ensemble Features
for c=1:C
    %% DATA
    R=R_Condition{c};               % RASTER
    [AN,Frames]=size(R);            % Total Active Neurons [selected]
    RasterDuration=Frames/fs/60;    % MINUTES
    CAG=sum(R);                     % Co-Activity-Graphy
    %% CAG Statistics
    AUC=autocorr(CAG,1); % Autocorrelation Coeffcient
    CAGstats(c,:)=[AUC(2),mean(CAG),var(CAG),skewness(CAG),kurtosis(CAG)];
    Th=Ensemble_Threshold(c);       % CAG Threshold
    % Thresholds(c)=Th;
    signif_frames=find(CAG>=Th);    % Significatn Frames
    Ensembles_Labels=Ensembled_Labels{c}; % Labels each frame
    E=unique(Ensembled_Labels{c}); % Ensambles per condition
    %% Classification Error
    [Model_Cond{c},ECV_Cond(c)]=Nbayes_Ensembles(R(:,signif_frames),Ensembles_Labels);
    %% EACH ENSEMBLE
    MaxIntraVec=zeros(1,numel(E));
    for e=1:numel(E)
        fprintf('>> Condition %i, Ensemble %i of %i \n',c,e,numel(E));
        frames_ensemble=signif_frames(Ensembles_Labels==E(e));
        TimeOccupancy(c,e)=numel(frames_ensemble)/numel(signif_frames);
        EnsembleActivations=numel(find(diff(frames_ensemble)>1));
        % Ouput Measure Features by ENSEMBLE
        Ensembles_Rate(c,e)=EnsembleActivations/RasterDuration;
        Ensembled_Neurons{c,e}=find(sum(R(:,frames_ensemble),2));
        % Output Indexes
        NeuronsOccupancy(c,e)=numel(Ensembled_Neurons{c,e})/AN;
        % MORE FEATURES
        Rcluster=R(:,frames_ensemble); % Cells x Frames
        CAGcluster=sum(Rcluster);
        AUC=autocorr(CAGcluster,1); % Autocorrelation Coeffcient
        EnsCAGstats{c,e}=[AUC(2),mean(CAGcluster),var(CAGcluster),skewness(CAGcluster),kurtosis(CAGcluster)];
        MaxIntraVec(c)=max(pdist(Rcluster',SimMethod));
        % Inter-Eensemble-Interval & Ensemble Duration
        r=zeros(size(CAG));
        r(frames_ensemble)=1;
        [IEIs,EDs]=interval_duration_events(r);
        IEIsExp{c,e}=IEIs/fs;   % [SECONDS]
        EDsExp{c,e}=EDs/fs;     % [SECONDS]
        IEIstats{c,e}=[mean(IEIs),var(IEIs),skewness(IEIs),kurtosis(IEIs)];
        EDstats{c,e}=[mean(EDs),var(EDs),skewness(EDs),kurtosis(EDs)];
        %disp('butt')
    end
    %% ENSEMBLES SETs FEATURES
    % CONDITION FEATURES ********************************
    % Dunn's Index (sort of):
    % How Separater Cluster divided how Divided Intra Clusters
    % <1 More Distance Intra Vectors than Intra Clusters-> Bad Clustering
    % >1 More Distance Intra Clusters than Intra Vectors-> Good Clustering
    NeuroClusters=zeros(AN,numel(E));
    for e=1:length(E)
        NeuroClusters(Ensembled_Neurons{c,e},e)=1;
    end
    Dhamm=pdist(NeuroClusters',SimMethod); % percentage of different neurons
    if isempty(Dhamm); Dhamm=0; end;
    if max(MaxIntraVec)>0
        DunnIndex(c)=min(Dhamm)/max(MaxIntraVec); % min distance among ensembles divided by maximum length of ensembles
    else
        DunnIndex(c)=0; % min distance among ensembles divided by maximum length of ensembles
    end
    MIV(c)=max(MaxIntraVec);
    
    % Hebbian Sequence
    HS=Ensembles_Labels(diff(signif_frames)>1);
    % HebbianSequence{c}=HS;
    % Transitions: Ensmbles Change deactivate and activate [ALTERNANCE]
    ET= HS(diff([HS;0])~=0);
    Transitions{c}=ET;
    Ntransitions(c)=numel(ET);
    Rate_Transitions(c)=numel(ET)/RasterDuration; % Transitions per MINUTE
    % Cycles of Ensembles [REVERBERATION] return to a given ensemble (after activate all ensembles)
    TypeCycles=zeros(3,1);
    tcounter=[]; t=1;
    Tremaining=1;
    while and(~isempty(Tremaining),~isempty(ET))
        ActualEnsemble=ET(t);
        Cy=find(ET(t+1:end)==ActualEnsemble);
        if ~isempty(Cy)
            auxt=t;
            i=1;
            % Check what kind of Hebbian Path: only for Cycle with all Active Ensemables
            while i<=length(Cy)
                Cycle=ET(auxt:t+Cy(i));
                % Simple
                if and(numel(Cycle)==length(E)+1,numel(unique(Cycle))==numel(E))
                    disp(Cycle')
                    disp('Simple')
                    TypeCycles(1)=TypeCycles(1)+1;
                    tcounter=[tcounter;t;Cy(1:i)+t];
                    auxt=t+Cy(i);
                    i=i+1;
                elseif numel(unique(Cycle))==numel(E)
                    disp(Cycle')
                    CycleMat=zeros(max(E));
                    for j=1:length(Cycle)-1
                        CycleMat(Cycle(j),Cycle(j+1))=CycleMat(Cycle(j),Cycle(j+1))+1;
                    end
                    % Check for upper and lower triangles
                    CS=sum(triu(CycleMat)+triu(CycleMat'));
                    % If there were sequences from 2 to end
                    if sum(CS(2:end)>0)==numel(E)-1
                        disp('Closed')
                        TypeCycles(2)=TypeCycles(2)+1;
                        tcounter=[tcounter;t;Cy(1:i)+t];
                        auxt=t+Cy(i);
                        i=i+1;
                    else
                        disp('Open')
                        TypeCycles(3)=TypeCycles(3)+1;
                        tcounter=[tcounter;t;Cy(1:i)+t];
                        auxt=t+Cy(i);
                        i=i+1;
                    end
                else
                    tcounter=[tcounter;t;Cy(1:i)+t];
                    i=i+1;
                    auxt=t;
                end
                tcounter=unique(tcounter);
            end
        else
            Cycle=[];
            tcounter=unique([tcounter;t]);
        end
        Tremaining=setdiff(1:numel(ET)-1,tcounter);
        if ~isempty(Tremaining)
            t=Tremaining(1);
        end
    end
    CyclesTypes(:,c)=TypeCycles;
    Ratecycles(c)=sum(TypeCycles)/RasterDuration;
    if c<C; disp('Next Condition'); end;
end
%% Cross Simmilar Neural Ensembles Are 
NeuralClusters=zeros(AN,Ne);
col=1;
for ncond=1:C
    for nens=1:Nenscond(ncond)
        NeuralClusters(Ensembled_Neurons{ncond,nens},col)=1;
        col=col+1;
    end
end
CrossEnsmebleSimm=ones(Ne);
CrossEnsmebleSimm=1-squareform( pdist(NeuralClusters',SimMethod) );


%% OUTPUTS ***************************************************************
Dominance_Ensemble=NeuronsOccupancy.*Ensembles_Rate;
% Matrices of Conditon x Ensembles
Features_Ensemble.Neurons=Ensembled_Neurons;
Features_Ensemble.Rate=Ensembles_Rate;
Features_Ensemble.Dominance=Dominance_Ensemble;
Features_Ensemble.TimeOccupancy=TimeOccupancy;
Features_Ensemble.NeuronsOccupancy=NeuronsOccupancy;
Features_Ensemble.EnsCAGstats=EnsCAGstats;
Features_Ensemble.IEIstats=IEIstats; % [seconds]
Features_Ensemble.EDstats=EDstats;   % [seconds]
Features_Ensemble.IEIsExp=IEIsExp;   % [seconds]
Features_Ensemble.EDsExp=EDsExp;     % [seconds]
% Vectors of Condition x 1
Features_Condition.Dunn=DunnIndex;
Features_Condition.RateTrans=Rate_Transitions;
Features_Condition.RateCycles=Ratecycles;
Features_Condition.CyclesType=CyclesTypes;
Features_Condition.CAGstats=CAGstats;
Features_Condition.Threshold=Ensemble_Threshold;
Features_Condition.MIV=MIV;
Features_Condition.ECV_Cond=ECV_Cond;
Features_Condition.Model_Cond=Model_Cond;
Features_Condition.CrossEnsmebleSimm=CrossEnsmebleSimm;
Features_Condition.Nenscond=Nenscond;
disp('>>Feature Extraction of Neural Ensemble: Done.')
%% disp('END OF THE WORLD')