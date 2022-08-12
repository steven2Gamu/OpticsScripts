function ShowImage( img, fs, map, filename )
%SHOWIMAGE Show the specified image in a window or fullscreen. Can also
%save the image to the specified path.
%   img : A matrix to show / save as image. 
%   fs : The screen to show fullscreen on, if 0 then a window is used. -1
%   does not show the image (useful for only saving).
%   map : The colourmap to use (default is gray).
%   filename : The path and filename (can be relative). If not specified
%   then the image is not saved. .png is automatically appended.


if (min(min(img)))
    warning(strcat('img has negative values: be careful! min(img(:)) = ', num2str(min(img(:)))));
end
if (max(max(img)) > 1)
    warning(strcat('max(img) > 1: be careful! max(img(:)) = ', num2str(max(img(:)))));
end

if nargin < 2
    fs = 0;
end

if nargin < 3
    map=gray(256);
end

if nargin == 4
    normImg = img - min(img(:));
    normImg = (normImg ./ max(normImg(:))) .* 255;
    imwrite(normImg, map, filename);
end

if fs == -1
    return;
end

if fs == 0
    figure; 
    imshow(img,[min(min(img)) max(max(img))],'colormap',map,'Border','tight','InitialMagnification','fit'); 
    set(gca,'dataAspectRatio',[1 1 1]);
elseif fs > 0
    %scale to [0,1]
    %img = img - min(img(:));
    %img = img ./ max(img(:));
    fullscreen(img, fs);
end

end

