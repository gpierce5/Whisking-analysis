function var = checkTrace_b(fx,fy,tx,ty,xThresh1,yThresh1,xThresh2,yThresh2,minLength,...
    faceEdgeX,faceEdgeY,minFollicleDistance,faceAngle,whiskAngle)

wlength = [];

var = 1;

%Checks angle of object relative to face, to rule out objects that are
%oriented at the wrong angle (like lick spout)
% if whiskAngle < 30
%     var = 0;
% end
% %Checks that at least 2/3 of the traced object is within the chosen
% %quadrant for whiskers.
% if (sum(xp < xThresh2) + sum(xp > xThresh1)) >= (length(xp)/2)
%     var = 0;
% elseif (sum(yp > yThresh2) + sum(yp < yThresh1)) >= length(yp)/2
%     var = 0;
% end

%Checks if follicle point is within ROI
if (fx > xThresh1) || (fy < yThresh1)
    var = 0;
end

wlength = sqrt((tx - fx)^2 + (ty - fy)^2);
%Sets a minimum length that object has to exceed to be considered a whisker
if wlength <= minLength
    var = 0;
end

%Sets a threshold such that the 'follicle' of the traced object has to be x
%distance from the face edge
if minFollicleDistance > 20
    var = 0;
end

if min(abs(fy - faceEdgeY)) > 40
    %var = 0;
end
%Throws out objects that are exactly horizontal - most likely artificial
%background lines from having gain turned up high
% yslope = mean(diff(yp));
% 
% if abs(yslope) < 0.1
%     var = 0;
% end

% if yp(end) > (faceEdgeY(end) + 10)
%     var = 0;
% end

%Plot the traced objects for the current frame
% if isequal(var,0)
%     plot([fx tx],[fy ty],'-r','MarkerSize',20) %Rejected whisker objects
% else
%     plot([fx tx],[fy ty],'-g','MarkerSize',20) %Rejected whisker objects
%     plot([fx tx],[fy ty],'.b','MarkerSize',20) %Rejected whisker objects
% end
end