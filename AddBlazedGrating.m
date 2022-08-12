function [ phaseOnlyHologram ] = AddBlazedGrating( E, pixelSize, gratingNumber, gratingAngle, complexAmplitude, actualWavelength, refWavelength )
%ADDGRATING Adds a grating to the provided hologram and outputs it as a
% phase-only matrix of doubles on [0,1] representing [0,2pi].
%   Refs: DOI 10.1364/OE.24.006249 and 10.1364/JOSAA.24.003500
%
%   E                   : The complex field to add a grating to.
%   pixelSize           : The dimentions of the pixels [m] or [x_m y_m]. See
%                         PhysicalMeshGrid.
%   gratingNumber       : The number of gratings
%   gratingAngle        : The angle of the grating [degrees]
%   complexAmplitude    : Whether to use complex amplitude modulation.
%                         'naive': naive but good efficiency
%                         'gabor': better naive (best for intensity)
%                         'arrizon': best for fidelity
%                         'arrizonblazed': arrizon with a blazed grating
%                         'davis': don't bother...
%                         'bolduc': don't bother...
%                         'none' (default) phase only
%
%   Example: gmat = AddBlazedGrating(mat,50,0,false); imagesc(gmat);

if nargin < 6
    actualWavelength = 632.8e-9; %HeNe
end

if nargin < 7
    refWavelength = 632.8e-9;
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

[X,Y] = PhysicalMeshGrid([size(E,2) size(E,1)], pixelSize);

pixelSize = [pixelSize(1) pixelSize(2)];

sZ = size(E) .* pixelSize;

% Find Gx and Gy - number of gratings filling the screen
Gx = (refWavelength/actualWavelength)*(gratingNumber*cos((pi/180)*gratingAngle)/(sZ(1)));
Gy = (refWavelength/actualWavelength)*(gratingNumber*sin((pi/180)*gratingAngle)/(sZ(2)));

% Find Gx and Gy - if gratingNum given in number of gratings per mm
% Gx = (refWavelength/actualWavelength)*(gratingNum*cos((pi/180)*gratingAngle)*10e-3);
% Gy = (refWavelength/actualWavelength)*(gratingNum*sin((pi/180)*gratingAngle)*10e-3);

% Determine the angle and make sure it is between 0 and 2pi
H = angle(E) + 2*pi*(Gx.*X + Gy.*Y);
hologramAngle = mod(H,2*pi);

amplitude = abs(E)/max(max(abs(E))); % y is [0,1] 

% Complex amplitude modulation
if strcmp(complexAmplitude, 'none')
   
    phaseOnlyHologram = hologramAngle;
    
elseif strcmp(complexAmplitude, 'naive')
    % Naive method - Amplitude*Phase
    
    phaseOnlyHologram = amplitude.*hologramAngle;
    
elseif strcmp(complexAmplitude, 'gabor')
    % Gabor method - arg(N*Edes + Ein)
    % Edes = Amplitude*e^(i*phase)
    % Ein = 1*e^(i*phase)
    
    AmpandPhase = amplitude.*exp(1i*hologramAngle)+1;
    phaseOnlyHologram = angle(AmpandPhase);
    
elseif strcmp(complexAmplitude, 'davis')
    % f(A)*phase
    % f(A) = 1 - (1/pi) * sinc^(-1)(A)
    
    % Load the sinc lookup table
    InvSinc = load('InveSinc.mat');
    
    % Use the table to calculate values for inverse sinc
    modAmplitude = interp1(InvSinc.xdata,InvSinc.ydata,amplitude,'pchip');
    
    % now solve for modified Amplitude
    newAmplitude = 1 - (1/pi)*modAmplitude;
    phaseOnlyHologram = newAmplitude.*hologramAngle;
    
elseif strcmp(complexAmplitude, 'bolduc')
    % M*(phase-pi*M)
    % M = 1 + (1/pi) * sinc^(-1)(A)
    
    % Load the sinc lookup table
    InvSinc = load('InveSinc.mat');
    
    % Use the table to calculate values for inverse sinc
    modAmplitude = interp1(InvSinc.xdata,InvSinc.ydata,amplitude,'pchip');
    
    % now solve for modified Amplitude
    M = 1 + (1/pi)*modAmplitude;
    phaseOnlyHologram = M.*(hologramAngle - pi*M);
    
elseif strcmp(complexAmplitude, 'arrizon')
    % May need to change ShowImage to include this method and the
    % decreased phase shift
    
    % f(A)*sin(phase)
    % f(A) = J_1^-1{Amplitude]
    
    % This is still confusing me :(
    H = angle(E) + 1.17*pi*(Gx.*X + Gy.*Y); % Reduced angle
    hologramAngle = (mod(H,2*pi));
    
    % Load the bessel lookup table
    InvBessel = load('InveBessel.mat');
    
    % Use the table to calculate values for inverse bessel
    modAmplitude = interp1(InvBessel.xdata,InvBessel.ydata,0.5817*amplitude,'nearest');
    
    % now solve for modified Amplitude
    phaseOnlyHologram = modAmplitude.*sin(hologramAngle);
end

% Normalise so that [0,2pi] represents [0,1]
phaseOnlyHologram = (phaseOnlyHologram-min(min(phaseOnlyHologram)))/(max(max(phaseOnlyHologram))-min(min(phaseOnlyHologram)));
phaseOnlyHologram = phaseOnlyHologram * 2* pi;

if strcmp(complexAmplitude, 'arrizon')
  %  phaseOnlyHologram = phaseOnlyHologram .* (2*pi/1.17);
end

end

