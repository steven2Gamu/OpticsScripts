function [ points ] = findOAMCenter( vid, nPoints )
%FINDOAMCENTER Takes a snapshot and lets the user click in the center.
%   If nPoints (optional, default = 1) is specified then several points can
%   be selected.
%   The result is a 2 x NPOINTS matrix; each
%   row is [X Y] for one point.

img = getsnapshot(vid);
if (max(max(img))) > 255
    img = img / 16;
end

%%Find the centroid to suggest the center
centroid = regionprops(imbinarize(img), 'centroid');
[m, mi] = max(img(:));
[maxRow maxCol]=ind2sub(size(img),mi);

maxRowCol = [maxRow maxCol]

centroidRow = centroid(1).Centroid(2);
centroidCol = centroid(1).Centroid(1);

centroidRowCol = [centroidRow centroidCol]

ShowImage(img, 0, parula(256));

k = 0;

hold on;           % and keep it there while we plot

plot(centroid(1).Centroid(1),centroid(1).Centroid(2),'ro');
plot(maxCol(1), maxRow(1), 'bo');

%Legend
plot(10, 10, 'bo');
text(12,9,' Maximum Point')
plot(10, 20, 'ro');
text(12,20,' Centroid Point')

if nargin >= 2
    points = zeros(2, nPoints);
    while 1
        [xi, yi, but] = ginput(1);      % get a point
        if ~isequal(but, 1)             % stop if not button 1
            break
        end
        
        k = k + 1;
        points(k,1) = xi;
        points(k,2) = yi;
        
        plot(xi, yi, 'go');         % first point on its own
        
        if isequal(k, nPoints)
            break
        end
    end
    
    if k < size(points)
        points = points(1:k, :);
    end
    
    points = round(points);
end

hold off;
end

