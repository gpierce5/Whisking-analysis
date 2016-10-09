

fname = '160722-02';
fname2 = '160722_vid-1';

%Loading all the necessary files
% load([fname '.mat'])
filename = [fname2 '.mat'];

vidfile = sprintf('%s',filename(1:end-4),'.mp4');
disp('Loading video file...')
vidobj = VideoReader(vidfile); %Load the video file

load(filename)
disp('Loading mat file...')
whiskMov(1) = struct('cdata',zeros(vidHeight,vidWidth,'uint8'),'colormap',[]);

%xvect2 = (df/1000)*binSize:(df/1000)*binSize:(df*nFrames)/1000;
count = 1;
% frame = zeros(1,size(whiskersAll,1));
% for i = 1:size(whiskersAll,1)
%     frame(i) = whiskersAll(i).fid;
% end
frame = whiskersAll.fID;

%Setting up the figure subplots and axis for the video
h = figure('Color',[1 1 1],'Position',[300 0 900 800]);
set(0,'CurrentFigure',h)
subplot(4,3,[1:6])
axis square
axis off

subplot(4,3,7:9)
axis([0 10 min(whiskerPosition_median) max(whiskerPosition_median)])

subplot(4,3,10:12)
axis([0 10 0 max(whiskerPosition_varSR)]) %changed from var to std dev

% timeDisplay = 5000; %amount of time to display at once
timeDisplay = 750; %in frames

%Creating a vector of zeros and ones for the time of the LED flash; length
%of vector is the number of video frames
LEDvect = zeros(1,length(whiskerPosition_median));
l = IRLedStartFrames;
LEDvect(IRLedStartFrames) = 1;

% contactManualData = zeros(1,length(whiskerPosition_median));

%Cutting off all data at first LED light flash (whiskStart) & last LED
%light flash (whiskEnd)
wStart = IRLedStartFrames(whiskStart);
wEnd = IRLedStartFrames(whiskEnd);
whiskerPosition_median = whiskerPosition_median(wStart:wEnd);
whiskerPosition_varSR = whiskerPosition_varSR(wStart:wEnd);
LEDvect = LEDvect(wStart:wEnd);
% contactManualData = zeros(1,length(wStart:wEnd));%contactTimesManual2(wStart:wEnd);

% %Creating a vector of zeros and ones for the time of the trial start pulse;
% %length is total time of video (so is in ms)
% trialStartVect = zeros(1,round(totalTime));
% trialStartVect(round(trialStartTimes)) = 1;
% 
% %Cutting off all ntrode data at first trial start time (spikeStart) & last
% %trial startTime (spikeEnd)
% cStart = trialStartTimes(spikeStart);
% cEnd = trialStartTimes(spikeEnd);
% trialStartVect = trialStartVect(cStart:cEnd);
% contactBottomTrain = zeros(1,length(cStart:cEnd));%contactTopTrain(cStart:cEnd);%contactBottomTrain(cStart:cEnd);
% contactBottomFiltNew = zeros(1,length(cStart:cEnd));%contactTopFiltNew(cStart/dt:cEnd/dt);%contactBottomFiltNew(cStart/dt:cEnd/dt);
% 
% xvect2 = 1:length(trialStartVect); %ms time vector
% xvect3 = dt:dt:length(contactBottomFiltNew)*dt; %point time vector

% %Interpolate the whisking & manual contact data to also be in 1ms time bins
% whiskVectData = zeros(length(trialStartVect),1); 
% LEDvectData = zeros(length(trialStartVect),1);

% dw = length(trialStartVect)/length(LEDvect); %this is the time between frames we're using (not df or df_adj)
% 
% xWhisk_current = dw:dw:length(trialStartVect); %Current time step vector (in steps of dw)
% xWhisk_new = 1:1:length(trialStartVect); %New time step vector (in steps of 1 ms)

%whisk x vector for video that only includes whisking, no contact or ntrode
%trialstarts
xWhisk = df:df:length(whiskerPosition_median)*df; %should be in ms?


% whiskVectData = interp1(xWhisk_current,whiskerPosition_varSR,xWhisk_new); %this is the step that does the interpolation
% LEDvectData = interp1(xWhisk_current,LEDvect,xWhisk_new);
% contactManualVect = interp1(xWhisk_current,contactManualData,xWhisk_new);
% 
% %this is just a simple step to keep the contactManualVect binary (0 or 1; 
% %the interpolation created some intermediate values)
% x = find(contactManualVect <0.9); 
% contactManualvect(x) = 0;

%Grabs the correct video frame that corresponds with the current whisking/ntrode data point
frameList = IRLedStartFrames(whiskStart):IRLedStartFrames(end);
% frameList_new = round(frameList(1):(1/dw):IRLedStartFrames(end)); 
% 
%Parameters for the movie we're making here
vidFR = 50; %frames per second
df_new = 1000/vidFR;
% totalTime_new = length(trialStartVect);
totalTime_new = length(whiskerPosition_median);
vidLength = totalTime_new/1000;
nFrames_new = round(vidFR*vidLength);
indFrames_new = round((nFrames/nFrames_new).*(1:nFrames_new));

%these setting create a video that's the most versatile (i.e. can be opened on windows or mac, works in ppt, etc)
writerObj = VideoWriter('whiskerVideo.avi','Motion JPEG AVI'); 
%writerObj = VideoWriter('whiskerVideo.mp4','MPEG-4');

speedSlowed = 10;
writerObj.FrameRate = vidFR/speedSlowed; %controls how fast the video is played back
open(writerObj);

%frame number that's the middle of the display
cFrame = vidFR*(timeDisplay/2)/1000;
startframe = 94600;
endframe = 132100;
b= find(whiskersAll.fID==startframe,1,'first');
stp = find(whiskersAll.fID==endframe+1,1,'first');
for i = startframe:endframe %from middle frame whatever to whatever else
% for i = 12000:df_new:totalTime_new - timeDisplay
%for i = timeDisplay + 1:df_new:totalTime_new - timeDisplay
    
     cTime = i;%round(i/2);
    sTime = cTime - timeDisplay/2;
    eTime = cTime + timeDisplay/2;

%     whiskMov.cdata = read(vidobj,frameList(cTime));
%     cFrame = cFrame + 1;
whiskMov.cdata = read(vidobj,cTime);

    hold off
    
    %Plot the video image for current frame
    subplot(8,3,[1:12])
    image(whiskMov.cdata)
    axis square
    set(gca,'Visible','on')
    title(['Frame number: ',num2str(cTime)])

%     indList = find(frame == (frameList_new(cTime))); %Find indices in 'whiskers' that correspond to current frame
    f = i;
    first = b;
    while whiskersAll.fID(b) == f && (b < stp)
        b = b+1;
    end
    last = b-1;
    indList = first:last;

    %Going through each object in this frame for analysis
    for j = 1:length(indList)
        t = indList(j);
        line([whiskersAll.follicle_x(t) whiskersAll.tip_x(t)],[whiskersAll.follicle_y(t) whiskersAll.tip_y(t)],'LineStyle','-','Color','g') %Confirmed whisker objects
        %plot(whiskersAll(t).x,whiskersAll(t).y,'-g') %Confirmed whisker objects
        %plot(whiskersAll(t).follicle(1),whiskersAll(t).follicle(2),'.b')
        %plot(whiskersAll(t).tip(1),whiskersAll(t).tip(2),'.b')
    end
    
    hold off
    
    %Plotting the median whisker angle per frame
    subplot(8,3,13:18)
    %Adding the LED sync signal to this plot
%     plot(xvect2(sTime:eTime),(max(whiskVectData)*LEDvectData(sTime:eTime)) + min(whiskVectData),'-k','LineWidth',1)
%     hold on
%     plot(xvect2(sTime:eTime),whiskVectData(sTime:eTime),'-g','LineWidth',2)
%     line([xvect2(cTime) xvect2(cTime)],[min(whiskVectData) max(whiskVectData)],'Color','k','LineWidth',2)
%     axis([xvect2(sTime) xvect2(eTime) min(whiskVectData) max(whiskVectData)]);
    
    plot((sTime:eTime),whiskerPosition_varSR(sTime:eTime),'-b','LineWidth',2)
    hold on
    line([(cTime) (cTime)],[min(whiskerPosition_varSR) max(whiskerPosition_varSR)],'Color','k','LineWidth',1,'LineStyle','--')
    axis([(sTime) (eTime) min(whiskerPosition_varSR) max(whiskerPosition_varSR)]);
%     set(gca,'XTickLabel',{' '})
    title('std of whisker angle')
    
    hold off
    %plotting the LED start times
    subplot(8,3,22:24)
    plot((sTime:eTime),LEDvect(sTime:eTime),'Color','k','LineWidth',2)
    hold on
    line([(cTime) (cTime)],[0 1.5],'Color','k','LineWidth',1,'LineStyle','--')
    axis([(sTime) (eTime) 0 1.5]);
    title('trial starts')
    hold off
%     
%     %Plotting the contact data & times  
%     subplot(7,3,13:15)   
%     plot(xvect2(sTime:eTime),contactManualVect(sTime:eTime),'c','LineWidth',2)
%     line([xvect2(cTime) xvect2(cTime)],[min(contactBottomTrain) max(contactBottomTrain)],'Color','k','LineWidth',2)
%     axis([xvect2(sTime) xvect2(eTime) 0 1])
%     set(gca,'XTickLabel',{' '})
%     axis off
%     hold off
    
%     %Plotting the contact data & times    
%     subplot(7,3,16:18)   
%     plot(xvect2(sTime:eTime),trialStartVect(sTime:eTime),'k')
%     hold on
%     plot(xvect2(sTime:eTime),contactBottomTrain(sTime:eTime),'m','LineWidth',2)
%     line([xvect2(cTime) xvect2(cTime)],[min(contactBottomTrain) max(contactBottomTrain)],'Color','k','LineWidth',2)
%     axis([xvect2(sTime) xvect2(eTime) 0 1])
%     set(gca,'XTickLabel',{' '})
%     axis off
%     hold off
    
% %     subplot(7,3,19:21)
% %     cPoint = i/dt;%(i/2)/dt;
% %     sPoint = cPoint - (timeDisplay/2)/dt;
% %     ePoint = cPoint + (timeDisplay/2)/dt;
% %     plot(xvect3(sPoint:ePoint),contactBottomFiltNew(sPoint:ePoint),'b','LineWidth',1)
% %     line([xvect3(cPoint) xvect3(cPoint)],[min(contactBottomFiltNew) max(contactBottomFiltNew)],'Color','k','LineWidth',2)
% %     axis([xvect3(sPoint) xvect3(ePoint) min(contactBottomFiltNew) max(contactBottomFiltNew)])
% %     xlabel('Time (ms)')
% %     hold off
% %     ylabel('voltage (mV)')
% %     title('contact detector signal')
% %     
hold off
    whiskerFrames(i) = getframe(h);
    writeVideo(writerObj,whiskerFrames(i));
    
end

close(writerObj)



