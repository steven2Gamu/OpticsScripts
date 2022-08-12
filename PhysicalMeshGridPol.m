function [rho, theta] = PhysicalMeshGridPol(sizeXY, pixelSizeXY, rotation)
%PHYSICALMESHGRID Returns a polar MeshGrid with rho and theta scaled accordingly, with
% zero at the center.
%   sizeXY : The size of the returned matrix ("pixels") [col,row]
%   pixelSizeXY : [sizeX sizeY] or sizeX. The size of each pixel along X
%   and Y (or both if only one value is provided).
%
%   Example: [r,t] = PhysicalMeshGridPol([128 128],1);figure;imagesc(r);figure;imagesc(t);
%   Example: [r,t] = PhysicalMeshGridPol([128 128],[1 2]);figure;imagesc(r);figure;imagesc(t); %see it's stretched

% Optimisation: This function stores it's last returned value, so that if
% it is asked for again it is not recalculated.

if size(pixelSizeXY,2) == 1
    % only a number is provided
    pixelSizeXY = [pixelSizeXY pixelSizeXY];
end


if nargin < 3
    rotation = 0;
end

if nargin > 3
    rotation = pixelSizeXY(3);
end

[X, Y] = PhysicalMeshGrid(sizeXY, [pixelSizeXY(1) pixelSizeXY(2)], rotation, [pixelSizeXY(4) pixelSizeXY(5)]);

[theta, rho] = cart2pol(X,Y);
end

