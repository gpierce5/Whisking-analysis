
function whiskAngle = calcWhiskAngle(x1,y1,x2,y2,faceAngle)

ang = abs(rad2deg(atan((x2 - x1)/(y2 - y1))));
whiskAngle = ang - faceAngle;

end
 
% x1 = faceEdgeX(1);
% y1 = faceEdgeY(1);
% x2 = faceEdgeX(end);
% y2 = faceEdgeY(end);
% 
% angFace = rad2deg(atan((x2 - x1)/(y2 - y1)));
% 
% angWhisk - angFace