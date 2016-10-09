%A Kinnischtzke
%filename = '150831_file-0.mat';
%filename = fname2;
load(filename)

%NOTE: YOU SAVED ANGLE VARIABLE AS WHISKERPOSITION, really it is the angle
%calculated by Amanda's program, it's possible it gets smaller as they
%protract if the mouse is facing down (hers face upwards)

binSize = 20; %number of frames per bin
i = 1;
a = 1;

while i <= length(whiskerPosition_median) - binSize
    whiskerPosition_binned(a) = nanmean(whiskerPosition(i:i+binSize-1)); %Amanda has no -1... is that better?
    whiskerPosition_median_binned(a) = nanmean(whiskerPosition_median(i:i+binSize-1));
    i = i + binSize;
    a = a+1;

end
   
whiskerPosition_var = zeros(size(whiskerPosition));
for i = 1:length(whiskerPosition_median) - binSize
    whiskerPosition_var(i) = nanvar(whiskerPosition_median(i:i+binSize));
end

whiskerPosition_varSR = sqrt(whiskerPosition_var);


save(filename,'whiskerPosition_median_binned','whiskerPosition_var','whiskerPosition_varSR','-append')
%save(filename,'whiskerPosition_median_binned','whiskerPosition_median_orig','whiskerPosition_median','whiskerPosition_var','whiskerPosition_varSR','-append')

figure()
hold on
ax1 = subplot(4,1,1)
plot(whiskerPosition_median,'-b')
axis tight
title('Median whisker angle per frame (deg)')

ax2 = subplot(4,1,2)
plot(whiskerCurvature,'-c')
axis tight
title('Whisker curvature per frame')

ax3 = subplot(4,1,3)
hold on
plot(whiskerPosition_var,'-m')
%ylabel('Mean whisker position per frame (deg)')
axis tight
title('variance of whisker angle')
ax4 = subplot(4,1,4)
hold on
plot(sqrt(whiskerPosition_var),'-g')
%ylabel('Mean whisker position per frame (deg)')
axis tight
title('sqrt(variance) of whisker angle')
linkaxes([ax1, ax2, ax3, ax4],'x')


figure()
hold on
subplot(3,1,1)
hist(whiskerPosition_median,50)
h = findobj(gca,'Type','patch');
set(h,'FaceColor','b','EdgeColor','w')
axis tight
title('histogram of median whisker angle')

subplot(3,1,1)
hist(whiskerPosition_median,50)
h = findobj(gca,'Type','patch');
set(h,'FaceColor','b','EdgeColor','w')
axis tight
title('histogram of median whisker angle')

subplot(3,1,2)
hist(whiskerPosition_var,50)
h = findobj(gca,'Type','patch');
set(h,'FaceColor','m','EdgeColor','w')
axis tight
title('histogram of variance of whisker angle')

subplot(3,1,3)
hist(sqrt(whiskerPosition_var),50)
h = findobj(gca,'Type','patch');
set(h,'FaceColor','g','EdgeColor','w')
axis tight
title('histogram of sqrt(variance) of whisker angle')


