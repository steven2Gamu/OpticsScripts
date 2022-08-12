function ComplexFigure( complexMatrix, intensity, map, filename )
%COMPLEXFIGURE Displays a complex 2D matrix nicely.
% intensity : If true, displays intensity as well as amplitude.
% map : Default: parula(255)
% filename : If specified, also saves each subfigure as a .png file.

if nargin < 3
    map = parula(255);
end

if nargin < 2
    intensity = false;
end

if nargin < 4
    filename = '';
end

%figure;
hold on
if intensity == true
    subplot(1,3,1)
    imshow(abs(complexMatrix).^2,[min(min(abs(complexMatrix).^2)) max(max(abs(complexMatrix).^2))],'Border','tight','InitialMagnification','fit','colormap',map);
    title('Intensity')
    subplot(1,3,2)
    imshow(abs(complexMatrix),[min(min(abs(complexMatrix))) max(max(abs(complexMatrix)))],'Border','tight','InitialMagnification','fit','colormap',map);
    title('Amplitude')
    subplot(1,3,3)
    imshow(angle(complexMatrix),[min(min(angle(complexMatrix))) max(max(angle(complexMatrix)))],'Border','tight','InitialMagnification','fit','colormap',map);
    title('Phase (Mod 2\pi)')
    set(gcf,'color','w');
    if ~isempty(filename)
        imwrite(mat2gray(abs(complexMatrix).^2)*255,map,strcat(filename,'Intensity.png'));
        imwrite(mat2gray(abs(complexMatrix))*255,map,strcat(filename,'Amplitude.png'));
        imwrite(mat2gray(angle(complexMatrix))*255,map,strcat(filename,'Angle.png'));
    end
    
else
    subplot(1,2,1)
    imshow(abs(complexMatrix),[min(min(abs(complexMatrix))) max(max(abs(complexMatrix)))],'Border','tight','InitialMagnification','fit','colormap',map);
    title('Amplitude')
    subplot(1,2,2)
    imshow(angle(complexMatrix),[min(min(angle(complexMatrix))) max(max(angle(complexMatrix)))],'Border','tight','InitialMagnification','fit','colormap',map);
    title('Phase (Mod 2\pi)')
    set(gcf,'color','w');
    if ~isempty(filename)
        imwrite(mat2gray(abs(complexMatrix))*255,map,strcat(filename,'Amplitude.png'));
        imwrite(mat2gray(angle(complexMatrix))*255,map,strcat(filename,'Angle.png'));
    end
end
hold off
end

