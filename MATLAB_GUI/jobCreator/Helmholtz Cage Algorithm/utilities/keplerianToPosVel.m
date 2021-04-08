function [pos,vel] = keplerianToPosVel(...
    semiparam,ecc,incl,raan,argper,trueanom,truelon,arglat,lonper)
%KEPLERIANTOPOSVEL returns the ECI position and velocity coordinates
%given the Keplerian elements.
%
% Inputs:
% - semiparam:  Semiparameter (also known as semilatus rectum) [m]
% - ecc:        Eccentricity
% - incl:       Inclination [0 to pi rad]
% - raan:       Right ascension of ascending node [0 to 2pi rad]
% - argper:     Argument of perigee [0 to 2pi rad]
% - trueanom:   True anomaly [0 to 2pi rad]
% - truelon:    True longitude [0 to 2pi rad]
% - arglat:     Argument of latitude [0 to 2pi rad]
% - lonper:     Longitude of perigee [0 to 2pi rad]
%
% Outputs:
% - pos:        Position in ECI frame [m]
% - vel:        Velocity in ECI frame [m/s]
%
% Notes:
% - Most orbits can be defined with six Keplerian elements:
%   - Semiparameter
%   - Eccentricity
%   - Inclination
%   - Right ascension of the ascending node
%   - Argument of perigee
%   - True anomaly
% - Semiparameter and eccentricity can be calculated from perigee and
%   apogee, which are easier to visualize, for closed orbits
% - There are three special orbits that require additional parameters:
%   - Circular equatorial orbit: True longitude
%   - Circular inclined orbit: Argument of latitude
%   - Elliptical equatorial orbit: Longitude of perigee
%
% Reference:
% - Vallado, Fundamentals of Astrodynamics and Applications, 2001,
%   2.6 Application: r and v from Orbital Elements,
%   Algorithm 10: randv.
%
%#codegen

% Define tolerances
epsilon = 1e-8;

% Handle special cases
if ecc < epsilon
    
    % Circular equatorial
    if (incl < epsilon) || (abs(incl-pi) < epsilon)
        argper = 0;
        raan = 0;
        trueanom = truelon;
        
    else % Circular inclined
        argper = 0;
        trueanom = arglat;
    end
    
else
    
    % Elliptical equatorial
    if (incl < epsilon) || (abs(incl-pi) < epsilon)
        argper = lonper;
        raan = 0;
    end
    
end

% Enforce minimum value of semiparameter to avoid divide by zero
if abs(semiparam) < 1e-4
    semiparam = 1e-4;
end

% Calculate the position and velocity in the perifocal coordinate system:
% - origin at the center of the Earth
% - x-axis points towards perigee
% - y-axis points in the velocity direction at perigee
% - z-axis forms a right-handed system (normal to the orbital plane)
pos = [
    semiparam*cos(trueanom) / (1 + ecc*cos(trueanom))
    semiparam*sin(trueanom) / (1 + ecc*cos(trueanom))
    0];
vel = [
    -sqrt(EARTH_GRAV_PARAM/semiparam)*sin(trueanom)
    sqrt(EARTH_GRAV_PARAM/semiparam)*(ecc + cos(trueanom))
    0];

% Calculate transformation from perifocal to ECI coordinates
R = coder.nullcopy(zeros(3));
R(1,1) =  cos(raan)*cos(argper)-sin(raan)*sin(argper)*cos(incl);
R(2,1) =  sin(raan)*cos(argper)+cos(raan)*sin(argper)*cos(incl);
R(3,1) =  sin(argper)*sin(incl);
R(1,2) = -cos(raan)*sin(argper)-sin(raan)*cos(argper)*cos(incl);
R(2,2) = -sin(raan)*sin(argper)+cos(raan)*cos(argper)*cos(incl);
R(3,2) =  cos(argper)*sin(incl);
R(1,3) =  sin(raan)*sin(incl);
R(2,3) = -cos(raan)*sin(incl);
R(3,3) =  cos(incl);

% Transform and output position and velocity
pos = R*pos;
vel = R*vel;

end
