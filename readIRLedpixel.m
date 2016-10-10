
function signal = readIRLedpixel(position,filename)
% L=figure;
%Loading all the necessary files
if isequal(filename(end-3:end),'.mat')
    vidfile = sprintf('%s',filename(1:end-4),'.mp4');
else
    vidfile = sprintf('%s',filename,'.mp4');
end
disp('Loading video file...')
vidobj = VideoReader(vidfile); %Load the video file
n = vidobj.NumberOfFrames;
signal = zeros(1,n);

whiskMov = zeros(vidobj.Height,vidobj.Width,3,'uint8');

percDone = 0;
disp('Getting IR LED pixel value...')
disp(sprintf('%s',num2str(percDone),'% done...'))
for i = 1:n
    percDone = floor(100*(i/n));
    percDoneLast = floor(100*((i-1)/n));
    if isequal(percDone,percDoneLast) == 0
        disp(sprintf('%s',num2str(percDone),'% done...'))
    end
    
    whiskMov = read(vidobj,i);
    signal(i) = whiskMov(position(2),position(1),1);
    
%    figure(L)
%    image(whiskMov)
%     hold on
%     if signal(i)<5
%         c = 'g';
%     else
%         c = 'r';
%     end
%     plot(position(1),position(2),['.' c]) %plot reverses y compared with image
%     drawnow limitrate
%     hold off
end

IRledSignal = signal;

figure
plot(IRledSignal)

if isequal(filename(end-3:end),'.mat')
    f = filename;
else
    f = [filename '.mat'];
end

if exist(f,'file')
    save(f,'IRledSignal','-append')
else
    save(f,'IRledSignal')
end

end