% Script TO merge Datasets of the Following Caterogry of Features:
%   'Raster Activity';
%   'General Ensembles';
%   'Detailed Ensembles';
%% Select Kind Of Features to Merge
KindFeatures={'Raster Activity';'General Ensembles';...
    'Detailed Ensembles'};
[index_var,index_CHECK] = listdlg('PromptString','Select Sort of Features:',...
            'SelectionMode','single',...
            'ListString',KindFeatures);
SelectedCatergory=KindFeatures{index_var};
%% Setup
% Initial:
runs=1;             % Runs Counter
EXPS={};            % List Of Experiments
% Directory:
Dirpwd=pwd;
slashesindx=find(Dirpwd=='\');
% Select Folder
if index_var<2
    FolderDefault='Raster Features';
    HeadersFeatures={'Condition','EXP_ID','RateNeurons','ActivityTimeFraction',...
        'ActiveRatioCAG','EffectiveActivity',...
        'ISImean','ISImode','ISIvar','ISIskew','ISIkurt',...
        'Lengthmean','Lengthmode','Lengthvar','Lengthskew','Lengthkurt',...
        'CAGmean','CAGmode','CAGvar','CAGskew','CAGkurt',...
        'RoAmean','RoAmode','RoAvar','RoAskew','RoAkurt'};
else
    FolderDefault='Ensemble Features';
    if index_var<3
        HeadersFeatures={'Condition','EXP_ID','Nensembles','Threshold','Dunns','MaxIntraVec','ClassError',...
         'RateTrans','RateCycles','SimpleCycles','ClosedCycles','OpenedCycles',...
         'CAGauc','CoreSize','MaxSynLinks','MaxConn_A','MaxConn_B',...
         'SynWeigthMean','SynWeigthVar','SynWeigthSkew','SynWeigthKurt'};
    else
        HeadersFeatures={'Condition','EXP_ID','NeuronsRation','Time','Dominance','Rate',...
     'ensCAGauc','ensCAGmean','ensCAGvar','ensCAGskew','ensCAGkurt'...
     'IEImean','IEIvar','IEIskew','IEIkurt'...
     'EDmean','EDvar','EDskew','EDkurt'};
    end
end
CurrentPathOK=[Dirpwd(1:slashesindx(end)),FolderDefault]; 
% Load File 
[FileName,PathName,MoreFiles] = uigetfile('*.csv',[SelectedCatergory,' Feature Database file'],...
    'MultiSelect', 'off',CurrentPathOK);
%% Loop to keep loading files
FeaturesSingle=table;
while MoreFiles

    % Numerical Data
    rowFeatures=readtable([PathName,FileName]);
    FeaturesSingle=[FeaturesSingle;rowFeatures]; 
    
    % Disp Experiments Selected:
    EXPS{runs,1}=FileName
    CurrentPathOK=PathName;
    runs=runs+1;
    [FileName,PathName,MoreFiles] = uigetfile('*.csv',[SelectedCatergory,' Feature Database file'],...
    'MultiSelect', 'off',CurrentPathOK);
end
FeaturesSingle.Properties.VariableNames=HeadersFeatures;
disp('>>end.')
%% Make and Save Table
okbutton = questdlg(['Make CSV for ',SelectedCatergory,' Features Table?']);
waitfor(okbutton); 
if strcmp('Yes',okbutton)
    % Set Save Name
    timesave=clock;
    TS=num2str(timesave(1:5));
    TS=TS(TS~=' ');
    SelectedCatergory(SelectedCatergory==' ')='_';
    SaveFile=[SelectedCatergory,'_Dataset_',TS,'.csv'];
    % Select Destiny
    PathSave=uigetdir(CurrentPathOK);
    disp('>>Making CSV table...')
    writetable(FeaturesSingle,[PathSave,'\',SaveFile],...
                    'Delimiter',',','QuoteStrings',true);
    fprintf('>> Data saved @: %s\n',[PathSave,SaveFile])
else
    fprintf('>>Unsaved data.\n')
end
fprintf('>>Cleaning Workspace: ')
clear
fprintf('done\n')
%% END