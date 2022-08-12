%% Author: Steven Makoni 1935885 version 1.1
% This code works for the experimental setup and to impose the lateral
% displacement and tilt

%% Setup the camera
% Execute ‘imaqregister’ to find the list of currently registered adaptors
imaqregister

%% Unregister existing spinnaker adaptors.
imaqregister("C:\Users\SteveM\AppData\Roaming\MathWorks\MATLAB Add-Ons\Toolboxes\FLIR Spinnaker support by Image Acquisition Toolbox\FLIR Spinnaker support by Image Acquisition Toolbox\R2021a\mwspinnakerimaq.dll", "unregister");

%% For MATLAB R2019b, register the DLL file available in the R2019b folder.
imaqregister("C:\Users\SteveM\AppData\Roaming\MathWorks\MATLAB Add-Ons\Toolboxes\FLIR Spinnaker support by Image Acquisition Toolbox\FLIR Spinnaker support by Image Acquisition Toolbox\R2021a\mwspinnakerimaq.dll")

%% Reload the adaptor libraries registered with the toolbox for the adaptor to appear.
imaqreset

% Create a video input object.
vid = videoinput('mwspinnakerimaq', 1, 'Mono8');

%% Paramaters for the camera
vid.FramesPerTrigger = 1;
vid_src = getselectedsource(vid);
vid_src.ExposureTime = 100; % Max 200

% % Region of interest
x_offset = 174; %Adjustable
y_offset = 380; %Adjustable
x_length = 200;
y_length = 200;
vid.ROIPosition = [x_offset y_offset x_length y_length];

% Preview vid to see if the position is correct
preview(vid)

%% General Parameters

% Mode stuff:
ell = -4;
w_0 = 0.35e-3; %m
% w_0 = 1e-3; %m
wavelength = 632.8e-9;

w_1  =  0.35e-3;% .25e-3; %m Decomp beam

% Grating stuff:
gratingNumber = 115;
gratingAngle = 45;
complexAmplitude = "gabor";

% SLM stuff:
pixels = [720 1050]; %[horiz vert]

pixelShiftX =  0.1*w_0/ 10e-6;
% pixelShiftX =  0*w_0/ 10e-6;
pixelSize1 = [10e-6 10e-6 0 pixelShiftX pixelShiftX] %m [pixelSizeX pixelSizeY rotation lateralShiftPixelsX lateralShiftPixelsY]
pixelSize2 = [10e-6 10e-6 0 0 0];
pixelSize = 10e-6;

%% Modal Decomp Configuration
frameWidth = x_length ;
frameHeight = y_length ;
sizeOfImage = [frameWidth, frameHeight];

modeCreationNum = 1;
modeDetectionNum = 1;
lMax = 5; %Maximum shift to [-5,5] to become [0,10]
vidFrames =  zeros(frameWidth,frameHeight,modeCreationNum, modeDetectionNum);

% Decomposition Detection Cell
cameraPixelSize = 3.45*10^-6;
focalLength = 20e-2;
diameter = 720*pixelSize;
minDiameter = wavelength*focalLength/diameter;
minDiameterInPixels =  minDiameter/cameraPixelSize;
% numSamplePixels = 3;

dataFileName = "G:\My Drive\2022 Wits Masters\Results\Experiments\July-August Deadline\Data\Set3";
mkdir(dataFileName);

pngFileName = dataFileName + "\Pictures\PNG";
mkdir(pngFileName);

%% Determine the Centre Position
for l1 = 0:10:50
%     for l2 = -5:1:5
% l1 = 0;
% l2 = 0;
pixelShiftX =  11*0.1*w_0/ 10e-6;
% pixelShiftX =  0*w_0/ 10e-6;
pixelSize1 = [10e-6 10e-6 0 l1 0];

mode = LaguerreGauss(pixels, pixelSize1, w_0, 0, 0, false);
% ComplexFigure(mode);
ModeCreationHologram = AddBlazedGrating(mode , pixelSize2, gratingNumber, gratingAngle, complexAmplitude);

modeDeco = LaguerreGauss(pixels, pixelSize2, w_1, 0, 0, false);
modeDetectionHologram = AddBlazedGrating(modeDeco, pixelSize2, gratingNumber, gratingAngle, complexAmplitude);
hologram = [modeDetectionHologram ModeCreationHologram];

ShowImageSantec(hologram,2,633);
pause(1)
%     end
% 
start(vid);
data = getdata(vid);

% Save image
pngFileNameFinal = pngFileName + "\l_" + l1 ;
mkdir(pngFileNameFinal);
file_name = "\ModalDecom_l_" + l2 + ".bmp";
pngFileNameFinal = fullfile(pngFileNameFinal, file_name);
imwrite(mat2gray(data), pngFileNameFinal);

% Save matrix
% vidFrames(:,:,lcreation + lMax + 1, ldecomp + lMax + 1) = data;%%
% [Centre] = findOAMCenter( vid, 1);


[x, y] = Cmass(data)

end
