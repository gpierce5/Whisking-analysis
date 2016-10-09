function traceAnalysis(fname,plotFig) %Use filename
%adapted from Amanda's traceAnalysis, updated 10/2016
%Input arguments:
%Filename - enter the base filename (without the extension) for the whisker
%video. All variables will get saved in a .mat file with the same name

%plotFig - enter 'y' to plot the video output or 'n' to not plot it. It is
%helpful to plot the video at first to check your parameters, but the function
%will run 2-3 times faster if not plotting

if ~isequal(fname(end-3:end),'.mat')
    filename = [fname '.mat'];
end

%Create a mat file if doesn't already exist and run the 'setup' analysis
if ~exist(filename,'file')
    %Loading video file
    vidfile = sprintf('%s',filename(1:end-4),'.mp4');
    disp('Loading video file...')
    vidobj = VideoReader(vidfile);
    analyzeWhiskersSetup(filename,vidobj);
end

load(filename)

if isequal(plotFig,'y')
    if ~exist('vidobj','var')
        %Loading video file
        vidfile = sprintf('%s',filename(1:end-4),'.mp4');
        disp('Loading video file...')
        vidobj = VideoReader(vidfile); %Load the video file
    end
    h = figure;
    set(0,'CurrentFigure',h)
    whiskMov = struct('cdata',zeros(vidobj.Height,vidobj.Width,3,'uint8'),...
        'colormap',[]);
end
%

%Load measurements
if exist([fname '-measurements.mat'],'file')
    measurefile = [fname '-measurements.mat'];
    load(measurefile)
    disp(['loaded ' measurefile])
else
    measurefile = sprintf('%s',fname,'.measurements');
    disp('Loading measurements file...')
    disp(measurefile)
    tic
    M = LoadMeasurements(measurefile);
    toc
    % make matrices containing individual data features.
    for ii = 1: size(M,1)
        fID(ii) = M(ii).fid+1; %added 1 to index frame number
        wAngle(ii) = M(ii).angle;
        wLength(ii) = M(ii).length; %outputs the whisker angle at each frame i
        wCurv(ii) = M(ii).curvature;
        follicle_x(ii)= M(ii).follicle_x;
        follicle_y (ii)=M(ii).follicle_y;
        tip_x(ii) = M(ii).tip_x;
        tip_y(ii) = M(ii).tip_y;
    end
    disp ('loaded measurements file...');
    %make a table for ease of indexing
    measurements = table(fID', follicle_x', follicle_y', tip_x', tip_y', wCurv', wAngle', wLength',...
        'VariableNames',...
        {'fID', 'follicle_x', 'follicle_y', 'tip_x', 'tip_y', 'wCurv', 'wAngle', 'wLength'});
    disp('saving measurements info');
    save([fname '-measurements.mat'],'measurements')
    clear M
end

%load info from whisker mat file
disp('Loading mat file...')
load(filename)

z = 1;
b=1;
percDone = 0;
disp('Analyzing whisker objects...')
disp(sprintf('%s',num2str(percDone),'% done...'))

%%%%%%%%% Analyze whisker tracing information by frame %%%%%%%
whiskerPosition = zeros(1,nFrames);
whiskerPosition_median = zeros(1,nFrames);
whiskerCurvature = zeros(1,nFrames);

for i = 1:nFrames
    
    %Keeps track of how much farther to go
    percDone = floor(100*(i/nFrames));
    percDoneLast = floor(100*((i-1)/nFrames));
    if isequal(percDone,percDoneLast) == 0
        disp(sprintf('%s',num2str(percDone),'% done...'))
    end
    
    %Only if you want to plot the video & whisker output
    if isequal(plotFig,'y')
        %Plot the current frame
        whiskMov.cdata = read(vidobj,i);
        
        figure(h)
        image(whiskMov.cdata)
        hold on
        %title(sprintf('%s','Frame ',num2str(i-1)))
        line([xThresh1 xThresh2],[yThresh1 yThresh1])
        line([xThresh1 xThresh1],[yThresh1 yThresh2])
        line([xThresh2 xThresh2],[yThresh1 yThresh2])
        line([xThresh1 xThresh2],[yThresh2 yThresh2])
        plot(faceEdgeX,faceEdgeY,'-y')
        plot(IRledLocation(1),IRledLocation(2),'.y','MarkerSize',20)
        
    end
    
    %Get all traced objects in the current frame
    %frame = i-1; %amanda's videos start at zero
    frame = i;
    first = b;
    while measurements.fID(b) == frame && (b < height(measurements))
        b = b+1;
    end
    last = b-1;
    
    indList = first:last;%find(frame == (i-1)); %Find indices in 'measurements' that correspond to current frame
    
    whiskerAngles = zeros(1,length(indList));
    isWhisker = ones(1,length(indList));
    
    %Going through each object in this frame for analysis
    for j = 1:length(indList)
        t = indList(j);
        
        %Find the 'follicle' point, which is the closest point on the
        %whisker to the face edge
        follicleX = measurements.follicle_x(t);
        follicleY = measurements.follicle_y(t);
        whiskerTipX = measurements.tip_x(t);
        whiskerTipY = measurements.tip_y(t);
        minFollicleDistance = findFollicle(follicleX,follicleY,faceEdgeX,faceEdgeY);
        whiskerCurve = measurements.wCurv(t);
        whiskAngle =  faceAngle + abs(measurements.wAngle(t)) + 90;

        
        %Check each traced object and determine if potential whisker or
        %not; returns '0' if not whisker and '1' if it is
        isWhisker(j) = checkTrace(follicleX,follicleY,whiskerTipX,whiskerTipY,xThresh1,yThresh1,xThresh2,yThresh2,...
            faceEdgeX,faceEdgeY,minFollicleDistance,faceAngle,whiskAngle, faceside);
        
        %Rule out whisker objects if the angle is very different from
        %median of last frame
        if i > 1
            w = abs(whiskAngle - whiskerPosition_median(i-1));
            if w > 60
                isWhisker(j) = 0;
            end
        end
        
        %For any objects that are not whiskers
        if isequal(isWhisker(j),0)
            if isequal(plotFig,'y')
                plot([follicleX whiskerTipX],[follicleY whiskerTipY],'-r','MarkerSize',20) %Rejected whisker objects
            end
            
            whiskerAngles(j) = NaN;
            noWhiskerInd(z) = t; %Saving a list of the objects that are not whiskers, in order to delete at the end
            z = z+1;
            
        else
            %For objects that are whiskers
            if isequal(plotFig,'y')
                plot([follicleX whiskerTipX],[follicleY whiskerTipY],'-g','MarkerSize',20)
                plot([follicleX whiskerTipX],[follicleY whiskerTipY],'.b','MarkerSize',20)
            end
            whiskerAngles(j) = whiskAngle; %List of all whisker angles in the current frame
        end
        
    end
    
    %Save info for all objects in current frame
    %temp = find(isnan(whiskerAngles));
    %whiskerAngles(temp) = [];
    whiskerAngles(isnan(whiskerAngles)) = [];
    whiskerPosition(i) = mean(whiskerAngles);
    whiskerPosition_median(i) = median(whiskerAngles);
    whiskerCurvature(i) = mean(whiskerCurve);
    
    
    
    if isequal(plotFig,'y')
        drawnow limitrate
        %         title(['Frame: ' num2str(i) '  Med Ang: ' num2str(whiskerPosition_median(i))])
        figure(h)
        hold off
    end
    
    %     if ~isempty(input('continue? '))
    %         keyboard;
    %     end
end

%Saving only whiskers entries that were decided to be whiskers
whiskersAll = measurements(1:t,:);
whiskersAll(noWhiskerInd,:) = [];

disp('Saving .mat file...')
save(filename,'whiskersAll','frame','noWhiskerInd','whiskerPosition','whiskerCurvature','whiskerPosition_median','-append')
%Get pixel value for IR LED if not already saved
if ~exist('IRledSignal','var')
    disp('Getting IR LED signal...')
    readIRLedpixel(IRledLocation,filename);
end

% %Get smoothed median and variance measurements
% disp('Calculating median and variance across frames...')
% whiskerangle_bin(filename)

end


