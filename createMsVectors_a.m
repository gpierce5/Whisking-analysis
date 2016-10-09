
function createMsVectors(nfile,whiskmat,fname3)

%from Amanda 10/2016

fname = nfile;
fname2 = whiskmat;


%The purpose of this is to create properly aligned 1ms vectors for all data that can then be
%used for further analysis
%interpolates the whisker frame data into ms time

%This data will be saved in a new mat file, for easier analysis

load(fname)

%Spiking
if isempty(fname2) %if there is not an analyzeable whisking video
    spikeStart = 1;
    spikeEnd = length(trialStartTimes);
else
    load(fname2)
end
t_spikeStart = trialStartTimes(spikeStart);
t_spikeEnd = trialStartTimes(spikeEnd);

trialStartTrain = zeros(1,round(totalTime));
trialStartTrain(round(trialStartTimes)) = 1;
trialStartVect = trialStartTrain(t_spikeStart:t_spikeEnd);

spikeTrain = zeros(1,round(totalTime));
spikeTrain(round(spikeTimes)) = 1;
spikeVect = spikeTrain(t_spikeStart:t_spikeEnd);

newTotalTime = length(trialStartVect);

%Licking
lickTrain = zeros(1,round(totalTime));
lickTrain(round(lickTimes)) = 1;
lickVect = lickTrain(t_spikeStart:t_spikeEnd);
locoCheck = 'y';% input('Is lick channel recording locomotion? ');
if isequal(locoCheck,'y')
    lickVect = smoothData(lickVect,3000);
end

%Contacts on poles
if ~exist('contactBottomTimes','var')
    check = input('Get contact data? ');
    if isequal(check,'y')
        getContactTimes_wholetrace_b(fname,'y');
    else
        contactBottomTimes = [];
        contactBottom_var = nans(1,round(totalTime));
        contactTopTimes = [];
        contactTop_var = nans(1,round(totalTime));
        
        save(fname,'contactBottomTimes','contactBottom_var','contactTopTimes','contactTop_var','-append')
    end
    
    load(fname)
end
contactBottomTrain = zeros(1,round(totalTime));
contactBottomTrain(round(contactBottomTimes)) = 1;
contactBottomTimesVect = contactBottomTrain(t_spikeStart:t_spikeEnd);
contactBottomStdVect = contactBottom_var(t_spikeStart:t_spikeEnd);

contactTopTrain = zeros(1,round(totalTime));
contactTopTrain(round(contactTopTimes)) = 1;
contactTopTimesVect = contactTopTrain(t_spikeStart:t_spikeEnd);
contactTopStdVect = contactTop_var(t_spikeStart:t_spikeEnd);

%Reward times
rewardTrain = zeros(1,round(totalTime));
rewardTrain(round(rewardTimes)) = 1;
rewardVect = rewardTrain(t_spikeStart:t_spikeEnd);

%Behavioral response time
behavRespTimes = respTime' + trialStartTimes;
behavRespTimes(isnan(behavRespTimes)) = [];

behavRespTrain = zeros(1,round(totalTime));
behavRespTrain(round(behavRespTimes)) = 1;
behavRespVect = behavRespTrain(t_spikeStart:t_spikeEnd);

%Whisking
if isempty(fname2) %if there is an analyzeable whisking video
    LedSigVect = nan(1,newTotalTime);
    whiskingSRVect = nan(1,newTotalTime);
    whiskingAngleVect = nan(1,newTotalTime);
    IRStartTimesVect = nan(1,newTotalTime);
else
    load(fname2)
    IRStartFrames_adj = zeros(1,length(whiskerPosition_varSR));
    IRStartFrames_adj(IRLedStartFrames) = 1;
    IRStartFrames_temp = IRStartFrames_adj(IRLedStartFrames(whiskStart):IRLedStartFrames(whiskEnd));
    
    whiskerPosition_smoothed = whiskerPosition_smoothed';
    
    if exist('framesChanged','var')
        for i = 1:size(framesChanged,1)
            n = framesChanged(i,1);
            s = framesChanged(i,2);
            LedSig = insertFrames(LedSig,IRLedStartFrames,n,s);
            whiskerPosition_varSR = insertFrames(whiskerPosition_varSR,IRLedStartFrames,n,s);
            whiskerPosition_median = insertFrames(whiskerPosition_median,IRLedStartFrames,n,s);
            whiskerPosition_smoothed = insertFrames(whiskerPosition_smoothed,IRLedStartFrames,n,s);
            
        end
    end
    
    LedSig_adj = abs(LedSig(IRLedStartFrames(whiskStart):IRLedStartFrames(whiskEnd)));
    whiskingSR = whiskerPosition_varSR(IRLedStartFrames(whiskStart):IRLedStartFrames(whiskEnd));
    whiskingAngle = whiskerPosition_median(IRLedStartFrames(whiskStart):IRLedStartFrames(whiskEnd));
    whiskingSmoothed = whiskerPosition_smoothed(IRLedStartFrames(whiskStart):IRLedStartFrames(whiskEnd));
    
    LedSigVect = createInterpVector(LedSig_adj,newTotalTime);
    whiskingSRVect = createInterpVector(whiskingSR,newTotalTime);
    whiskingAngleVect = createInterpVector(whiskingAngle,newTotalTime);
    whiskingSmoothVect = createInterpVector(whiskingSmoothed,newTotalTime);
    IRStartTimesVect = createInterpVector(IRStartFrames_temp,newTotalTime);    
end

if length(IRStartTimesVect) ~= length(trialStartVect)
    warning('vectors not correctly aligned')
end
binSize = 100;
[CCdata,lags] = computeCC(IRStartTimesVect,trialStartVect,-1000,binSize);
if max(CCdata) < 0.7
    warning(['Problem aligning whisking and spiking at bin size of ',num2str(binSize),'ms'])
    whiskingSRVect = nan(1,newTotalTime);
    whiskingAngleVect = nan(1,newTotalTime);
else
    disp(['Whisking and spiking are correctly aligned at bin size of ',num2str(binSize),'ms'])
end
subplot(2,1,1)
hold on
plot(IRStartTimesVect)
%plot(LedSigVect,'g')
plot(trialStartVect,'r')
subplot(2,1,2)
hold on
plot(lags*binSize,CCdata)
axis tight

%Trial & resp time information
trialType = trialType(spikeStart:spikeEnd);
respTime = respTime(spikeStart:spikeEnd);

if exist('sessionData.mat','file') == 0
    save('sessionData.mat','newTotalTime','trialType','respTime','IRStartTimesVect','LedSigVect','trialStartVect','whiskingSRVect','whiskingAngleVect',...
        'lickVect','rewardVect','behavRespVect','contactBottomStdVect','contactTopStdVect','contactBottomTimesVect','contactTopTimesVect')
else
    save('sessionData.mat','newTotalTime','trialType','respTime','IRStartTimesVect','LedSigVect','trialStartVect','whiskingSRVect','whiskingAngleVect',...
        'lickVect','rewardVect','behavRespVect','contactBottomStdVect','contactTopStdVect','contactBottomTimesVect','contactTopTimesVect','-append')
end

if nargin > 2
    clear IRStartFrames_adj IRStartFrames_temp IRStartFrames LedSig whiskStart whiskEnd framesChanged
    
    load(fname3)
    load('sessionData.mat')
    IRStartFrames_adj = zeros(1,length(pupilDiameterFilt));
    IRStartFrames_adj(IRLedStartFrames) = 1;
    IRStartFrames_temp = IRStartFrames_adj(IRLedStartFrames(whiskStart):IRLedStartFrames(whiskEnd));
    
    if exist('framesChanged','var')
        for i = 1:size(framesChanged,1)
            n = framesChanged(i,1);
            s = framesChanged(i,2);
            LedSig = insertFrames(LedSig,IRLedStartFrames,n,s);
            %eyeLumFilt = insertFrames(eyeLumFilt,IRLedStartFrames,n,s);
            %pupilSizeFilt = insertFrames(pupilSizeFilt,IRLedStartFrames,n,s);
            pupilDiameterFilt = insertFrames(pupilDiameterFilt,IRLedStartFrames,n,s);
        end
    end
    
    LedSig_adj = abs(LedSig(IRLedStartFrames(whiskStart):IRLedStartFrames(whiskEnd)));
    %eyeLum = (eyeLumFilt(IRLedStartFrames(whiskStart):IRLedStartFrames(whiskEnd)));
    %pupil = pupilSizeFilt(IRLedStartFrames(whiskStart):IRLedStartFrames(whiskEnd));
    pDiam = pupilDiameterFilt(IRLedStartFrames(whiskStart):IRLedStartFrames(whiskEnd));
    %pDiam = nan(1,length(pupilSizeFilt(IRLedStartFrames(whiskStart):IRLedStartFrames(whiskEnd))));
    
    eye_IRStartTimesVect = createInterpVector(IRStartFrames_temp,newTotalTime);
    eye_LedSigVect = createInterpVector(LedSig_adj,newTotalTime);
    %eyeLumVect = createInterpVector(eyeLum,newTotalTime);
    %pupilSizeVect = createInterpVector(pupil,newTotalTime);
    pupilDiamVect = createInterpVector(pDiam,newTotalTime);
    
    [CCdata_eye,lags] = computeCC(eye_IRStartTimesVect,trialStartVect,-1000,binSize);
    if max(CCdata) < 0.7
        warning(['Problem aligning pupil and spiking at bin size of ',num2str(binSize),'ms'])
        %pupilSizeVect = nan(1,newTotalTime);
        %eyeLumVect = nan(1,newTotalTime);
        pupilDiamVect = nan(1,newTotalTime);
    else
        disp(['Pupil and spiking are correctly aligned at bin size of ',num2str(binSize),'ms'])
    end
    subplot(2,1,1)
    plot(eye_IRStartTimesVect,'g')
    subplot(2,1,2)
    plot(lags*binSize,CCdata_eye,'g')
    
    disp('Saving mat file...')
    
else
    eye_LedSigVect = nan(1,length(whiskingSRVect));
    eye_IRStartTimesVect = nan(1,length(whiskingSRVect));
    %eyeLumVect = nan(1,length(whiskingSRVect));
    %pupilSizeVect = nan(1,length(whiskingSRVect));
    pupilDiamVect = nan(1,length(whiskingSRVect));
end

% save('sessionData.mat','whiskingSmoothVect','eye_LedSigVect','pupilDiamVect','eye_IRStartTimesVect','-append')
% %'eyeLumVect','pupilSizeVect'

end