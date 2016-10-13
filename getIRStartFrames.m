
function [x1,dataFiltNew] = getIRStartFrames(data,df)
%Amanda, 10/2016

%Filter the data to remove any brief (~1 frame) flunctuations
cutoffFreq = [10 40];
cfreq = cutoffFreq/(1000/df);
[b,a] = butter(1,[cfreq],'bandpass');
dataFilt = filtfilt(b,a,data);

%Now transforming the data to further eliminate any noise
dataFiltNew = -(dataFilt./min(dataFilt));
dataFiltNew(dataFiltNew < 0.6) = 0;

figure
subplot(2,1,1)
hold on
plot(data - mean(data),'b')
plot(dataFilt,'r')

axis tight
subplot(2,1,2)
plot(dataFiltNew,'m')
axis tight

%Now get start times using the first derivative
d = diff(dataFiltNew);
diffThresh = 0.1;
x = findpeaks(d,diffThresh); %trying this out for the first time
x1 = x.loc+1;
x2 = find(diff(x1)< 300);
if isempty(x2) == 0
    x1(x2+1) = [];
end
figure
hold on
plot((data - mean(data))./min(data),'b')
plot(dataFiltNew,'m')
plot(d,'r')
plot(x1,dataFiltNew(x1),'.k','MarkerSize',20)

end