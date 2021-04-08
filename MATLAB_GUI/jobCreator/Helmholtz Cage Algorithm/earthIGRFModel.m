function magFieldI = earthIGRFModel(julianDate,posI)
%EARTHIGRFDIPOLE calculates the magnetic field at the given position and
%time based on a dipole model using the IGRF model.
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

% Calculate the right ascension (alpha) and declination (delta)
alpha = atan2(posI(2),posI(1));
delta = atan2(posI(3),sqrt(posI(1)^2+posI(2)^2));

% Calculate the Greenwich mean sidereal time
gmst = julianDateToGMST(julianDate);

% Calculate the geocentric distance (r), coelevation (theta), and east
% longitude from Greenwich (phi)
r = sqrt(posI(1)^2+posI(2)^2+posI(3)^2);
theta = pi/2 - delta;
phi = alpha - gmst; % Equation (H-15)

% Equatorial radius of the Earth adopted for the IGRF model (Wertz, p. 779)
a = 6371.2 * KILOMETERS;

persistent g h S
if isempty(g) || isempty(h) || isempty(S)
    
    % Load the IGRF coefficients
    [g,h] = igrfCoeffs;
    
    % Calculate the S factors
    S = calculateS;
    
    % Convert coefficients from Schmidt to Gauss normalization,
    % Equation (H-6)
    g = S.*g;
    h = S.*h;
    
end

% Calculate the Gauss normalized Legendre functions
[P,dPdtheta] = legendreFunctions(theta);

% Calculate the magnetic field in the radial (r), coelevation (theta), and
% azimuthal (phi) directions, Equations (H-12)
% Note: The indices are incremented by 1 to avoid 0 subscript indices
Br     = 0;
Btheta = 0;
Bphi   = 0;
for n = 1:13
    partBr     = 0;
    partBtheta = 0;
    partBphi   = 0;
    for m = 0:n
        partBr = partBr + ...
            (g(n+1,m+1)*cos(m*phi)+h(n+1,m+1)*sin(m*phi)) ...
            * P(n+1,m+1);
        partBtheta = partBtheta + ...
            (g(n+1,m+1)*cos(m*phi)+h(n+1,m+1)*sin(m*phi)) ...
            * dPdtheta(n+1,m+1);
        partBphi = partBphi + ...
            m*(-g(n+1,m+1)*sin(m*phi)+h(n+1,m+1)*cos(m*phi)) ...
            * P(n+1,m+1);
    end
    Br     = Br     + (a/r)^(n+2)*(n+1)*partBr;
    Btheta = Btheta + (a/r)^(n+2)*partBtheta;
    Bphi   = Bphi   + (a/r)^(n+2)*partBphi;
end
Btheta = -Btheta;
Bphi   = -1/sin(theta)*Bphi;

% Convert the magnetic field to ECI coordinates, Equations (H-14)
% Also, convert units from nT to T
magFieldI = NANOTESLAS*[
    (Br*cos(delta)+Btheta*sin(delta))*cos(alpha) - Bphi*sin(alpha)
    (Br*cos(delta)+Btheta*sin(delta))*sin(alpha) + Bphi*cos(alpha)
     Br*sin(delta)-Btheta*cos(delta)];

end



function S = calculateS

% Calculate S, Equations (H-7)
% Note: The indices are incremented by 1 to avoid 0 subscript indices
S = zeros(14);
for n = 0:13
    for m = 0:n
        if n==0 && m==0
            S(n+1,m+1) = 1;
        elseif m==0
            S(n+1,m+1) = S(n,1)*(2*n-1)/n;
        else
            S(n+1,m+1) = S(n+1,m)*sqrt((n-m+1)*((m==1)+1)/(n+m));
        end
    end
end

end



function [P,dPdtheta] = legendreFunctions(theta)

% Calculate K, Equations (H-9)
% Note: The indices are incremented by 1 to avoid 0 subscript indices
persistent K
if isempty(K)
    K = zeros(14);
    for n = 2:13
        for m = 0:n
            K(n+1,m+1) = ((n-1)^2-m^2) / ((2*n-1)*(2*n-3));
        end
    end
end

% Calculate P, Equations (H-8)
% Note: The indices are incremented by 1 to avoid 0 subscript indices
P = zeros(14);
for n = 0:13
    for m = 0:n
        if n==0 && m==0
            P(n+1,m+1) = 1;
        elseif n==m
            P(n+1,m+1) = sin(theta)*P(n,n);
        elseif n==1 && m==0
            P(n+1,m+1) = cos(theta)*P(n,m+1);
        else
            P(n+1,m+1) = cos(theta)*P(n,m+1)-K(n+1,m+1)*P(n-1,m+1);
        end
    end
end

% Calculate dPdtheta, Equations (H-10)
% Note: The indices are incremented by 1 to avoid 0 subscript indices
dPdtheta = zeros(14);
for n = 0:13
    for m = 0:n
        if n==0 && m==0
            dPdtheta(n+1,m+1) = 0;
        elseif n==m
            dPdtheta(n+1,m+1) = sin(theta)*dPdtheta(n,n) ...
                + cos(theta)*P(n,n);
        elseif n==1 && m==0
            dPdtheta(n+1,m+1) = cos(theta)*dPdtheta(n,m+1) ...
                - sin(theta)*P(n,m+1);
        else
            dPdtheta(n+1,m+1) = cos(theta)*dPdtheta(n,m+1) ...
                - sin(theta)*P(n,m+1)-K(n+1,m+1)*dPdtheta(n-1,m+1);
        end
    end
end

end



function [g,h] = igrfCoeffs

% Initialize the g and h coefficients
g = zeros(14);
h = zeros(14);

% 11th Generation International Geomagnetic Reference Field Schmidt
% semi-normalised spherical harmonic coefficients, degree n=1,13 in units
% nanoTesla for IGRF and definitive DGRF main-field models (degree n=1,8
% nanoTesla/year for secular variation (SV))
%             IGRF      SV
%  n  m      2010.0   2010-15
g( 2, 1) = -29496.5;%   11.4
g( 2, 2) =  -1585.9;%   16.7
h( 2, 2) =   4945.1;%  -28.8
g( 3, 1) =  -2396.6;%  -11.3
g( 3, 2) =   3026.0;%   -3.9
h( 3, 2) =  -2707.7;%  -23.0
g( 3, 3) =   1668.6;%    2.7
h( 3, 3) =   -575.4;%  -12.9
g( 4, 1) =   1339.7;%    1.3
g( 4, 2) =  -2326.3;%   -3.9
h( 4, 2) =   -160.5;%    8.6
g( 4, 3) =   1231.7;%   -2.9
h( 4, 3) =    251.7;%   -2.9
g( 4, 4) =    634.2;%   -8.1
h( 4, 4) =   -536.8;%   -2.1
g( 5, 1) =    912.6;%   -1.4
g( 5, 2) =    809.0;%    2.0
h( 5, 2) =    286.4;%    0.4
g( 5, 3) =    166.6;%   -8.9
h( 5, 3) =   -211.2;%    3.2
g( 5, 4) =   -357.1;%    4.4
h( 5, 4) =    164.4;%    3.6
g( 5, 5) =     89.7;%   -2.3
h( 5, 5) =   -309.2;%   -0.8
g( 6, 1) =   -231.1;%   -0.5
g( 6, 2) =    357.2;%    0.5
h( 6, 2) =     44.7;%    0.5
g( 6, 3) =    200.3;%   -1.5
h( 6, 3) =    188.9;%    1.5
g( 6, 4) =   -141.2;%   -0.7
h( 6, 4) =   -118.1;%    0.9
g( 6, 5) =   -163.1;%    1.3
h( 6, 5) =      0.1;%    3.7
g( 6, 6) =     -7.7;%    1.4
h( 6, 6) =    100.9;%   -0.6
g( 7, 1) =     72.8;%   -0.3
g( 7, 2) =     68.6;%   -0.3
h( 7, 2) =    -20.8;%   -0.1
g( 7, 3) =     76.0;%   -0.3
h( 7, 3) =     44.2;%   -2.1
g( 7, 4) =   -141.4;%    1.9
h( 7, 4) =     61.5;%   -0.4
g( 7, 5) =    -22.9;%   -1.6
h( 7, 5) =    -66.3;%   -0.5
g( 7, 6) =     13.1;%   -0.2
h( 7, 6) =      3.1;%    0.8
g( 7, 7) =    -77.9;%    1.8
h( 7, 7) =     54.9;%    0.5
g( 8, 1) =     80.4;%    0.2
g( 8, 2) =    -75.0;%   -0.1
h( 8, 2) =    -57.8;%    0.6
g( 8, 3) =     -4.7;%   -0.6
h( 8, 3) =    -21.2;%    0.3
g( 8, 4) =     45.3;%    1.4
h( 8, 4) =      6.6;%   -0.2
g( 8, 5) =     14.0;%    0.3
h( 8, 5) =     24.9;%   -0.1
g( 8, 6) =     10.4;%    0.1
h( 8, 6) =      7.0;%   -0.8
g( 8, 7) =      1.6;%   -0.8
h( 8, 7) =    -27.7;%   -0.3
g( 8, 8) =      4.9;%    0.4
h( 8, 8) =     -3.4;%    0.2
g( 9, 1) =     24.3;%   -0.1
g( 9, 2) =      8.2;%    0.1
h( 9, 2) =     10.9;%    0.0
g( 9, 3) =    -14.5;%   -0.5
h( 9, 3) =    -20.0;%    0.2
g( 9, 4) =     -5.7;%    0.3
h( 9, 4) =     11.9;%    0.5
g( 9, 5) =    -19.3;%   -0.3
h( 9, 5) =    -17.4;%    0.4
g( 9, 6) =     11.6;%    0.3
h( 9, 6) =     16.7;%    0.1
g( 9, 7) =     10.9;%    0.2
h( 9, 7) =      7.1;%   -0.1
g( 9, 8) =    -14.1;%   -0.5
h( 9, 8) =    -10.8;%    0.4
g( 9, 9) =     -3.7;%    0.2
h( 9, 9) =      1.7;%    0.4
g(10, 1) =      5.4;%    0.0
g(10, 2) =      9.4;%    0.0
h(10, 2) =    -20.5;%    0.0
g(10, 3) =      3.4;%    0.0
h(10, 3) =     11.6;%    0.0
g(10, 4) =     -5.3;%    0.0
h(10, 4) =     12.8;%    0.0
g(10, 5) =      3.1;%    0.0
h(10, 5) =     -7.2;%    0.0
g(10, 6) =    -12.4;%    0.0
h(10, 6) =     -7.4;%    0.0
g(10, 7) =     -0.8;%    0.0
h(10, 7) =      8.0;%    0.0
g(10, 8) =      8.4;%    0.0
h(10, 8) =      2.2;%    0.0
g(10, 9) =     -8.4;%    0.0
h(10, 9) =     -6.1;%    0.0
g(10,10) =    -10.1;%    0.0
h(10,10) =      7.0;%    0.0
g(11, 1) =     -2.0;%    0.0
g(11, 2) =     -6.3;%    0.0
h(11, 2) =      2.8;%    0.0
g(11, 3) =      0.9;%    0.0
h(11, 3) =     -0.1;%    0.0
g(11, 4) =     -1.1;%    0.0
h(11, 4) =      4.7;%    0.0
g(11, 5) =     -0.2;%    0.0
h(11, 5) =      4.4;%    0.0
g(11, 6) =      2.5;%    0.0
h(11, 6) =     -7.2;%    0.0
g(11, 7) =     -0.3;%    0.0
h(11, 7) =     -1.0;%    0.0
g(11, 8) =      2.2;%    0.0
h(11, 8) =     -4.0;%    0.0
g(11, 9) =      3.1;%    0.0
h(11, 9) =     -2.0;%    0.0
g(11,10) =     -1.0;%    0.0
h(11,10) =     -2.0;%    0.0
g(11,11) =     -2.8;%    0.0
h(11,11) =     -8.3;%    0.0
g(12, 1) =      3.0;%    0.0
g(12, 2) =     -1.5;%    0.0
h(12, 2) =      0.1;%    0.0
g(12, 3) =     -2.1;%    0.0
h(12, 3) =      1.7;%    0.0
g(12, 4) =      1.6;%    0.0
h(12, 4) =     -0.6;%    0.0
g(12, 5) =     -0.5;%    0.0
h(12, 5) =     -1.8;%    0.0
g(12, 6) =      0.5;%    0.0
h(12, 6) =      0.9;%    0.0
g(12, 7) =     -0.8;%    0.0
h(12, 7) =     -0.4;%    0.0
g(12, 8) =      0.4;%    0.0
h(12, 8) =     -2.5;%    0.0
g(12, 9) =      1.8;%    0.0
h(12, 9) =     -1.3;%    0.0
g(12,10) =      0.2;%    0.0
h(12,10) =     -2.1;%    0.0
g(12,11) =      0.8;%    0.0
h(12,11) =     -1.9;%    0.0
g(12,12) =      3.8;%    0.0
h(12,12) =     -1.8;%    0.0
g(13, 1) =     -2.1;%    0.0
g(13, 2) =     -0.2;%    0.0
h(13, 2) =     -0.8;%    0.0
g(13, 3) =      0.3;%    0.0
h(13, 3) =      0.3;%    0.0
g(13, 4) =      1.0;%    0.0
h(13, 4) =      2.2;%    0.0
g(13, 5) =     -0.7;%    0.0
h(13, 5) =     -2.5;%    0.0
g(13, 6) =      0.9;%    0.0
h(13, 6) =      0.5;%    0.0
g(13, 7) =     -0.1;%    0.0
h(13, 7) =      0.6;%    0.0
g(13, 8) =      0.5;%    0.0
h(13, 8) =      0.0;%    0.0
g(13, 9) =     -0.4;%    0.0
h(13, 9) =      0.1;%    0.0
g(13,10) =     -0.4;%    0.0
h(13,10) =      0.3;%    0.0
g(13,11) =      0.2;%    0.0
h(13,11) =     -0.9;%    0.0
g(13,12) =     -0.8;%    0.0
h(13,12) =     -0.2;%    0.0
g(13,13) =      0.0;%    0.0
h(13,13) =      0.8;%    0.0
g(14, 1) =     -0.2;%    0.0
g(14, 2) =     -0.9;%    0.0
h(14, 2) =     -0.8;%    0.0
g(14, 3) =      0.3;%    0.0
h(14, 3) =      0.3;%    0.0
g(14, 4) =      0.4;%    0.0
h(14, 4) =      1.7;%    0.0
g(14, 5) =     -0.4;%    0.0
h(14, 5) =     -0.6;%    0.0
g(14, 6) =      1.1;%    0.0
h(14, 6) =     -1.2;%    0.0
g(14, 7) =     -0.3;%    0.0
h(14, 7) =     -0.1;%    0.0
g(14, 8) =      0.8;%    0.0
h(14, 8) =      0.5;%    0.0
g(14, 9) =     -0.2;%    0.0
h(14, 9) =      0.1;%    0.0
g(14,10) =      0.4;%    0.0
h(14,10) =      0.5;%    0.0
g(14,11) =      0.0;%    0.0
h(14,11) =      0.4;%    0.0
g(14,12) =      0.4;%    0.0
h(14,12) =     -0.2;%    0.0
g(14,13) =     -0.3;%    0.0
h(14,13) =     -0.5;%    0.0
g(14,14) =     -0.3;%    0.0
h(14,14) =     -0.8;%    0.0

end
