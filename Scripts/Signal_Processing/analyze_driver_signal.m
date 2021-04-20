% Function to anlize Driver Function:
% Check if first samples are the biggest ones (mainly due to miss
% detrending, fast bleaching or decay of fluorescence
% Input
%   D:              Original Set of Row Vector of Driver Signals
%   FR:             Response Functions
%   XDupdate:       Detrendend Signals
%   Xest:           Denoised Signals
%   SigmaNoise:     Standard Deviation of Noise
% Output
%   Dfix:           Fixed Set of Row Vector of Driver Signals
%   XDfix:          Detrended Signals Fixed
%   Xestfix:        Denoised Signals Fixed
%   LambdasFix:     Lambdas Recalculated
%   IndexesFix:     Indexes of Fixed Cells
%   Features:       [SkewSignal, SkewNoise, SRbyWT] Matrix of Fetures]
function [Dfix,XDfix,Xestfix,LambdasFix,IndexesFix,Features]=analyze_driver_signal(D,FR,XDupdate,Xest,varargin)
% check if Activate Driver Analysis
if isempty(varargin)
    check=1;
else
    check=0;
    disp('Only Checkin Driver Amplitudes')
end
% Make size of Cells x Frames:
D=makecellsxframes(D);
XDupdate=makecellsxframes(XDupdate);
Xest=makecellsxframes(Xest);
% Initial Decay due to firing or "fast bleaching"
[C,~]=size(D); % Length of okINDX (!) carefull if size(D)=[1,F]
% Initialize Output
Xestfix=Xest;
XDfix=XDupdate;
Dfix=D;
LambdasFix=[];
IndexesFix=[];
fixindx=1;
Features=[];
for c=1:C
    % Get Single Signals ##########################################
    rbiexp=FR(c,:);  % response function
    d=D(c,:);   % driver function
    x_sparse=sparse_convolution(d,rbiexp); % Clean Signal
    % x_sparsePRE=x_sparse;
    disp(c);
    xd=XDupdate(c,:);
    xe=Xest(c,:);
    noisex=xd-xe;
    % Initial Maximum Driver->Distortion ##########################
    [~,framax]=max(d);
    if and(framax==1 && ~isempty(d(d~=0)) ,check)
        % nextframe=framax+1;
        [~,framvall]=findpeaks(-xe); % valleys
        if ~isempty(framvall)
            nextframe=framvall(find(xe(framvall)<std(noisex),1));
            if isempty(nextframe)
                nextframe=2;
            end
        else
            nextframe=2;
        end
        % while and(nextframe<numel(xe),and(xe(nextframe)>0,x_sparse(nextframe)>0.5e-3))
        %    % x_sparse(nextframe)=0;
        %    % d(nextframe)=0;
        %    nextframe=nextframe+1;
        % end
      
% Fix Initial Fast Bleaching
%         Apeaks=findpeaks(xe(1:nextframe));
%         if isempty(Apeaks)
%             XDfix(c,1:nextframe)=XDfix(c,1:nextframe)-x_sparsePRE(1:nextframe);
%         else
        % dxe=diff(xe); % derivative of clean signal
%         if nextframe>3
%             decayok=true;
%             while decayok
%                 xexp=fit([1:nextframe]',xd(1:nextframe)','exp1');
%                 xdecay=xexp(1:nextframe);
%                 if xdecay(end)>xd(nextframe)
%                     nextframe=nextframe+1;
%                     if nextframe>=numel(xe)
%                         decayok=false;
%                     end
%                 else
%                     decayok=false;
%                 end
%             end
%             
%             xd(1:nextframe)=xd(1:nextframe)-xdecay';
%             XDfix(c,:)=xd;
%             disp('\___ Initial decay ~~>')
%         end
        if and(nextframe>3,xe(1)>std(noisex))
            % Check if there is a Peak in Between
            AmpP=findpeaks(xe(1:nextframe));
            if isempty(AmpP); AmpP=0; end
            if AmpP<std(noisex)
                % if NO : exponential decay
                xexp=fit([1:nextframe]',xd(1:nextframe)','exp1');
                xdecay=xexp(1:nextframe);
            else
                % if DOES set a line
                xdecay=getlinearsegment(xe(1:nextframe),std(noisex),1)';
            end
            xd(1:nextframe)=xd(1:nextframe)-xdecay';
            XDfix(c,:)=xd; % detrended
            disp('\___ Initial decay ~~>')
        end
        
%         end
        [xe,noisex]=mini_denoise(xd); % update and fix
        [d,lambdaD]=maxlambda_finder(xd,rbiexp); % +& - drive
        %[d,lambdaD]=maxlambda_finder(xd,rbiexp,0); % only + drive
        x_sparse=sparse_convolution(d,rbiexp);
        Xestfix(c,:)=xe;
        % Dfix(c,:)=d; % update and fix
        LambdasFix=[LambdasFix,lambdaD];
        IndexesFix=[IndexesFix,c];
        % Recalculate Signal Features:
        [Features(fixindx,1),Features(fixindx,2),Features(fixindx,3),~]=feature_extraction(xe,noisex);
        fixindx=fixindx+1;
        disp('Initial fast bleaching or decaying')
    else
        disp('Fluoresence Trace OK')
    end
    % Delete Small Changes below Noise #############################
    % Check Responses below Noise:
    % Thd=abs(min(d));
    SamplesDelete=1:numel(x_sparse);
    [ApeaksAll,NpeaksAll]=findpeaks(x_sparse);
    [~,NvallsAll]=findpeaks(-x_sparse);
    SaveSamples=[];
    % GET ONLY PEAKS ABOVE NOISE
    okPeaks=find(ApeaksAll>std(noisex)); 
    Apeaks=ApeaksAll(okPeaks);
    Npeaks=NpeaksAll(okPeaks);
    % dx_sparse=diff(x_sparse);
    n=1;
    while n<=numel(Npeaks)
        fprintf('Analysing Peak %i of %i ',n,numel(Npeaks));
        % Before the peak $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
        auxN=0;
        isPeakStop=1;
        % WHILE    ---signal is +--------------&---SAmples are +---&dont get another peak
        while and(and(x_sparse(Npeaks(n)-auxN)>0,Npeaks(n)-auxN>0),isPeakStop)
            if Npeaks(n)>1
                if and(ismember(Npeaks(n)-auxN,NvallsAll),x_sparse(Npeaks(n)-auxN)<std(noisex))
                    isPeakStop=0;
                else
                    SaveSamples=[SaveSamples,(Npeaks(n)-auxN)];
                end
            else
                SaveSamples=[SaveSamples,(Npeaks(n)-auxN)];
            end
            fprintf('.');
            auxN=auxN+1;
        end
        fprintf('\n');
        % After the peak $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
        auxN=1;
        isPeakStop=1;
        while and(and(x_sparse(Npeaks(n)+auxN)>0,Npeaks(n)+auxN<numel(x_sparse)),isPeakStop)
            if n<numel(Npeaks)
                if and(ismember(Npeaks(n)+auxN,NpeaksAll),x_sparse(Npeaks(n)+auxN)<std(noisex))
                    isPeakStop=0;
                else
                    SaveSamples=[SaveSamples,(Npeaks(n)+auxN)];
                end
            else
                SaveSamples=[SaveSamples,(Npeaks(n)+auxN)];
            end
            auxN=auxN+1;
            fprintf('.');
            % SaveSamples=[SaveSamples,(Npeaks(n)+auxN)];
            % auxN=auxN+1;
        end
        n=find(Npeaks>max(SaveSamples),1);
        if isempty(n)
            n=numel(Npeaks)+1;
        end
        fprintf('\n');
    end
    fprintf('\n');
    SaveSamples=unique(SaveSamples); % just to sort them
    if ~isempty(SaveSamples)
        SamplesDelete=setdiff([1:numel(x_sparse)],SaveSamples);
        d(SamplesDelete)=0;
        x_sparse(SamplesDelete)=0;
    else
        d(SamplesDelete)=0;
        x_sparse(SamplesDelete)=0;
    end
    % Just (+) Drivers
    d(d<0)=0;
    
    if check==0
        Xestfix(c,:)=x_sparse;
    end
    % Spurious Drivers:
    % dbuffer=d;
    % d(:)=0;
    dx_sparse=diff(xe);
    d( dx_sparse<0 )=0;
    
    Dfix(c,:)=d; % update and fix
    %d(sign(dbuffer).*sign(dx_sparse)>0)=dbuffer(sign(dbuffer).*sign(dx_sparse)>0);
%     %% CHECK STUFF
%     plot(xd,'b'); hold on;
%     plot(xe,'m'); 
%     plot(x_sparse,'g','LineWidth',2);
%     plot([0,numel(x_sparse)],[std(noisex),std(noisex)],'-.r');
%     bar(d); hold off;
%     disp(c) 
%     pause
    
end

end % END OF THE WORLD
