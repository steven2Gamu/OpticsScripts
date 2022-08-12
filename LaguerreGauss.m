function [E, normalisationFactor] = LaguerreGauss(sizeXY, pixelSize, w0, l, p, normalise)
%LAGUERREGAUSS Returns the complex field (E) for an LG beam.
%
%   sizeXY : The size of the returned matrix [col,row]
%   pixelSize : The size of each pixel (be be [x y] size too) [m]
%   w0 : The beam wasit (radius) of the required beam
%   l : Radial index (OAM)
%   p : Azimuthal index
%   normalise : whether to normalsie the amplitude of the field to [0,1].
%   In this case, the normalisation factor is returned.
%
%   Example:  LaguerreGauss([512 512], 10e-6, 1e-3, 1, 0, true)


if nargin < 6
    normalise = false;
    normalisationFactor = 1;
end

if length(pixelSize) == 3
    rotation = pixelSize(3);
else
    rotation = 0;
end

[r, phi] = PhysicalMeshGridPol(sizeXY, pixelSize, rotation);

%r = single(r);
%phi = single(phi);
%p = single(p);
%l = single(l);

RhoSquareOverWSquare = r.^2 ./ w0.^2; %optimisation since we always use the squares

%we don't use the built in MATLAB laguerreL as this is faster
%factorials replaced by gamma(n+1) for speed

La = Laguerre(p, abs(l), 2*RhoSquareOverWSquare);
Clg = sqrt((2*gamma(p+1)) ./ (pi * gamma(abs(l)+p+1)));
E = Clg .* (sqrt(2)*sqrt(RhoSquareOverWSquare)).^abs(l) .* exp(-RhoSquareOverWSquare) .* La .* exp(-1i*l*phi);

if normalise
    E = E ./ max(max(abs(E)));
    
    [x,y] = pol2cart(phi,r);
    x = x(1,:);
    y = y(:,1)';
    normalisationFactor = trapz(y, trapz(x, E .* conj(E)));
    warning('Need to double check normalisationFactor calculation!');
end

end

