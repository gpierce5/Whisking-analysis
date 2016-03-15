function var = checkTrace(fx,fy,tx,ty,xThresh1,yThresh1,xThresh2,yThresh2,minLength,...
    faceEdgeX,faceEdgeY,minFollicleDistance,faceAngle,whiskAngle, verbose)
%checkTrace 
%   formerly checkTrace_b



wlength = [];

var = 1;

%Checks angle of object relative to face, to rule out objects that are
%oriented at the wrong angle (like lick spout)
if whiskAngle + faceAngle > 360
    if verbose==1
    warning('A whisker might be too far protracted!')
    end
end
if whiskAngle < 30
    var = 0;
    if verbose==1
    warning(['A whisker is at a suspiciously retracted angle! whiskAngle = ' num2str(whiskAngle)]')
    end
end
% %Checks that at least 2/3 of the traced object is within the chosen
% %quadrant for whiskers.
% if (sum(xp < xThresh2) + sum(xp > xThresh1)) >= (length(xp)/2)
%     var = 0;
% elseif (sum(yp > yThresh2) + sum(yp < yThresh1)) >= length(yp)/2
%     var = 0;
% end

%Checks if follicle point is within ROI
if (fx < xThresh2) || (fx > xThresh1) || (fy < yThresh1) || (fy > yThresh2) %these are different than Amanda's
    var = 0;
    if verbose==1
    warning('A whisker exited the whisker threshold!')
    end
end

wlength = sqrt((tx - fx)^2 + (ty - fy)^2);
%Sets a minimum length that object has to exceed to be considered a whisker
if wlength <= minLength
    var = 0;
    if verbose==1
    warning(['A whisker was too short! length = ' num2str(wlength)])
    end
end

%Sets a threshold such that the 'follicle' of the traced object has to be x
%distance from the face edge
if minFollicleDistance > 50 %20
    if verbose==1
    warning(['A whisker is too far from the face! min follicle distance = ' num2str(minFollicleDistance)])
    end
    if wlength > minFollicleDistance
        warning(['Oh good, the whisker is long enough to count. length = ' num2str(wlength)])
    else
        var = 0;
    end
    
end

%Thow out objects where the follicle is below the line of the face
%define parts of the line equation
x1=faceEdgeX(1);
y1=faceEdgeY(1);
x2 = faceEdgeX(end);
y2 = faceEdgeY(end);
slope = (y2-y1)/(x2-x1);
b = y1 - (slope*x1);
%if the point is below the line of the face, discard => this would be
%different for a vertical face
if fy > (slope*fx + b)
    var = 0;
    warning('Follicle is below the line of the cheek!')
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