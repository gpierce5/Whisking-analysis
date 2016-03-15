
function [minFollicleDistance] = findFollicle(fx,fy,faceEdgeX,faceEdgeY)
%findFollicle  - finds the minimum distance between the follicle and the
%face
%formerly findFollicle_b
%Written by Amanda Kinnischtzke


dist = [];
minDist = [];
dist = [];
for j = 1:size(faceEdgeX,2)
    dist(j) = sqrt((faceEdgeX(j) - fx)^2 + (faceEdgeY(j) - fy)^2);
end

[a,b]=min(dist);
minFollicleDistance = a;
end