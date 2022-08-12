%% Author: Steven Makoni 1935885
%% Setup the camera
% Execute ‘imaqregister’ to find the list of currently registered adaptors
% imaqregister
%
% % Unregister existing spinnaker adaptors.
% imaqregister("C:\Users\SteveM\AppData\Roaming\MathWorks\MATLAB Add-Ons\Toolboxes\FLIR Spinnaker support by Image Acquisition Toolbox\FLIR Spinnaker support by Image Acquisition Toolbox\R2021a\mwspinnakerimaq.dll", "unregister");
%
% % For MATLAB R2019b, register the DLL file available in the R2019b folder.
% imaqregister("C:\Users\SteveM\AppData\Roaming\MathWorks\MATLAB Add-Ons\Toolboxes\FLIR Spinnaker support by Image Acquisition Toolbox\FLIR Spinnaker support by Image Acquisition Toolbox\R2021a\mwspinnakerimaq.dll")
%
% % Reload the adaptor libraries registered with the toolbox for the adaptor to appear.
% imaqreset
%
% % Create a video input object.
% vid = videoinput('mwspinnakerimaq', 1, 'Mono8');
%
% % Paramaters for the camera
% vid.FramesPerTrigger = 1;
% vid_src = getselectedsource(vid);
% % vid_src.ExposureTime = 100;
%
% % Region of interest
% x_offset = 183;%191;% Change this!!!
% y_offset = 118 ;%41;
% x_length = 200;
% y_length = 200;
% vid.ROIPosition = [x_offset y_offset x_length y_length];
%
% % Preview vid to see if it is correct
% preview(vid)

% [x

%% General Parameters

% Mode stuff:
ell = 3;
p = 0;
w_0 = .3e-3;%.35e-3; %m


% Grating stuff:
gratingNumber = 500;
gratingAngle = 0;
complexAmplitude = "gabor";

% SLM stuff:
pixels = [4 6]; %[horiz vert]
pixelSize = [10e-6 10e-6]; %m

%% The magic happens here...

% mode = LaguerreGauss(pixels, pixelSize, w_0, ell, p, false) + LaguerreGauss(pixels, pixelSize, w_0, -ell, p, false);
mode = LaguerreGauss(pixels, pixelSize, w_0, ell, p, false);
ComplexFigure(mode);
%%
% for gratingNumber =  250:1:750

grating = AddBlazedGrating(mode, pixelSize, gratingNumber, gratingAngle, complexAmplitude);
%%
ShowImageSantec(grating,1,633);
pause(0.01)
% end