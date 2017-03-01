function [ areTheyEqual ] = compareVidFrames( vidname )
%compareVidFrames Compares a couple of the same frames from a video and
%its cropped counterpart (here called v2)
%   Use this to check if the cropped videos are matching the uncropped
%   videos. Video must be within the current directory.
%input:
%   vidname - the basename of the vidfile. ex: '170206_vid-2'

%load original video
origivid = VideoReader([vidname '.mp4']);
nframesO = origivid.NumberOfFrames;

%load cropped video
cropvid = VideoReader([vidname 'v2.mp4']);
nframesC = cropvid.NumberOfFrames;

origFramesEqualToCropFrames = isequal(nframesO,nframesC)
if origFramesEqualToCropFrames ~= 1
    nframes = min(nframesO,nframesC);
else
    nframes = nframesO;
end

%pick a random frame number
testframe1 = randi(nframes);

%plot original video at that frame
o = figure;
set(0,'CurrentFigure',o);
orig = struct('cdata',zeros(origivid.Height,origivid.Width,3,'uint8'),...
'colormap',[]);
orig.cdata = read(origivid,testframe1);
image(orig.cdata)
title(['original, frame ' num2str(testframe1)])

%plot cropped video
c = figure;
set(0,'CurrentFigure',c);
crop = struct('cdata',zeros(cropvid.Height,cropvid.Width,3,'uint8'),...
'colormap',[]);
crop.cdata = read(cropvid,testframe1);
image(crop.cdata)
title(['cropped, frame ' num2str(testframe1)])

%repeat
%pick a random frame number
testframe2 = randi(nframes);

%plot original video at that frame
o2 = figure;
set(0,'CurrentFigure',o2);
orig = struct('cdata',zeros(origivid.Height,origivid.Width,3,'uint8'),...
'colormap',[]);
orig.cdata = read(origivid,testframe2);
image(orig.cdata)
title(['original, frame ' num2str(testframe2)])

%plot cropped video
c2 = figure;
set(0,'CurrentFigure',c2);
crop = struct('cdata',zeros(cropvid.Height,cropvid.Width,3,'uint8'),...
'colormap',[]);
crop.cdata = read(cropvid,testframe2);
image(crop.cdata)
title(['cropped, frame ' num2str(testframe2)])

drawnow limitrate
areTheyEqual = input('Are the video frames the same? (0 or 1) ')

end

