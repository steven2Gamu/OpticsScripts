function [ img10bit, img8bit ] = ShowImageSantec( hologram, fs, wavelength )
%SHOWIMAGE Display the specified hologram on a Santec 10bit SLM or as a
%window. Returns the RGB image of what was displayed.
%   hologram:       A matrix to show / save as image with dimensions [rows cols] = [height width]. 
%                   Must be in actual desired phase for example [0,2pi].
%   fs:             The screen to show fullscreen on, if 0 then a window is used for
%                   both holograms, 1 is current monitor, >=2 are SLMs, -1
%                   doesn't display.
%   wavelength:     The wavelength (in nm) that is incident on the SLM. Default is
%                   632.8nm

if nargin < 2
  fs = 0; 
end

if nargin < 3
    wavelength = 635;
end

img8bit = uint8(hologram * 255);

% The SLM can do a 2pi phase shift at 1550nm. At 775nm it can do 4pi, etc.
% unless calibrated which is more accurate.

if wavelength == 0
    ratio = 1;
elseif wavelength == 520
    ratio = 1/0.02555; %measured
elseif wavelength == 635
    ratio = 1/0.01947; %measured
else
    ratio = (1023 / ((1550/wavelength)*2*pi));
end

% map to 10 bits on RGB according to SLM-100 datasheet:
holo = uint16(round(hologram .* ratio)); %[0,1023] 10 bits
holo(holo>1023) = 1023; %in case of rounding errors

%make it fit by padding to 1920x1080
holo = cat(2, holo, zeros(1050, 1920-1440));
holo = cat(1, holo, zeros(1080-1050, 1920));

blue = bitand(holo, bin2dec('0000001111'));
blue = uint8(bitshift(blue, 4));
green = bitand(holo, bin2dec('0001110000'));
green = uint8(bitshift(green, 1));
red = bitand(holo, bin2dec('1110000000'));
red = uint8(bitshift(red, -2));

img10bit = double(cat(3,red,green,blue)) ./ 255; %get back to [0, 1]


% if fs=-1 dont display anything
if fs == 0
    %figure; 
    subplot(1,2,1);
    imshow(img8bit,gray(256),'Border','tight','InitialMagnification','fit'); 
    title('8 bit raw')
    subplot(1,2,2);
    imshow(uint8(img10bit .* 255), parula(256),'Border','tight','InitialMagnification','fit'); 
    title(strcat('10 bit, mapped, \lambda=',num2str(wavelength),' nm'))
    set(gca,'dataAspectRatio',[1 1 1])
elseif fs > 0
    fullscreen(img10bit, fs);
end

end

