% Function that Finds a feature subset equal or best than all features
% to classify the conditon given
% Input
%   Y:              Labels: conditions
%   X:              Dataset
%   NameFeatures:   Feature Names
%   EXPIDs:         Experiment IDs
% Output
function OKFeatures = Best_Subset_Feature(Y,X,NameFeatures,EXPIDs)
%% Setup
[~,NFeatures]=size(X);
%% Classifier ALL FEATURES ##########################################
disp('>>Data:')
tabulate(Y)
disp('>>Training...')
Mdl=fitcnb(X,Y,'DistributionNames','kernel');
disp('>>Trained.')
disp('>>Evaluating...')
[Yhat,~]=resubPredict(Mdl);
[Call,order]=confusionmat(Y,Yhat)
ECVall=1-numel(find(Y==Yhat))/numel(Y);
fprintf('Cross-Validated Classification Error: %3.1f %%\n',100*ECVall)
disp('>>Evaluated.')
%% Find Failed Experiments:
pause(2)
disp('Missclassified:')
[EXPIDs(Y~=Yhat),Y(Y~=Yhat)]
pause(1)
disp('>>Search subset...')
%% Feature Selection #####################################################
% NFeatSel=2;
Nremove=1;
NFeatSel=NFeatures-Nremove; % Remove-one-Feature Sets
CO=nchoosek(1:NFeatures,NFeatSel); % Sets of Features Indexes
Ncombinations=size(CO,1);
ErrorCV=ones(Ncombinations,1);
for f=1:Ncombinations
    fprintf('Feature Set: %i/%i\n',f,Ncombinations)
    disp('>>Training...')
    Mdl=fitcnb(X(:,CO(f,:)),Y,'DistributionNames','kernel');
    disp('>>Trained.')
    disp('>>Evaluating...')
    [Yhat,~]=resubPredict(Mdl);
    [C,order]=confusionmat(Y,Yhat)
    ECV=1-numel(find(Y==Yhat))/numel(Y);
    fprintf('Cross-Validated Subset Classification Error: %3.1f %%\n',100*ECV);
    ErrorCV(f)=ECV;
    disp('>>Evaluated.')
    % GET ROC curve
end
MinError=min(ErrorCV);
BestSetFeatures=find(ErrorCV<=MinError);
WorseSetFeatures=find(ErrorCV>MinError);
if numel(BestSetFeatures)>numel(WorseSetFeatures) 
    disp('>>Too Many Feature Combinations right!')
    RejecetFeat=[];
    for n=1:numel(WorseSetFeatures)
        RejecetFeat=[RejecetFeat;setdiff(1:NFeatures,CO(WorseSetFeatures(n),:))];
    end
    RejecetFeat=makerowvector(unique(RejecetFeat))';
else
    disp('>>A few Feature Combinations right!')
    RejecetFeat=[];
    for n=1:numel(BestSetFeatures)
        RejecetFeat=[RejecetFeat;setdiff(1:NFeatures,CO(BestSetFeatures(n),:))];
    end
    RejecetFeat=makerowvector(unique(RejecetFeat))';
end
RejecetFeatpre=RejecetFeat;

% Check that the SUBSET Acutally classifies as usin
OKFeatures=setdiff(1:NFeatures,RejecetFeat);
Mdl=fitcnb(X(:,OKFeatures),Y,'DistributionNames','kernel');
disp('>>Trained.')
disp('>>Evaluating...')
[Yhat,~]=resubPredict(Mdl);
ErrorSelFeat=1-numel(find(Y==Yhat))/numel(Y);
fprintf('Cross-Validated  Subset Classification Error: %3.1f %%\n',100*ErrorSelFeat);

%% Removing More Features
if ErrorSelFeat<=ECVall
    aux=1;
    RejectSets={};
    TrialError=[];
    while ErrorSelFeat<=ECVall
        % ECVall=MinError;
        OKFeatures=setdiff(1:NFeatures,RejecetFeat);
        if isempty(RejecetFeat)
            Nremove=Nremove+1;
        end
        CO=nchoosek(OKFeatures,NFeatures-Nremove);
        Ncombinations=size(CO,1);
        ErrorCV=ones(Ncombinations,1);
        for f=1:Ncombinations
            fprintf('Feature Subset: %i/%i Trial %i\n',f,Ncombinations,aux)
            disp('>>Training...')
            Mdl=fitcnb(X(:,CO(f,:)),Y,'DistributionNames','kernel');
            disp('>>Trained.')
            disp('>>Evaluating...')
            [Yhat,~]=resubPredict(Mdl);
            [C,order]=confusionmat(Y,Yhat)
            ECV=1-numel(find(Y==Yhat))/numel(Y);
            fprintf('Cross-Validated Classification Error: %3.1f %%\n',100*ECV);
            ErrorCV(f)=ECV;
            disp('>>Evaluated.')
        end
        MinError=min(ErrorCV);
        TrialError(aux)=MinError;
        BestSetFeatures=find(ErrorCV<=MinError);
        if numel(BestSetFeatures)==Nokfeatures
            RejecetFeat=1;
        else
            % RejecetFeat=[];
            for n=1:numel(BestSetFeatures)
                RejecetFeat=[RejecetFeat;setdiff(1:NFeatures,CO(BestSetFeatures(n),:))'];
            end
        end
        RejecetFeat=unique(RejecetFeat);
        RejectSets{aux}=RejecetFeat;
        OKFeatures=setdiff(1:NFeatures,RejecetFeat);
        Mdl=fitcnb(X(:,OKFeatures),Y,'DistributionNames','kernel');
        disp('>>Trained.')
        disp('>>Evaluating...')
        [Yhat,~]=resubPredict(Mdl);
        [C,order]=confusionmat(Y,Yhat)
        ErrorSelFeat=1-numel(find(Y==Yhat))/numel(Y);
        aux=aux+1;
    end
    %% Check if it search for less Features
    if aux>2
        okaux=aux-2;
    elseif aux==1 % didn't make the loop
        RejectSets{1}=RejecetFeat;
        okaux=1;
    else  % did the loop once only
        okaux=1;
        RejectSets{1}=RejecetFeatpre;
    end
    RejecetFeat=RejectSets{okaux};
    OKFeatures=setdiff(1:NFeatures,RejecetFeat);
    Mdl=fitcnb(X(:,OKFeatures),Y,'DistributionNames','kernel');
    disp('>>Trained.')
    disp('>>Evaluating...')
    [Yhat,~]=resubPredict(Mdl);
    ErrorSelFeat=1-numel(find(Y==Yhat))/numel(Y);
else
    disp('>>It is needed to use all the features.')
    ErrorSelFeat=ECVall;
    OKFeatures=1:NFeatures;
    C=Call;
end

%% Display Exploratory Plot of The Selected Features
fprintf('Cross-Validated Classification Error: %3.1f %%\n',100*ErrorSelFeat);
fprintf('Selected Features: %i of %i:\n',numel(OKFeatures),NFeatures);
NameFeatures(OKFeatures)'
table(order,C)
[C,order]=confusionmat(Y,Yhat)
disp('>>MissClassified Experiment:')
[EXPIDs(Y~=Yhat),Y(Y~=Yhat)]

% [~,score] = resubPredict(Mdl);

% ROC curve ******************************************************
% figure; hold on;
% for s=1:numel(order)
%     [Xroc,Yroc,Troc,AUC(s)] = perfcurve(Y,score(:,s),char(order(s)));
%     plot(Xroc,Yroc)
%     LegLab{s}=char(order(s));
% end
% hold off; legend(LegLab)
% xlabel('False positive rate') 
% ylabel('True positive rate')
% pause


%% Boxplots
okbutton = questdlg('Show Feature Boxplots?');
waitfor(okbutton); 
if strcmp('Yes',okbutton)
    for n=1:numel(OKFeatures)
        ActualFeature=OKFeatures(n);
        Xdata=X(:,ActualFeature);
        figure;
        boxplot(Xdata,Y)
        title(NameFeatures(OKFeatures(n)))
    end
end
%% Scatter PLots
okbutton = questdlg('Show 3-Feature Scatter Plots?');
waitfor(okbutton); 
if strcmp('Yes',okbutton)
    NFeatComb=nchoosek(OKFeatures,3);
    Ncomb=size(NFeatComb,1);
    Ncolors=numel(unique(Y));
    CM=jet(Ncolors);
    Labels=unique(Y);
    Colors=zeros(size(Y));
    ColorsHatRGB=zeros(numel(Colors),3);
    for c=1:Ncolors
        Colors(Y==Labels(c))=c;
        Nrowsid=find(Yhat==Labels(c));
        ColorsHatRGB(Nrowsid,:)=repmat(CM(c,:),numel(Nrowsid),1);
    end
    % Missclassified * * * *  * * * * 
    MissClassData=find(Y~=Yhat);
    for n=1:Ncomb
        ComBF=NFeatComb(n,:);
        x=X(:,ComBF(1));
        y=X(:,ComBF(2));
        z=X(:,ComBF(3));
        s=50*ones(size(x));
        figure; 
        hs=scatter3(x,y,z,s,Colors,'filled'); hold on;
        for m=1:numel(MissClassData)
            plot3(x(MissClassData(m)),y(MissClassData(m)),...
                z(MissClassData(m)),...
                'LineStyle','none',...
                'Marker','x',...
                'LineWidth',2,...
                'MarkerSize',15,...
                'MarkerEdgeColor',ColorsHatRGB(MissClassData(m),:)); 
        end
        hs.MarkerEdgeColor='k';
        hold off;
        xlabel(NameFeatures(ComBF(1)));
        ylabel(NameFeatures(ComBF(2)));
        zlabel(NameFeatures(ComBF(3)));
    end
end