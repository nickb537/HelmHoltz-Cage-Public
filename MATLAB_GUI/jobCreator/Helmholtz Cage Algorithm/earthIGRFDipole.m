function magFieldI = earthIGRFDipole(julianDate,posI)
%EARTHIGRFDIPOLE calculates the magnetic field at the given position and
%time based on a dipole model using the first degree coefficients of the
%IGRF model.
%
% Inputs:
% - julianDate: The interval of time measured in days from the epoch
%               January 1, 4713 B.C.E. 12:00
% - posI:       Position of the spacecraft in ECI coordinates
%
% Output:
% - magFieldI:  Magnetic field at the given position in ECI coordinates [T]
%
% References:
% - http://www.ngdc.noaa.gov/IAGA/vmod/igrf.html
% - Wertz, Spacecraft Attitude Determination and Control, 1978,
%   Appendix H, Magnetic Field Models, Dipole Model.
%
%#codegen

% Equatorial radius of the Earth adopted for the IGRF model (Wertz, p. 779)
a = 6371.2 * KILOMETERS;

% 11th Generation International Geomagnetic Reference Field
% First degree IGRF 2010 coefficients
g10 = -29496.5 * NANOTESLAS;
g11 = -1585.9 * NANOTESLAS;
h11 = 4945.1 * NANOTESLAS;

% Equation (H-18)
H0 = sqrt(g10^2+g11^2+h11^2);

% Coelevation of the dipole, Equation (H-19)
theta_m = acos(g10/H0);

% East longitude of the dipole, Equation (H-20)
phi_m = atan2(h11,g11);

% Calculate the Greenwich mean sidereal time
gmst = julianDateToGMST(julianDate);

% Calculate the right ascension of the dipole:
% Right ascension of the prime meridian + east longitude of the dipole.
% Note: gmst = alpha_G0 + (dalpha_G/dt)*t.
alpha_m = gmst + phi_m;

% Calculate the vector dipole, Equation (H-23)
mHat = [
    sin(theta_m)*cos(alpha_m)
    sin(theta_m)*sin(alpha_m)
    cos(theta_m)];

% Calculate the distance and unit vector from the Earth to the spacecraft
r = norm(posI);
rHat = posI/r;

% Calculate the magnetic field, Equation (H-22)
magFieldI = a^3*H0/r^3 * (3*dot(mHat,rHat)*rHat-mHat);

end
