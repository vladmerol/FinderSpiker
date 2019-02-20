%% Set Filter to Ban Experiments from Classification Stage
% Due to undesired very low activity or atifacts
% According to Raster Activity Features and General Ensemble Features
% and The Condition

% Input:
%   Features Thresholds
% Output:
%   List of Experiments IDs to ban
%% Setup Criteria Thresholds *******************************************
% Discriminate the Following Features
% For Initial Condition Usually
% Thresholds are MINIMAL values ACCEPTDE
ConditionNameCheck='Dyskinesia';
% Raster Activity Minimal Constraint:
DF.RateNeurons_Threshold=0;
DF.EffectiveActivity_Threshold=0.25;
% Ensembles General Minimal Constraint:
DF.RateTrans_Threshold=0;
DF.RateCycles_Threshold=0;
DF.SynWeigthMean_Threshold=0;
DF.SynWeigthVar_Threshold=0;
%% Load Datasetes ******************************************************
% Raster Activity Minimal Constraint:
Dirpwd=pwd;
slashesindx=find(Dirpwd=='\');
CurrentPathOK=[Dirpwd(1:slashesindx(end))]; % Finder Spiker Root Folder

% Load File 
[FileName,PathName] = uigetfile('*.csv','Raster Activity Dataset',...
    'MultiSelect', 'off',CurrentPathOK);
CurrentPathOK=PathName;
Xraster=readtable([PathName,FileName]);
Yraster=categorical(table2array( Xraster(:,1)) );   % Labels
EXPIDraster=table2array( Xraster(:,2));             % EXPIDs Cell of Strings
FeaturesRaster=Xraster.Properties.VariableNames;    % Feature Names


% Ensembles General Minimal Constraint:
% Load File 
[FileName,PathName] = uigetfile('*.csv','General Ensembles Dataset',...
    'MultiSelect', 'off',CurrentPathOK);
Xensemble=readtable([PathName,FileName]);
Yensemble=categorical(table2array( Xensemble(:,1)) );   % Categorical ARRAYS
EXPIDensemble=table2array( Xensemble(:,2));             % EXPIDs Cell of Strings
FeaturesEnsemble=Xensemble.Properties.VariableNames;    % Feature Names
ignftr=[13,14,15]; % Links/Neuron A->euron B Most Connected
acceptcols=setdiff(1:numel(FeaturesEnsemble),ignftr);
Xensemble=Xensemble(:,acceptcols);
FeaturesEnsemble=FeaturesEnsemble(acceptcols);
% Load NETWORK excel
[FileName,PathName,MoreFiles] = uigetfile('*.xlsx','Network Dataset file',...
    'MultiSelect', 'off',CurrentPathOK);
Xnet=readtable([PathName,FileName]);        % Table
% Check table
LimitRow=find(isnan(table2array (Xnet(:,3) ) ),1)-1;
LimitCol=12;
Xnet=Xnet(1:LimitRow,1:LimitCol);
Ynet=categorical(table2array( Xnet(:,1)) );    % Labels
EXPIDnet=table2array( Xnet(:,2));             % Cell of Strings
FeaturesNet=Xnet.Properties.VariableNames(3:end);    % Feature Names


%% Filter Experiment IDs *************************************************
% Discriminant Feature Loop
DFNames=fieldnames(DF);
RejectedExperiments={};
aux=1;
for n=1:numel(DFNames)
    ActualFeature=DFNames{n};
    Actual_Threshold=getfield(DF,ActualFeature);
    auxchar=find(ActualFeature=='_');
    fprintf('>>Checking Feature: %s \n',ActualFeature(1:auxchar-1));
    % Check kind of Feature
    if ismember(ActualFeature(1:auxchar-1),FeaturesRaster)
        fprintf('>Raster Feature: %s.\n',ActualFeature(1:auxchar-1))
        FeatureVector=getfield(Xraster,ActualFeature(1:auxchar-1));
        Y=Yraster;
        EXPID=EXPIDraster;
    elseif ismember(ActualFeature(1:auxchar-1),FeaturesEnsemble)
        fprintf('>Ensemble Feature: %s.\n',ActualFeature(1:auxchar-1))
        FeatureVector=getfield(Xensemble,ActualFeature(1:auxchar-1));
        Y=Yensemble;
        EXPID=EXPIDensemble;
    else
        disp('Feature Not Found.')
    end
    % Identify Experiments
    EXPindx=find(Y==categorical(cellstr(ConditionNameCheck) ));
    % Rejec Experiments of the Conditions:
    % Thresholds are MINIMAL values ACCEPTDE
    RejectIndexofEXPID=find(FeatureVector(EXPindx)<=Actual_Threshold);
    RejectedEXpIndx=EXPindx(RejectIndexofEXPID);
    if isempty(RejectedEXpIndx)
    else
        RejectedExperiments=[RejectedExperiments;EXPID(RejectedEXpIndx)];
    end
end
RejectedExperiments=unique(RejectedExperiments);
%% MERGE DATASETS: RASTER|ENSEMBLES|NETWORK
% get same sorting for labels and Dateset rows WITHOUT THE REJECTED ONES