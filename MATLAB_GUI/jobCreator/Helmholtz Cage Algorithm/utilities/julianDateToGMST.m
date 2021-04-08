function gmst = julianDateToGMST(julianDate)
%JULIANDATETOGMST converts the Julian date to the Greenwich mean sidereal
%time.
%
% Input:
% - julianDate: The interval of time measured in days from the epoch
%               January 1, 4713 B.C.E. 12:00
%
% Output:
% - gmst:       Greenwich mean sidereal time [rad]
%
%#codegen

% Compute the number of Julian centuries elapsed from the epoch J2000.0
ut1 = (julianDate - 2451545)/36525;

% Compute the Greenwich mean sidereal time in seconds
gmst = 67310.54841 ...
    + ( 876600*3600 + 8640184.812866 )*ut1 ...
    + 0.093104*ut1^2 ...
    - 6.2e-6*ut1^3;
gmst = mod( gmst, 86400 );

% Convert Greenwich mean sidereal time from seconds to radians
gmst = gmst/60/60/24*2*pi;

end
