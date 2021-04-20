function HelpGUI()
% Check Actual Figures
List_of_Figures = findobj(groot,'Type','figure');
naux=1;
CHK=true;
HelpExist=false;
if numel(List_of_Figures)>0
    while CHK
        if strncmpi( List_of_Figures(naux).Name,'Keyboard',7)
            CHK=false;
            HelpExist=true;
        else
            naux=naux+1;
        end
        if naux>numel(List_of_Figures)
            CHK=false;
        end
    end
end
% Help Figure
% fprintf('\n>>Help displayed\n')
if ~HelpExist
    HelpFig=figure('DockCOntrols','off','MenuBar','none', 'NumberTitle',...
        'off','ToolBar','none','Units','normalized','Position',...
        [0.2 0.2 0.6 0.35],'Color','k','Name','FinderSpiker Keyboard Interface to Spikes Inspection ','Visible','off');
    FSDir=pwd;
    Ax1=subplot(131);
    imshow([FSDir,'\figures\RightLeftKeys.png'])
    Ax2=subplot(132);
    imshow([FSDir,'\figures\UpDownKeys.png'])
    Ax3=subplot(133);
    imshow([FSDir,'\figures\MouseClicks.png'])
    Ax1.Position=[0,0.1,0.2134,0.815];
    Ax2.Position=[0.3,0.1,0.2134,0.815];
    Ax3.Position=[0.6,0.1,0.2134,0.815];
    ColumnNavi=uicontrol('Parent',HelpFig,'Style','text','String',...
        'Navigate ROIs','Units','normalized','Position',[0.175 0.80 0.15 0.2],...
        'BackGround','k','ForegroundColor',[1,1,1],'FontSize',12,'FontWeight','bold');
    NextText=uicontrol('Parent',HelpFig,'Style','text','String',...
        'Next','Units','normalized','Position',[0.18 0.55 0.1 0.2],...
        'BackGround','k','ForegroundColor',[1,1,1],'FontSize',12);
    PreText=uicontrol('Parent',HelpFig,'Style','text','String',...
        'Previous','Units','normalized','Position',[0.18 0.20 0.1 0.2],...
        'BackGround','k','ForegroundColor',[1,1,1],'FontSize',12);

    UpText=uicontrol('Parent',HelpFig,'Style','text','String',...
        'Increase','Units','normalized','Position',[0.5 0.55 0.1 0.2],...
        'BackGround','k','ForegroundColor',[1,1,1],'FontSize',12);
    DownText=uicontrol('Parent',HelpFig,'Style','text','String',...
        'Decrease','Units','normalized','Position',[0.5 0.20 0.1 0.2],...
        'BackGround','k','ForegroundColor',[1,1,1],'FontSize',12);
    ColumnRepro=uicontrol('Parent',HelpFig,'Style','text','String',...
        'Spikes Sparseness','Units','normalized','Position',[0.45 0.9 0.25 0.1],...
        'BackGround','k','ForegroundColor',[1,1,1],'FontSize',12,'FontWeight','bold');

    ArtiSpikes=uicontrol('Parent',HelpFig,'Style','text','String',...
        'On spikes: delete interval','Units','normalized','Position',[0.75 0.65 0.25 0.1],...
        'BackGround','k','ForegroundColor',[1,1,1],'FontSize',12);
    RastSpikes=uicontrol('Parent',HelpFig,'Style','text','String',...
        'On raster: delete columns','Units','normalized','Position',[0.75 0.75 0.25 0.1],...
        'BackGround','k','ForegroundColor',[1,1,1],'FontSize',12);
    ColumnDele=uicontrol('Parent',HelpFig,'Style','text','String',...
        'Delete Artefacts','Units','normalized','Position',[0.75 0.9 0.15 0.1],...
        'BackGround','k','ForegroundColor',[1,1,1],'FontSize',12,'FontWeight','bold');

    VideoNavi=uicontrol('Parent',HelpFig,'Style','text','String',...
        'On gray area displays contextual menu','Units',...
        'normalized','Position',[0.75 0.25 0.25 0.15],...
        'BackGround','k','ForegroundColor',[1,1,1],'FontSize',12);
    VideoNaviTitle=uicontrol('Parent',HelpFig,'Style','text','String',...
        'Video/Segments Navigate','Units','normalized','Position',[0.75 0.45 0.25 0.1],...
        'BackGround','k','ForegroundColor',[1,1,1],'FontSize',12,'FontWeight','bold');
    % uiwait(HelpFig)
    % waitfor(HelpFig)
    HelpFig.Visible='on';
    fprintf('\n>>Help displayed\n')
else
    fprintf('\n>>Help already displayed\n')
end
end