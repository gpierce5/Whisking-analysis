function var = checkTrace(fx,fy,tx,ty,xThresh1,yThresh1,xThresh2,yThresh2,...
    faceEdgeX,faceEdgeY,minFollicleDistance,faceAngle,whiskAngle, faceside)
% adapted from Amanda's checkTrace_c
%INPUT:
% fx & fy: x and y positions for follicle point of traced object
% tx & ty: x and y positions for tip point of traced object
% xThresh1,yThresh1,xThresh2,yThresh2: ROI boundaries
% faceEdgeX & faceEdgeY: line for the edge of the face
% minFollicleDistance: distance from the follicle point on the object to closest point on the face
% faceAngle: angle of the mouse's face
% whiskAngle: angle of the traced object

%OUTPUT:
%var = set to 1 (is whisker object) or 0 (not whisker object). Default is
%set to 1, but value is changed to 0 if any of the following criteria are
%not true

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

%Determine which way the face is oriented

a = 'stop';
%Checks if follicle point is within ROI
if isequal(faceside,'right')
    if (fx > xThresh1) || (fy < yThresh1)
        var = 0;
    end
elseif isequal(faceside,'left')
    if (fx < xThresh2) || (fy < yThresh1) || (fx > xThresh1) || (fy > yThresh2)
        var = 0;
    end
elseif isequal(faceside,'top')
    if (fx < xThresh2) || (fy < yThresh1) || (fx > xThresh1) || (fy > yThresh2)
        var = 0;
    end
else
    warning('no parameters set for current face side')
end

%Sets a minimum length that object has to exceed to be considered a whisker
wlength = sqrt((tx - fx)^2 + (ty - fy)^2); %Length of current traced object
minLength = 50;

if abs(wlength) <= minLength
    var = 0;
end

%Sets a threshold such that the 'follicle' of the traced object has to be x
%distance from the face edge
follicleDistThresh = 70;
if minFollicleDistance > follicleDistThresh
    var = 0;
end

%Set a distance threshold just in the 'y' dimension. this is useful for
%ruling out little hairs on the body that are close to the face in the
%x-direction but far from the face in the y-direction
if isequal(faceside,'top')
    if min(abs(fx - faceEdgeX)) > 20
    var = 0;
    end
else
    if min(abs(fy - faceEdgeY)) > 50
    var = 0;
    end
end

%Follicle point has to be to the left of the face edge
dist = [];
minDist = [];
dist = [];
for j = 1:size(faceEdgeX,2)
    dist(j) = sqrt((faceEdgeX(j) - fx)^2 + (faceEdgeY(j) - fy)^2);
end

[a,b]=min(dist);
if fx > faceEdgeX(b) && fy > faceEdgeY(b)
    %var = 0;
end

if whiskAngle > 390
    var = 0;
    %warning('did you mean to cut out big angles?')
end


end