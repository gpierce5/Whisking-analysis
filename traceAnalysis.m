function traceAnalysis(nfile, vidfile,plotFig) %Use filename + .mat extension

filename = [nfile '.mat'];

%Loading all the necessary files
% vidfile = sprintf('%s',filename(1:end-4),'.mp4');
disp('Loading video file...')
vidobj = VideoReader(vidfile); %Load the video file

[pathstr, vidname, ext] = fileparts(vidfile);
measurefile = [vidname ext];
disp('Loading measurements file...')
measurements = LoadMeasurements(measurefile);

%defines the area in the video where the whiskers are and the line of the
%mouse's cheek
if exist(filename,'file') ~= 2 %Create a mat file if doesn't already exist and run the 'setup' analysis
    analyzeWhiskersSetup(filename,vidobj);
end
disp('Loading mat file...')
load(filename)

frame = zeros(1,size(measurements,1));
for i = 1:size(measurements,1)
    frame(i) = measurements(i).fid;
end

minLength = 50;
%whiskerFrames(1) = struct('cdata',zeros(vidHeight,vidWidth,'uint8'),...
%    'colormap',[]);

whiskMov = struct('cdata',zeros(vidHeight,vidWidth,'uint8'),...
    'colormap',[]);

IRledSignal = zeros(3,nFrames);

z = 1;
%plotFig = 'y';

if isequal(plotFig,'y')
    h = figure();
    set(0,'CurrentFigure',h)
end

percDone = 0;
disp(sprintf('%s',num2str(percDone),'% done...'))

%%%%%%%%% Analyze whisker tracing information by frame %%%%%%%
for i = 1:nFrames
    
    percDone = floor(100*(i/nFrames));
    percDoneLast = floor(100*((i-1)/nFrames));
    if isequal(percDone,percDoneLast) == 0
        disp(sprintf('%s',num2str(percDone),'% done...'))
    end
    whiskMov.cdata = read(vidobj,i);
    
    temp = whiskMov.cdata(IRledLocation(2),IRledLocation(1),:);
    IRledSignal(:,i) = reshape(temp,3,1);
    
    if isequal(plotFig,'y')
        %Plot the current frame including our whisker area and LED location
        figure(h)
        image(whiskMov.cdata)
        hold on
        title(sprintf('%s','Frame ',num2str(i-1)))
        line([xThresh1 xThresh2],[yThresh1 yThresh1])
        line([xThresh1 xThresh1],[yThresh1 yThresh2])
        line([xThresh2 xThresh2],[yThresh1 yThresh2])
        line([xThresh1 xThresh2],[yThresh2 yThresh2])
        plot(faceEdgeX,faceEdgeY,'-y')
        plot(IRledLocation(1),IRledLocation(2),'.y','MarkerSize',20)
    end
    indList = find(frame == (i-1)); %Find indices in 'whiskers' that correspond to current frame
    
    whiskAngle = [];
    
    %Going through each object in this frame for analysis
    for j = 1:length(indList)
        
        
        
        t = indList(j);
        
        %Find the 'follicle' point, which is the closest point on the
        %whisker to the face edge
        follicleX = measurements(t).follicle_x;
        follicleY = measurements(t).follicle_y;
        whiskerTipX = measurements(t).tip_x;
        whiskerTipY = measurements(t).tip_y;
        minFollicleDistance = findFollicle(follicleX,follicleY,faceEdgeX,faceEdgeY);
        whiskerCurve = measurements(t).curvature;
        %faceAngle gives angle relative to y, +90 makes it relative to X
        %when mouse is at bottom, facing left, measurements(t).angle is the
        %angle on the back of the whisker between the whisker and the
        %horizontal plane
        %If running amanda's code as is, whiskAngle is the angle from under
        %the face edge, counterclockwise to the back of the whisker
        relFaceAngle = 90-faceAngle; %this gives angle from nose up to x
        %relFaceAngle is from the nose counterclockwise to horizontal
        %whiskAngle =  faceAngle + abs(measurements(t).angle) + 90;
        whiskAngle = abs(measurements(t).angle); %this way, whiskAngle should start small and protract to get big, but won't go above 360.
        
        verbose = 1; %1 for printing all warnings, 0 for hiding them
        
        %Check each traced object and determine if potential whisker or
        %not; returns '0' if not whisker and '1' if it is
        isWhisker(j) = checkTrace(follicleX,follicleY,whiskerTipX,whiskerTipY,xThresh1,yThresh1,xThresh2,yThresh2,...
            minLength,faceEdgeX,faceEdgeY,minFollicleDistance,relFaceAngle,whiskAngle, verbose);
        
        %         whiskers(t).x,whiskers(t).y,xThresh1,yThresh1,xThresh2,yThresh2,...
        %             minLength,faceEdgeX,faceEdgeY,minFollicleDistance,faceAngle,whiskers(t).whiskAngle);
        %
        %noWhiskerInd(z) = [];tr
        
        %for debugging
        if i>9  %if i= problem frame +1, then will go whisker by whisker
            plot(follicleX,follicleY,'cp')
            p=3;
        end
        
        
        if isequal(isWhisker(j),0)
            if isequal(plotFig,'y')
                plot([follicleX whiskerTipX],[follicleY whiskerTipY],'-r','MarkerSize',20) %Rejected whisker objects
            end
            
            measurements(t).fid = NaN;
            measurements(t).follicle_x = [];
            measurements(t).follicle_y = [];
            measurements(t).tip_x = [];
            measurements(t).tip_y = [];
            
            measurements(t).angle = NaN;
            whiskerAngles(j) = NaN;
            noWhiskerInd(z) = t; %Saving a list of the objects that are not whiskers, in order to delete later
            z = z+1;
            
        else
            if isequal(plotFig,'y')
                plot([follicleX whiskerTipX],[follicleY whiskerTipY],'-g','MarkerSize',20)
                plot([follicleX whiskerTipX],[follicleY whiskerTipY],'.b','MarkerSize',20)
            end
            %The whisker tip is the first point in the traced object. This
            %usually works fine, but may need to be refined in some cases
            
            %whiskerTipX = whiskers(t).x(1);
            %whiskerTipY = whiskers(t).y(1);
            
            %plot(follicleX,follicleY,'.b','MarkerSize',20)
            %plot(whiskerTipX,whiskerTipY,'.b','MarkerSize',20)
            
            %measurements(t).follicle_x = [follicleX follicleY];
            %whiskers(t).tip = [whiskerTipX whiskerTipY];
            
            %whiskers(t).whiskAngle = calcWhiskAngle(follicleX,follicleY,whiskerTipX,whiskerTipY,faceAngle);
            whiskerAngles(j) = whiskAngle;
        end
        
        
        %this is for debugging indivudual whiskers
        
        
        
        
    end %end loop through whiskers in this frame
    
    %Save info for all objects in current frame
    temp = find(isnan(whiskerAngles));
    whiskerAngles(temp) = [];
    whiskerPosition(i) = mean(whiskerAngles);
    whiskerPosition_median(i) = median(whiskerAngles);
    whiskerCurvature(i) = mean(whiskerCurve);
    
    if isequal(plotFig,'y')
        figure(h)
        %hold on
        %plot(i,whiskerPosition(i),'.-b')
        %axis([0 nFrames 0 1])
        %axis 'auto y'
        title(sprintf('%s','Frame ',num2str(i-1),': Median whisker angle = ',num2str(whiskerPosition_median(i)),' degrees'))
        %whiskerFrames(i) = getframe;
        %input('continue?')
        hold off
        %clf
        waitforbuttonpress %computer won't plot fast enough unless you wait for it
    end
    
    
    
end %end loop through all frames

whiskersAll = measurements(1:t);
whiskersAll(noWhiskerInd) = [];

disp('Saving .mat file...')
save(filename,'whiskersAll','frame','noWhiskerInd','whiskerPosition','whiskerCurvature','whiskerPosition_median','IRledSignal','-append','-v7.3')

end


