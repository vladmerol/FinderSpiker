%% Save DATA: Neural Ensembles Features
% .mat file:
%   Features_Ensemble
%   Features_Condition
% .CSV file
%   N-Ensembles,Dunns Index,RateOfTransitions,RateOfCycles,DominantEnsemble
%   N SimpleCycles, N-ClosedCycles , N-OpenedCycles
%   Ensemble i Rate,...
%   Ensemble i Dominance=%NeuronsOccupance * Rate,...
function save_features_ensembles(Experiment,Names_Conditions,Features_Ensemble,Features_Condition)
% Setup
% Saving Directory: one above where Finder Spiker is..
Experiment=Experiment(Experiment~='\');     % NAMES PATCH
FileDirSave=pwd;
slashes=find(FileDirSave=='\');
FileDirSave=FileDirSave(1:slashes(end));

%% SAVE OUTPUT DATASET (.m file)
% checkname=1;
% while checkname==1
%     DefaultPath=[FileDirSave,'Processed Data'];
%     if exist(DefaultPath,'dir')==0
%         DefaultPath=pwd; % Current Diretory of MATLAB
%     end
%     [FileName,PathName] = uigetfile('*.mat',[' Pick the Analysis File ',Experiment],...
%         'MultiSelect', 'off',DefaultPath);
%     dotindex=find(FileName=='.');
%     if strcmp(FileName(1:end-4),Experiment)
%         checkname=0;
%         % SAVE DATA
%         disp('>>Updating .mat file...')
%         save([PathName,FileName],'Features_Ensemble','Features_Condition',...
%             '-append');
%         disp([Experiment,'   -> UPDATED (Ensembles Features)'])
%     elseif FileName==0
%         checkname=0;
%         disp('*************DISCARDED************')
%     else
%         disp('Not the same Experiment!')
%         disp('Try again!')
%     end
% end    
%% SAVE CSV FILES
% Direcotry Name
NameDir='Ensemble Features\';
% Number of Condition
if iscell(Names_Conditions)
    C=numel(Names_Conditions);
else
    C=1;
end
%% Save Files for each COndition
HeadersFeaturesCondition={'Nensembles','Threshold','Dunns','MaxIntraVec','ClassError',...
                     'RateTrans','RateCycles','SimpleCycles','ClosedCycles','OpenedCycles',...
                     'CAGauc','CoreSize','MaxSynLinks','MaxConn_A','MaxConn_B',...
                     'SynWeigthMean','SynWeigthVar','SynWeigthSkew','SynWeigthKurt'};
HeadersFeaturesEnsembles={'NeuronsRation','Time','Dominance','Rate',...
     'ensCAGauc','ensCAGmean','ensCAGvar','ensCAGskew','ensCAGkurt'...
     'IEImean','IEIvar','IEIskew','IEIkurt'...
     'EDmean','EDvar','EDskew','EDkurt'};
% For each Ensembles thera rows are : Ens1; Ens2; ... Ensj

for c=1:C
    fprintf('>> Creating Table Ensemble Feautures of %s \n',Names_Conditions{c});
    %% General INTEL about Neurla Ensembles
    % Features Columns of the Table ***************************************
    Name=Names_Conditions{c};
    NE=Features_Condition.Nenscond(c);                  % N ensembles
    Th=Features_Condition.Threshold(c);                 % Threshold
    DunnIndx=Features_Condition.Dunn(c);                % Dunns Index
    MaxIntraVec=Features_Condition.MIV(c);              % Max Distance Intra Vectors
    ClassError=Features_Condition.ECV_Cond(c);          % Classification Error
    RateTran=Features_Condition.RateTrans(c);           % Rate Transitions
    RateCycl=Features_Condition.RateCycles(c);          % Rate Cycles
    % [%] Simple Cycles
    Portion_simple=Features_Condition.CyclesType(1,c)/sum(Features_Condition.CyclesType(:,c));
    % [%] Closed Cycles
    Portion_closed=Features_Condition.CyclesType(2,c)/sum(Features_Condition.CyclesType(:,c));
    % [%] Opened Cycles
    Portion_opened=Features_Condition.CyclesType(3,c)/sum(Features_Condition.CyclesType(:,c));
    CAGauc=Features_Condition.CAGstats(c,1);            % CAG AutoCorrelation Coefficient
    CoreSize=Features_Condition.CoreNeurons(c);         % Ratio of neurons in all Ensembles
    % Max Links Between Neurons
    MaxSynLinks=Features_Condition.Network{c}.MaxSynLinks;
    % Max Links Between Neurons
    MaxConnA=Features_Condition.Network{c}.MaxCoupledPair(1); % Neuron A
    MaxConnB=Features_Condition.Network{c}.MaxCoupledPair(2); % Neuron B
    % Satitstics of Weights Connections (Synaptic Strength)
    SynMean=Features_Condition.Network{c}.SynStrengthStats(1);  % mean
    SynVar=Features_Condition.Network{c}.SynStrengthStats(2);   % variance
    SynSkew=Features_Condition.Network{c}.SynStrengthStats(3);  % skewness
    SynKurt=Features_Condition.Network{c}.SynStrengthStats(4);  % kurtosis
    % ********************************************************************
    % Create Table
    Tensemblesfeatures=table(NE,Th,DunnIndx,MaxIntraVec,ClassError,...
        RateTran,RateCycl,Portion_simple,Portion_closed,Portion_opened,...
        CAGauc,CoreSize,MaxSynLinks,MaxConnA,MaxConnB,...
        SynMean,SynVar,SynSkew,SynKurt);
    Tensemblesfeatures.Properties.VariableNames=HeadersFeaturesCondition;
    % Save CSV
    if isdir([FileDirSave,NameDir])
        disp('>>Saving...')
        writetable(Tensemblesfeatures,[FileDirSave,NameDir,Experiment,'_',Name,'.csv'],...
            'Delimiter',',','QuoteStrings',true);
        disp(['>>Saved at /Ensemble Features: ',Experiment,'-',Names_Conditions{c}])
    else % Create Directory
        disp('>>Directory >Ensemble Features< created')
        disp('>>Saving...')
        mkdir([FileDirSave,NameDir]);
        writetable(Tensemblesfeatures,[FileDirSave,NameDir,Experiment,'_',Name,'.csv'],...
            'Delimiter',',','QuoteStrings',true);
        disp('Ensemble Features Directory Created');
        disp(['>>Saved at /Ensemble Features: ',Experiment,'-',Names_Conditions{c}])
    end
    %% Detailed Ensembles INTEL ###########################################
    % Features For each Ensemble (rows of the table)
    % [%] Active Neurons (observed) [column vectors!]
    NeuronsOccupancy=Features_Ensemble.NeuronsOccupancy(c,1:NE)'; 
    % [%] Active Time (observed)
    TimeOccupancy=Features_Ensemble.TimeOccupancy(c,1:NE)';
    % Dominance Index
    DominanceIndex=Features_Ensemble.Dominance(c,1:NE)';
    % Ensemble Rate [act/min]
    EnseRate=Features_Ensemble.Rate(c,1:NE)';
    % Initialize sizes right
    EnsCAGauc=zeros(NE,1);EnsCAGmean=EnsCAGauc; EnsCAGvar=EnsCAGauc;
    EnsCAGskew=EnsCAGauc; EnsCAGkurt=EnsCAGauc; EnsIEImean=EnsCAGauc;
    EnsIEIvar=EnsCAGauc; EnsIEIskew=EnsCAGauc; EnsIEIkurt=EnsCAGauc;
    EnsEDmean=EnsCAGauc; EnsEDvar=EnsCAGauc; EnsEDskew=EnsCAGauc;
    EnsEDkurt=EnsCAGauc;
    for n=1:NE
        % Ensemble Co-Activity-Graphy ACC *******************
        EnsCAGauc(n,1)=Features_Ensemble.EnsCAGstats{c,n}(1);
        % Ensemble Co-Activity-Graphy Mean
        EnsCAGmean(n,1)=Features_Ensemble.EnsCAGstats{c,n}(2);
        % Ensemble Co-Activity-Graphy Variance
        EnsCAGvar(n,1)=Features_Ensemble.EnsCAGstats{c,n}(3);
        % Ensemble Co-Activity-Graphy Skewness
        EnsCAGskew(n,1)=Features_Ensemble.EnsCAGstats{c,n}(4);
        % Ensemble Co-Activity-Graphy Kurtosis
        EnsCAGkurt(n,1)=Features_Ensemble.EnsCAGstats{c,n}(5);
        % Inter Ensemble Interval Mean **********************
        EnsIEImean(n,1)=Features_Ensemble.IEIstats{c,n}(1);
        % Inter Ensemble Interval Variance
        EnsIEIvar(n,1)=Features_Ensemble.IEIstats{c,n}(2);
        % Inter Ensemble Interval Skewness
        EnsIEIskew(n,1)=Features_Ensemble.IEIstats{c,n}(3);
        % Inter Ensemble Interval Kurtosis
        EnsIEIkurt(n,1)=Features_Ensemble.IEIstats{c,n}(4);
        % Ensemble Duration Mean ****************************
        EnsEDmean(n,1)=Features_Ensemble.EDstats{c,n}(1);
        % Ensemble Duration Variance
        EnsEDvar(n,1)=Features_Ensemble.EDstats{c,n}(2);
        % Ensemble Duration Skewness
        EnsEDskew(n,1)=Features_Ensemble.EDstats{c,n}(3);
        % Ensemble Duration Kurtosis
        EnsEDkurt(n,1)=Features_Ensemble.EDstats{c,n}(4);
    end
    % ********************************************************************
    % Create Table
    TensemblesDetails=table(NeuronsOccupancy,TimeOccupancy,DominanceIndex,...
        EnseRate,...
        EnsCAGauc,EnsCAGmean,EnsCAGvar,EnsCAGskew,EnsCAGkurt,...
        EnsIEImean,EnsIEIvar,EnsIEIskew,EnsIEIkurt,...
        EnsEDmean,EnsEDvar,EnsEDskew,EnsEDkurt);
    TensemblesDetails.Properties.VariableNames=HeadersFeaturesEnsembles;
    % Save CSV
    if isdir([FileDirSave,NameDir])
        disp('>>Saving Neural Ensembles Details...')
        writetable(TensemblesDetails,[FileDirSave,NameDir,Experiment,'_',Name,'_DET.csv'],...
            'Delimiter',',','QuoteStrings',true);
        disp(['Saved Ensemble Details: ',Experiment,'-',Names_Conditions{c}])
    else % Create Directory
        disp('>>Directory >Ensemble Features< created')
        disp('>>Saving...')
        mkdir([FileDirSave,NameDir]);
        writetable(Tensemblesfeatures,[FileDirSave,NameDir,Experiment,'_',Name,'_DET.csv'],...
            'Delimiter',',','QuoteStrings',true);
        disp('Ensemble Features Directory Created');
        disp(['Saved Ensemble Details: ',Experiment,'-',Names_Conditions{c}])
    end
end
disp('>> Data Exported at \Ensemble Features.')
% disp('>>END.')