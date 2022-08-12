function [X, Y] = PhysicalMeshGrid(sizeXY, pixelSizeXY, rotation, lateralShiftXY)
%PHYSICALMESHGRID Returns a MeshGrid with X and Y scaled accordingly, with
% zero at the center.
%   sizeXY : The size of the returned matrix ("pixels") [col,row]
%   pixelSizeXY : [sizeX sizeY] or sizeX. The size of each pixel along X
%   and Y (or both if only one value is provided).
%
%   Example: [xx,yy] = PhysicalMeshGrid([128 128],1);figure;imagesc(xx);figure;imagesc(yy);
%   Example: [xx,yy] = PhysicalMeshGrid([128 128],[1 2]);figure;imagesc(xx);figure;imagesc(yy); %see it's stretched

% Optimisation: This function stores it's last returned value, so that if
% it is asked for again it is not recalculated.

if nargin < 3
    rotation = 0;
end

if nargin < 4
    lateralShiftXY = [0 0];
end

if size(pixelSizeXY,2) == 1
    % only a number is provided
    pixelSizeXY = [pixelSizeXY pixelSizeXY];
end

% Is there to fix a problem
pixelSizeXY = [pixelSizeXY(1) pixelSizeXY(2)];

persistent prevXY
persistent prevSizeXY
persistent prevX
persistent prevY
persistent prevRotation
persistent preVLateralShiftXY

if ~isempty(prevXY)
    if prevXY == sizeXY
        if prevSizeXY == pixelSizeXY
            if prevRotation == rotation
                if preVLateralShiftXY == lateralShiftXY
                    X = prevX;
                    Y = prevY;
                    return;
                end
            end
        end
    end
end

lateralshiftX = lateralShiftXY(1);
lateralshiftY = lateralShiftXY(2);

x = pixelSizeXY(1) .* (-sizeXY(1)/2 + lateralshiftX :(sizeXY(1)/2-1) +lateralshiftX );
y = pixelSizeXY(2) .* (-sizeXY(2)/2 +lateralshiftY :(sizeXY(2)/2-1)+ lateralshiftY );

[X,Y] = meshgrid(x,y);


if rotation ~= 0
    XY = [X(:) Y(:)];                                     % Create Matrix Of Vectors
    R=[cosd(rotation) -sind(rotation); sind(rotation) cosd(rotation)]; %CREATE THE MATRIX
    rotXY=XY*R'; %MULTIPLY VECTORS BY THE ROT MATRIX
    Xqr = reshape(rotXY(:,1), size(X,1), []);
    Yqr = reshape(rotXY(:,2), size(Y,1), []);
end

% if max(abs(lateralShiftXY)) ~= 0
% %     %SHIFTING
%      X = Xqr+lateralShiftXY(1); %not working
%      Y = Yqr+lateralShiftXY(2);
% end

prevXY = sizeXY;
prevSizeXY = pixelSizeXY;
prevX = X;
prevY = Y;
prevRotation = rotation;
preVLateralShiftXY = lateralShiftXY;

end

