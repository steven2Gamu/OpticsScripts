function hologram = AddingBlazedGrating(mode,slmSize,gratingNum,gratingAngle,complexAmplitude,actualWavelength)
% Author: Alice Drozdov 
% Example: AddingBlazedGrating(mode,[1440 1050],100,0,"naive",633e-9) 
% mode - the LG mode
% slmSize - the resolution of the SLM [X Y]
% gratingNum - number of gratings that fill the screen at a wavelength of 633e-9
% gratingAngle  - the angle is not entirely correct - will have to add a shift
% complexAmplitude - what type of amplitude modulation to add
% actualWavelength- the wavelength of the laser that is currently being used in meters

refWavelength = 520.2e-9; 

if nargin < 6
   actualWavelength = 520.2e-9; 
end

% Determine what sort of complex amplitude modulation to use:
if nargin < 5 % phase only
    complexAmplitude = 'none';
else
    % What sort of grating?
    if isa(complexAmplitude, 'logical')
        if complexAmplitude == true %default arrizon
            complexAmplitude = 'naive';
        else % phase only
            complexAmplitude = 'none';
        end
    elseif isa(complexAmplitude, 'char')
        % check for validity
        if ~strcmp(complexAmplitude, 'none') || ...
            ~strcmp(complexAmplitude, 'naive') || ...
            ~strcmp(complexAmplitude, 'gabor') || ...
            ~strcmp(complexAmplitude, 'davis') || ...
            ~strcmp(complexAmplitude, 'bolduc') || ...
            ~strcmp(complexAmplitude, 'arrizon')
        
            error('complexAmplitude is not valid!');
        end
    end
end


% Make meshgrid
x = (-slmSize(1)/2:1:slmSize(1)/2-1);
y = (-1.3*(slmSize(2)/2-1:-1:-slmSize(2)/2));
[X,Y] = meshgrid(x,y);

% Find Gx and Gy - number of gratings filling the screen 
Gx = (refWavelength/actualWavelength)*(gratingNum*cos((pi/180)*gratingAngle)/(slmSize(1)));
Gy = (refWavelength/actualWavelength)*(gratingNum*sin((pi/180)*gratingAngle)/(slmSize(2)));

% Find Gx and Gy - if gratingNum given in number of gratings per mm
% Gx = (refWavelength/actualWavelength)*(gratingNum*cos((pi/180)*gratingAngle)*pixelSize);
% Gy = (refWavelength/actualWavelength)*(gratingNum*sin((pi/180)*gratingAngle)*pixelSize);

% Determine the angle and make sure it is between 0 and 2pi
H = angle(mode) + 2*pi*(Gx.*X + Gy.*Y);
hologramAngle = mod(H,2*pi);

% Complex amplitude modulation
if ~strcmp(complexAmplitude, 'none')
    % Amplitude should be between 0 and 1
    amplitude = abs(mode)/max(max(abs(mode))); % y is [0,1]
    
    if strcmp(complexAmplitude, 'naive')
        % Naive method - Amplitude*Phase
        
        hologram = amplitude.*hologramAngle;
        
    elseif strcmp(complexAmplitude, 'gabor')
        % Gabor method - arg(N*Edes + Ein)
        % Edes = Amplitude*e^(i*phase)
        % Ein = 1*e^(i*phase)
        
        AmpandPhase = amplitude.*exp(1i*hologramAngle)+1;
        hologram = angle(AmpandPhase);
        
    elseif strcmp(complexAmplitude, 'davis')
        % f(A)*phase
        % f(A) = 1 - (1/pi) * sinc^(-1)(A)
        
        % Load the sinc lookup table
        InvSinc = load('InveSinc.mat');
        
        % Use the table to calculate values for inverse sinc
        modAmplitude = interp1(InvSinc.xdata,InvSinc.ydata,amplitude,'pchip');
        
        % now solve for modified Amplitude
        newAmplitude = 1 - (1/pi)*modAmplitude;
        hologram = newAmplitude.*hologramAngle;
     
    elseif strcmp(complexAmplitude, 'bolduc')
        % M*(phase-pi*M)
        % M = 1 + (1/pi) * sinc^(-1)(A)
        
        % Load the sinc lookup table
        InvSinc = load('InveSinc.mat');

        % Use the table to calculate values for inverse sinc
        modAmplitude = interp1(InvSinc.xdata,InvSinc.ydata,amplitude,'pchip');

        % now solve for modified Amplitude
        M = 1 + (1/pi)*modAmplitude;
        hologram = M.*(hologramAngle - pi*M);
        
   elseif strcmp(complexAmplitude, 'arrizon')
       % May need to change ShowImage to include this method and the
       % decreased phase shift - remember that the phase range is reduced
       % to 1.17*pi
       
        % f(A)*sin(phase)
        % f(A) = J_1^-1{Amplitude]
        
        % This is still confusing me :(
        H = angle(mode) + 1.17*pi*(Gx.*X + Gy.*Y); % Reduced angle 
        hologramAngle = (mod(H,2*pi));

        % Load the bessel lookup table
        InvBessel = load('InveBessel.mat');

        % Use the table to calculate values for inverse bessel
        modAmplitude = interp1(InvBessel.xdata,InvBessel.ydata,0.5817*amplitude,'nearest');

        % now solve for modified Amplitude
        hologram = modAmplitude.*sin(hologramAngle);
    end
end

% Normalisation
hologram = (hologram-min(min(hologram)))/(max(max(hologram))-min(min(hologram)));

% Images
% figure;
% imagesc(hologram)
% colormap gray

% % Images
% fig = figure(1);
% set(fig,'Position',[1900 0 1440 1050],'MenuBar','none','ToolBar','none','resize','off');
% set(gca,'position',[0 0 1 1],'Visible','off')
% imagesc(hologram)
% colormap gray
% axis off;
end
