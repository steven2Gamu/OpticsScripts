%% Author: Steven Makoni 1935885
% This code works for the experimental setup and it is the go to place when
% the settings in the code are change.
%% Setup the camera
% Execute ‘imaqregister’ to find the list of currently registered adaptors
imaqregister

%% Unregister existing spinnaker adaptors.
imaqregister("C:\Users\SteveM\AppData\Roaming\MathWorks\MATLAB Add-Ons\Toolboxes\FLIR Spinnaker support by Image Acquisition Toolbox\FLIR Spinnaker support by Image Acquisition Toolbox\R2021a\mwspinnakerimaq.dll", "unregister");

%% For MATLAB R2019b, register the DLL file available in the R2019b folder.
imaqregister("C:\Users\SteveM\AppData\Roaming\MathWorks\MATLAB Add-Ons\Toolboxes\FLIR Spinnaker support by Image Acquisition Toolbox\FLIR Spinnaker support by Image Acquisition Toolbox\R2021a\mwspinnakerimaq.dll")

%% Reload the adaptor libraries registered with the toolbox for the adaptor to appear.
imaqreset

%% Create a video input object.
vid = videoinput('mwspinnakerimaq', 1, 'Mono8');

%% Paramaters for the camera
vid.FramesPerTrigger = 1;
vid_src = getselectedsource(vid);
vid_src.ExposureTime = 100; % Max 200

% % Region of interest
x_offset = 184; %Adjustable
y_offset = 380; %Adjustable
x_length = 200;
y_length = 200;
vid.ROIPosition = [x_offset y_offset x_length y_length];

% % Preview vid to see if it is correct
preview(vid)

%% Folders to Save Data
dataFileName = "G:\My Drive\2022 Wits Masters\Results\Experiments\July-August Deadline\Data\Set1";
mkdir(dataFileName);

pngFileName = dataFileName + "\Pictures\PNG";
mkdir(pngFileName);

datasetFileName = dataFileName + "\Pictures\Dataset";
mkdir(datasetFileName);

crosstalkPngFileName = dataFileName + "\Crosstalk\PNG";
mkdir(crosstalkPngFileName);

crosstalkDatasetFileName = dataFileName + "\Crosstalk\Dataset";
mkdir(crosstalkDatasetFileName);

%% General Parameters

% Mode stuff:
ell = -4;
w_0 = 0.35e-3; %m
%w_0 = 1e-3; %m
wavelength = 632.8e-9;

w_1  =  0.35e-3;% .25e-3; %m Decomp beam

% Grating stuff:
gratingNumber = 115;
gratingAngle = 45;
complexAmplitude = "gabor";

% SLM stuff:
pixels = [720 1050]; %[horiz vert]


pixelSize1 = [10e-6 10e-6 0 0 0]; %m
pixelSize2 = [10e-6 10e-6 0 0 0];
pixelSize = 10e-6;
% pixelSize1 = [10e-6 10e-6]; %m

%% Modal Decomp Configuration
frameWidth = x_length ;
frameHeight = y_length ;
sizeOfImage = [frameWidth, frameHeight];

matrixSize = 121; % No. of frames to be generated
modeCreationNum = 11;
modeDetectionNum = 11;
lMax = 5; %Maximum shift to [-5,5] to become [0,10]
vidFrames =  zeros(frameWidth,frameHeight,modeCreationNum, modeDetectionNum);

norm_I = zeros(modeDetectionNum, modeCreationNum);
norm_cp = zeros(modeDetectionNum, modeCreationNum);
norm_power = zeros(modeDetectionNum, modeCreationNum);

% Decomposition Detection Cell
cameraPixelSize = 3.45*10^-6;
focalLength = 20e-2;
diameter = 720*pixelSize;
minDiameter = wavelength*focalLength/diameter;
minDiameterInPixels =  minDiameter/cameraPixelSize;

% numSamplePixels = 3;

%% Determine the Centre Position
mode = LaguerreGauss(pixels, pixelSize1, w_0, 5, 0, false);
ModeCreationHologram = AddBlazedGrating(mode , pixelSize1, gratingNumber, gratingAngle, complexAmplitude);

modeDeco = LaguerreGauss(pixels, pixelSize1, w_1, 5, 0, false);
modeDetectionHologram = AddBlazedGrating(modeDeco, pixelSize1, gratingNumber, gratingAngle, complexAmplitude);

hologram = [modeDetectionHologram ModeCreationHologram];

ShowImageSantec(hologram,2,633);
%% 
[Centre] = findOAMCenter( vid, 1);

%% Mode creation

for lcreation = -5:1:5
    
    ell = lcreation;
    mode = LaguerreGauss(pixels, pixelSize1, w_0, ell, 0, false);
    ModeCreationHologram = AddBlazedGrating(mode , pixelSize1, gratingNumber, gratingAngle, complexAmplitude);
    
    %% Mode Decomposition
    
    for ldecomp = -5:1:5
        
        el_l = ldecomp;
        modeDeco = LaguerreGauss(pixels, pixelSize1, w_1, el_l, 0, false);
        modeDetectionHologram = AddBlazedGrating(modeDeco, pixelSize1, gratingNumber, gratingAngle, complexAmplitude);
        CorrectionF = max(max(abs(modeDetectionHologram)));
        
        hologram = [modeDetectionHologram ModeCreationHologram];
        
        ShowImageSantec(hologram,2,633);
        pause(0.2)
        
        %% Image Processing
        % Take a picture and find the centre pixel value using the picture
        start(vid);
        data = getdata(vid);
        
        % Save image
        pngFileNameFinal = pngFileName + "\l_" + lcreation ;
        mkdir(pngFileNameFinal);
        file_name = "\ModalDecom_l_" + ldecomp + ".png";
        pngFileNameFinal = fullfile(pngFileNameFinal, file_name);
        imwrite(mat2gray(data), pngFileNameFinal);
        % Save matrix
        vidFrames(:,:,lcreation + lMax + 1, ldecomp + lMax + 1) = data;
        
        % Create the mask to calculate the modal decom
        CentreMask = CircularMask(sizeOfImage, Centre, ceil(minDiameterInPixels));
        I = sum(sum(double(data).*CentreMask))/sum(sum(CentreMask));
        norm_I(ldecomp + lMax + 1,lcreation + lMax +1) = I.*(1/(CorrectionF'.^2)); % Coefficient correction
        
    end
    norm_cp(:,lcreation + lMax +1) = norm_I(:,lcreation + lMax +1)./max(max(norm_I(:,lcreation + lMax + 1)));
    allSumNorm = sum(sum(norm_I(:,lcreation + lMax +1)));
    norm_power(:,lcreation + lMax +1) = norm_I(:,lcreation + lMax +1)./sum(sum(norm_I(:,lcreation + lMax + 1)));
    
end

%% Load Crosstalk Data

crosstalk = norm_power;
crosstalkDatasetFileName = crosstalkDatasetFileName + "\CrosstalkData.mat";
save(crosstalkDatasetFileName,'crosstalk');

% Create crosstalk matrix image
clims = [0 1];
x = [-5 -4 -3 -2 -1 0 1 2 3 4 5];
y = [-5 -4 -3 -2 -1 0 1 2 3 4 5];
figure;
imagesc(x,y,norm_power,clims)
set(gca,'XTickLabel',-5:1:5)
colorbar
crosstalkPngFileName = crosstalkPngFileName + "\CrosstalkMatrix.png";
saveas(gcf,crosstalkPngFileName);

% Save image data
DataType = "frameWidth,frameHeight,modeCreationNum, modeDetectionNum";
datasetFileName = datasetFileName + "\ImageDataset.mat";
