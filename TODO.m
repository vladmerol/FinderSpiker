%% NOTE A:
% Manual Mode->Necessary to know the statistics power
% of the automatic method by dividing in -+ and -- (false+ & false-)
% Old Version Manual Mode:
%   Manual_Driver_Raster_Magic.m
%% FIXED  before update GIT
% Manual Delete: fail update from driver selection->Zero Driver Stuff
% Run ONLY Undetected_Visual_Inspection, SAVE AFTER!OK
% Why it makes a Lambda Searcher in lambda tunning?->OK driver analyse function inputs
% OddsMatrix Issue-> OK
%% Bugs & New Functions NOW

% Set a waitfor(msgbox('processing')); delete(gco):OK
% Plot after Processing the UNporcessed: get raster: OK
% Get Raster Function->

% Delete :
%   Manual_Driver_Raster_Magic_Ultimate



% NO TO SO URGENT
% Re consider Accepted and Rejected ones @ automatic mode
% Add Highlight Neuron Using Mouse at Plot_Raster
% Progress Bar for Visual Inspection
% Get Raster Mode -> update in Manual Mode
% Driver Analysis-> Consider Derivative or Valleys
% Manual Mode for a specific raster ONLY!
% Manual mode without using pause---update workspace automatically
% and other colors in the MERGE script : MAGENTA
% Threshold to get NETWORK !!!!!!!!
% Kalman Filtering at SNR and lambdas pdf's: for optimal threshold

%% STEPS ******************************************
%PROCESSING
% RUN >>Raster_Magic_Better
% RUN >>Detected_Visual_Inspection
% RUN >>Undetected_Visual_Inspection
% RUN >>PLot_and_Save


% RASTER SELECTION
% ACTUAL MODE: @ Original Coordiantes Order
% [RASTER_Selected_Clean,XY_selected,R_Condition,Onsets]= Select_Raster_for_NN(fs,Raster_Condition,XY,Names_Conditions,Experiment);
% R=RASTER_Selected_Clean';
% R_CONDTION1=R_Condition{1}';
% ...
% R_CONDTIONi=R_Condition{i}';

% CLUSTERING
% 'Got to Dir' 
% C:\Users\Vladimir\Documents\Doctorado\Software\GetTransitum\Calcium Imaging Signal Processing\NeuralNetworks
% NeuralNetwork-> GUI mode-> Clustering Analysis
% Ensemble_Sorting

% COLOCALIZATION OF MARKED CELLS
% [XY_merged,ColocateIndx]=get_merged_coordinates(Experiment,XY_selected,r);
% Plot_Ensembles_Experiment(R_Condition,EnsembleName,Ensembled_Labels,Ensemble_Threshold,UniRMutiE,ColorState,fs,[]);
% [Features_Ensemble,Features_Condition]=get_ensembles_features(R_Condition,Ensemble_Threshold,Ensembled_Labels,fs);


%% FUTURE **********************************
% Figure: reason whi mean(ROI) withput distortion
% Load Raw FLuorescenc vs F_0 distortion

% 1st Part Automatic: Raster Method
% Analyze Rejects Ones Anyway to infer Artifacts

% CLUSTERING STUFF ***********************
% Threshold: prior numbercoactivyt:
% [THCOAC]=mctest(R,'modes')
% Clustering
% [Ensembles,N_Ensembles,MethodsClustering,ThEffective,
% label_frames,
% signifi_frames]=ensemble_clusterin(R,THCOAC);

% Setup Intel/Info .mat File-> Default User Direcotry to save info
% Setup Script