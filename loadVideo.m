function [  ] = loadVideo( )
%loadVideo Loads a video file into Matlab's player 
%   Useful for scrolling through videos frame by frame

%load the video
[vidfile,vidpath]=uigetfile('D:\Data\*.mp4', 'Select a video file.');
%vidObj = VideoReader([vidpath vidfile]);
implay([vidpath vidfile])

end

