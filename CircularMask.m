function [mask, pixels] = CircularMask(sizeXY, centerXY, diameter)
% Returns a circular mask with the specified diameter at the specified
% center position. The mask value is 1 while the rest is 0.
% Optionally, also returns the number of pixels making up the mask.

[xx,yy] = meshgrid(1:sizeXY(1),1:sizeXY(2));
mask = double(hypot(xx - centerXY(1), yy - centerXY(2)) <= (diameter/2));
pixels = sum(sum(mask));
%figure; imagesc(mask);
end
