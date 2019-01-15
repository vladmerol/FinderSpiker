%% Function to plot raster
% input
%   R:          Raster Matrix Cells x Frames
%   indexes:    Index of Neurons
%   stepy:      Y Tick Set
%   fs= sampling frequency
% Output
% figure of the raster in MINUTES
% Always creates a new figure
function Plot_Raster_Ensembles(R,indexes,stepy,varargin)
if numel(varargin)==1
    fs=varargin{1};
    ColocateIndx=[];% Indexes of Colocalized Neurons
    Neurons_Colocalized=[];
else
    fs=varargin{1};
    ColocateIndx=varargin{2};
    Neurons_Colocalized=find(ColocateIndx);
end
figure
ax1=subplot(3,1,[1,2]);
hold on;
% Identify Cell and Frame Matrix Dimension
[C,F]=size(R);
if C>F
    R=R';
    [C,~]=size(R);
end

ts=1/fs;
for i=1:C
    j=indexes(i);
    if ismember(j,Neurons_Colocalized)
            plot(ts*find(R(j,:))/60,i*R(j,R(j,:)>0),'Marker','square',...
            'LineWidth',2,...
            'LineStyle','none',...
            'MarkerSize',7,...
            'MarkerEdgeColor',[1,0.6,0.78],...
            'MarkerFaceColor',[1,0.6,0.78]); hold on;
    end
    % Dots @ Raster
%     plot(ts*find(R(j,:))/60,i*R(j,R(j,:)>0),'Marker','square',...
%         'LineStyle','none',...            
%         'MarkerEdgeColor','k',...
%         'MarkerFaceColor','k',...
%         'MarkerSize',4); hold on;
    ypositon=[j,1];
    activeframes=find(R(j,:));
    nf=1;
    xposition(1)=activeframes(1)-0.5;
    xposition(2)=1;
    while nf<numel(activeframes)
        nx=nf;
        while activeframes(nx+1)==activeframes(nx)+1
            xposition(2)=xposition(2)+1;
            if nx+1==numel(activeframes)
                activeframes=[activeframes,0];
                % never and active frame is going to be Zero
                % Stop sloop;
            else
                nx=nx+1;
            end
        end
        % Create Rectangle *************************
        xposs=ts*xposition/60;
        rectangle('Position',[xposs(1),ypositon(1),...
                xposs(2),ypositon(2)],'Curvature',0.2,...
                'EdgeColor','k',...
                'FaceColor','k');
        fprintf('*')
        % Restart xposition values
        xposition(1)=activeframes(nx+1)-0.5;
        xposition(2)=1;
        nf=nx+1;
    end
    fprintf('\n')
end
axis([0,ts*(length(R)-1)/60,1,C])
ylabel('Neural Activity')
set(gca,'XTick',[])
set(gca,'Box','off')
% Sorted Neurons according to Ensembles
yticks=indexes';
set(gca,'YTick',1:stepy:C)
set(gca,'YTickLabel',yticks(1:stepy:C))
set(gca,'TickLength',[0,0])

ax2=subplot(3,1,3);
plot(ts*(0:length(sum(R))-1)/60,sum(R),'k','LineWidth',1.1)
if ~isempty(ColocateIndx)
    hold on;
    plot(ts*(0:length(sum(R))-1)/60,sum(R(Neurons_Colocalized,:)),'Color',[1,0.6,0.78],'LineWidth',1.1)
end
hold on;

axis([0,ts*(length(R)-1)/60,0,max(sum(R))+1])
% grid on
ylabel('CAG')
xlabel('Minutes')


set(gca,'Box','off')
set(gca,'XTick',0:1:ts*(length(R)/60))
lisp=linspace(round(max(sum(R))/2),max(sum(R)),2);
if lisp(1)~=lisp(2)
    set(gca,'YTick',floor(linspace(round(max(sum(R))/2),max(sum(R)),2)))
end
linkaxes([ax1,ax2],'x')
end