% Funtion to denoise Fluorescence Signals
% By Wavelet Analysis under asumption: noise is iid
% argmin_dbw  { AUC(noise) }
% Input
%   XD:     Detrended Signal
% Output
%   Xest:       Estimated Denoised Signals
%   SNRbyWT:    SNR by wavelet denoising
%   SkewSignal: Skewness of Denoised Signal
%   ABratio:    Max Peak-Valley Amplitude Ratio in Dneoised Signal
%   SkewNoise:  Skewness of Noise
function [Xest,SNRbyWT,SkewSignal,ABratio,SkewNoise,XDupdate]=denoise_wavelet(XD)
%% Setup ****************************
[Ns,Frames]=size(XD);
Xest=zeros(Ns,Frames);
SkewSignal=zeros(Ns,1);
SkewNoise=zeros(Ns,1);
ABratio=zeros(Ns,1);
SNRbyWT=zeros(Ns,1);
XDupdate=XD;
%% FOR---------------------------------------------------------------------
for i=1:Ns
    xd=XD(i,:);
    disp(['------------------>    Denoising Signal: ',num2str(i),'/',num2str(Ns)]);
    % SNR by Wavelet Processing and Autocorrelation Diminishment
    [xdenoised,noisex]=mini_denoise(xd);
    %% DETRENDING FIXING #############################################
    [ValleAMP,ValleN]=findpeaks(-xdenoised);    % Get Valleys of Denoised Signal
    if ~isempty(ValleAMP)
        ValleAMPabs=abs(ValleAMP);
        ValleAMPflip=-ValleAMP;    % actual values
        [pV,binV]=ksdensity(ValleAMPabs);    % pdf of Valley Amplitudes
        [Vp,Vbin,Vwidth]=findpeaks(pV,binV); % modes of odf valleys
        if numel(Vp)>1
            % Take only small amplitudes
            [~,indxsmallAMps]=min(Vbin);
            LOWwaves=ValleAMPflip(ValleAMPflip<=Vbin(indxsmallAMps)+Vwidth(indxsmallAMps));
            LOWwavesFrames=ValleN(ValleAMPflip<=Vbin(indxsmallAMps)+Vwidth(indxsmallAMps));
        else
            LOWwaves=ValleAMP;
            LOWwavesFrames=ValleN;
        end
    else
        LOWwavesFrames=[];
        disp('-------------------------No distortion issues')
    end
    LOWwavesFrames=[1,LOWwavesFrames,Frames+1];
    LOWwavesFrames=unique(LOWwavesFrames);
%     % Plot Results
%     plot(xd)
%     hold on
%     plot(xdenoised);
%     plot(LOWwavesFrames(2:end-1),xdenoised(LOWwavesFrames(2:end-1)),'*k')
%     hold off
%     axis tight; grid on;
    xlin=[];
    if numel(LOWwavesFrames)>2
        for n=1:numel(LOWwavesFrames)-1
            xxtr=xdenoised(LOWwavesFrames(n):LOWwavesFrames(n+1)-1);
            mslope=(xxtr(end)-xxtr(1))/length(xxtr);
            xlinc=mslope*([1:length(xxtr)]-1)+xxtr(1);
            % xtrace=xxtr-xlinc;
            if length(xxtr-xlinc)>2
                AmpPeak=findpeaks((xxtr-xlinc),'SortStr','descend');
                if ~isempty(AmpPeak)>0
                    if AmpPeak(1)>=std(noisex)
                        disp('-OK-')
                    else
                        xlinc=xxtr;
                        disp('low movements <A>')
                    end
                else
                    disp('low movements <B>')
                end
            end
            xlin=[xlin,xlinc];
        end
        disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Fixing Distortion')
        xdupdate=xd-xlin;
        xdupdate=xdupdate - var(noisex); % Remove Offset Introduced by Valley-Linear Trending
        [xdenoised,noisex]=mini_denoise(xdupdate);
        % check out #######################
        %         plot(xdupdate); pause;
        XDupdate(i,:)=xdupdate;
    end

    %% FEATURE EXTRACTION ############################################
    Aden=findpeaks(xdenoised,'NPeaks',1,'SortStr','descend');
    if isempty(Aden)
        Aden=0;
        disp('..................No (+)Peaks');
    end
%     Anoise=var(noisex);
%     
    Bden=findpeaks(-xdenoised,'NPeaks',1,'SortStr','descend');
    if isempty(Bden)
        Bden=0;
        disp('.................No  (-)Peaks');
    end    
%     Aratio(i)=Aden/Anoise;  % PEAKS SIGNAL/NOISE RATIO
    ABratio(i)=Aden/Bden;   % max/min RATIO
    SkewSignal(i)=skewness(xdenoised,0); % $ $ $  OUTPUT
    SkewNoise(i)=skewness(noisex,0); % $ $ $  OUTPUT
    % SkewRation sensitive to misdetrending distortion
    
    SNRbyWT(i)=10*log(var(xdenoised)/var(noisex)); % $ $ $ $ $       OUTPUT
    Xest(i,:)=xdenoised; % SAVE DENOISED  * * * * ** $ $ $ $        OUTPUT
    
    
end

%% NESTED functions
    function [xdenoised,noisex]=mini_denoise(xd)
        dbw=1;          % Degree (Order )Wavelet
        gradacf=-10;
        acf_pre=1;
        ondeleta='sym8'; % Sort of Wavelet
        while ~or(gradacf>=0,dbw>9)
            disp(['DENOISING by wavelet level . . . . . ',num2str(dbw)])
            %         [xdenoised,~,~,~,~] = cmddenoise(xd,ondeleta,dbw);
            %          xdenoised=smooth(xd,SWS,'rloess'); ALTERNATIVE
            xdenoised=waveletdenoise(xd,ondeleta,dbw);
            noise=xd-xdenoised;
            acf=autocorr(noise,1);
            acf_act=abs(acf(end));
            gradacf=acf_act-acf_pre;
            acf_pre=acf_act;    % update ACF value
            dbw=dbw+1;          % Increase wavelet level
        end
        disp(' denoised <<<<<<<<<<<<<<<<<<<<<<<')
        dbw_opt=dbw-2; % Beacuse it detected +1 and increased it anyway +1
        %     [xdenoised,~,~,~,~] = cmddenoise(xd,ondeleta,dbw_opt);
        xdenoised=waveletdenoise(xd,ondeleta,dbw_opt);
        noisex=xd-xdenoised;
    end    
end