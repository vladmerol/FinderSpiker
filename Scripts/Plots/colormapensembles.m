% Funtion that genera COlr of The Ensembles
% According to the number of ensembles and conditions
% Input
%   TotalNG:    Total Number of Ensembles
%   NC:         Number of Conditions
%   NGroups:    N ensembles in each Condition
% Ouput
% Colormap      Matrix NC+1 x 3 RGB
function ColorState=colormapensembles(TotalNG,NC,NGroups)
%% Color map Generation: HSV colormap *****************************
CounterColors=TotalNG+1; % A color for each group plus all-neuron together
ColorStatesIndx=round(linspace(1,CounterColors,TotalNG+1));
ColorStatesIndx=ColorStatesIndx(1:end-1)';
ColorStatesIndx=[ColorStatesIndx;setdiff(1:CounterColors,ColorStatesIndx)'];
% ColorState=colormap(hsv(CounterColors));
ColorState=hsv(CounterColors);
ColorState=ColorState(ColorStatesIndx,:);
%% Initialize ColorMap [FiXeD Map]
% Define Sets of Colors (User Interface->Later)
% First Condition 3 Colors (see P�rez-Ortega et al, 2016)
redensemble=[0.8549,0.1,0.11];
greenensemble=[0.44,0.77,0];
blueensemble=[0.17,0.39,0.99];
% 2nd Set of Colors
yellowensemble=[0.949,1,0];
cyanensemble=[0,1,1];
violetensemble=[0.949,0,1];
% 3th Set of Colors [colors in between]
orangeensemble=[1,0.298,0];
lemonensemble=[0.6471,1,0];
aquaensemble=[0,1,0.4];
% 4th Set of Colors [colors in between]
orange2ensemble=[1,0.6,0];
skyensemble=[0,0.549,1];
grapeensemble=[1,0,0.749];
% 5th Set
hubbensemble=[ 0.70588,0,0.78431]; % DEEP PURPLE     \m,/   \,m/
% Initialize Color Map
Static_Color_Map=[redensemble;greenensemble;blueensemble;...
yellowensemble;cyanensemble;violetensemble;...
orangeensemble;lemonensemble;aquaensemble;...
orange2ensemble;skyensemble;grapeensemble;...
hubbensemble];
%% Set Color Ensembles according to Conditions & Number of Ensembles
ColorState=zeros(TotalNG+1,3);
SetIndx=1;
EnsmblIndx=1;
TailColor=12;
IndxLeaveOut=[];
IndxGotIn=[];
if TotalNG<=12
    for c=1:NC
        % Selecting Sets of 3 ensembles
        if NGroups{c}<=3 % Increase by 3-set Color Ensemble
            if SetIndx>TotalNG && EnsmblIndx<TotalNG
                ColorState(EnsmblIndx:EnsmblIndx+NGroups{c}-1,:)=Static_Color_Map(IndxLeaveOut(1:1+NGroups{c}-1),:);
                IndxGotIn=[IndxGotIn,IndxLeaveOut(1:1+NGroups{c}-1)];   % Indexes USED
                % SetIndx=SetIndx+3;                                    % Next Set
                EnsmblIndx=EnsmblIndx+NGroups{c};                       % Next Ensembles
            else
                ColorState(EnsmblIndx:EnsmblIndx+NGroups{c}-1,:)=Static_Color_Map(SetIndx:SetIndx+NGroups{c}-1,:);
                IndxGotIn=[IndxGotIn,SetIndx:SetIndx+NGroups{c}-1]; % Indexes USED
                SetIndx=SetIndx+3;                      % Next Set
                EnsmblIndx=EnsmblIndx+NGroups{c};       % Next Ensembles
            end
            % If tail isn't member of selected indexes
        else
            %if isempty(intersect(TailColor:-1:TailColor-((EnsmblIndx+NGroups{c}-1)-(EnsmblIndx+3)),IndxGotIn))
            if isempty(intersect(TailColor:-1:TailColor-((EnsmblIndx+NGroups{c}-1)-(EnsmblIndx+3)),SetIndx:SetIndx+3-1))
                % First 3
                ColorState(EnsmblIndx:EnsmblIndx+3-1,:)=Static_Color_Map(SetIndx:SetIndx+3-1,:);
                IndxGotIn=[IndxGotIn,SetIndx:SetIndx+3-1];
                % Following Ensembles from the Tail of Static_Color_Map
                ColorState(EnsmblIndx+3:EnsmblIndx+NGroups{c}-1,:)=Static_Color_Map(TailColor:-1:TailColor-((EnsmblIndx+NGroups{c}-1)-(EnsmblIndx+3)),:);
                IndxGotIn=[IndxGotIn,TailColor:-1:TailColor-((EnsmblIndx+NGroups{c}-1)-(EnsmblIndx+3))];
                SetIndx=SetIndx+3;                      % Next Set
                EnsmblIndx=EnsmblIndx+NGroups{c};     % Next Ensembles
                TailColor=TailColor-((EnsmblIndx+NGroups{c}-1)-(EnsmblIndx+3))-1;
            else
                % Case where tails and current selected indexes OVERLAPS
                ColorState(EnsmblIndx:EnsmblIndx+length(intersect(SetIndx:SetIndx+3-1,IndxLeaveOut))-1,:)=Static_Color_Map(intersect(SetIndx:SetIndx+3-1,IndxLeaveOut),:);
                IndxGotIn=[IndxGotIn,intersect(SetIndx:SetIndx+3-1,IndxLeaveOut)];
                Naux=length(intersect(SetIndx:SetIndx+3-1,IndxLeaveOut)); % used indexes
                IndxLeaveOut=setdiff(1:12,IndxGotIn);
                Nmiss=NGroups{c}-Naux;
                ColorState(EnsmblIndx+Naux:EnsmblIndx+Naux+Nmiss-1,:)=Static_Color_Map(IndxLeaveOut(1:Nmiss),:);
                IndxGotIn=[IndxGotIn,IndxLeaveOut(1:Nmiss)];
                disp('>>>>- -- strange  --- case --- <<<<')
            end
        end
        IndxLeaveOut=setdiff(1:12,IndxGotIn);
    end
else
    ColorState(1:TotalNG,:)=hsv(TotalNG);
end
ColorState(end,:)=hubbensemble;
% %% SHOW COLORMAP:
% figure('Position',[800 526 450 150],...
%     'Name','Ensemble Colormap');
% image(1:TotalNG); colormap(ColorState(1:end-1,:))