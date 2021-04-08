function [scPos,scVel] = keplersProblem(scInitPos,scInitVel,deltaTime)
%KEPLERSPROBLEM calculates the spacecraft position and velocity given the
%initial position, velocity, and time elapsed.
%
% Input:
% - scInitPos:  Initial position of the spacecraft in ECI coordinates [m]
% - scInitVel:  Initial velocity of the spacecraft in ECI coordinates [m]
% - deltaTime:  Time elapsed [s]
%
% Output:
% - scPos:      Position of the spacecraft in ECI coordinates [m]
% - scVel:      Velocity of the spacecraft in ECI coordinates [m]
%
% Reference:
% - Vallado, Fundamentals of Astrodynamics and Applications, 2001,
%   2.3 Kepler's Problem,
%   2.3.1 Solution Techniques,
%   Classical Formulas Using f and g Functions.
%
%#codegen

% Convert the inputs to units of ER and TU. This allows all the usages of
% Earth's gravitational parameter in the equations below to be set to one
% (Earth's gravitational parameter = 1 ER^3/TU^2).
dt = deltaTime / EARTH_TIME_UNIT;
r0 = scInitPos / EARTH_RADIUS;
v0 = scInitVel / (EARTH_RADIUS/EARTH_TIME_UNIT);

% Initial calculations
r0Norm = norm(r0);
v0Norm = norm(v0);
rdotv = dot(r0,v0);

% Calculate the specific mechanical energy
xi = v0Norm^2/2 - 1/r0Norm;

% Calculate alpha (determines orbit type)
alpha = -2*xi;

% Calculate the initial guess for chi for various orbit types
if alpha > 1e-6 % Circle or ellipse
    
    if abs(alpha-1) > 1e-6
        chi = dt*alpha;
    else
        chi = 0.97*dt*alpha; % Perturb first guess
    end
    
elseif abs(alpha) <= 1e-6 % Parabola
    
    alpha = 0;
    p = norm(cross(r0,v0))^2;
    s = acot(3 * sqrt(1/p^3) * dt) / 2;
    w = atan(tan(s)^(1/3));
    chi = 2 * sqrt(p) * cot(2*w);
    
else % alpha <= -1e-6 % Hyperbola
    
    a = 1/alpha;
    chi = sign(dt) * sqrt(-a) * log( -2*alpha*dt / ...
        (rdotv + sign(dt)*sqrt(-a)*(1 - r0Norm*alpha)) );
    
end

% Calculate a new value for chi using Newton-Raphson iterations
deltaChi = 1; % Just needs to be larger than 1e-6
while (abs(deltaChi) >= 1e-6)
    psi = chi^2 * alpha;
    [c2,c3] = findc2c3(psi);
    r = chi^2*c2 + rdotv*chi*(1 - psi*c3) + r0Norm*(1 - psi*c2);
    deltaChi = (dt - chi^3*c3 - rdotv*chi^2*c2 - r0Norm*chi*(1-psi*c3)) ...
        / r;
    chi = chi + deltaChi;
end

% Find position and velocity vectors at the new time
psi = chi^2 * alpha;
[c2,c3] = findc2c3(psi);
f = 1 - (chi^2*c2/r0Norm);
g = dt - chi^3*c3;
r = f*r0 + g*v0;
rNorm = norm(r);
gDot = 1 - (chi^2*c2 / rNorm);
fDot = chi*(psi*c3 - 1) / (r0Norm*rNorm);
v = fDot*r0 + gDot*v0;

% The following quantity should be equal to one (for debugging only)
% shouldBeOne = f*gDot - fDot*g;

% Convert position and velocity units
scPos = r * EARTH_RADIUS;
scVel = v * (EARTH_RADIUS/EARTH_TIME_UNIT);

end



function [c2,c3] = findc2c3(psi)
%FINDC2C3 calculates the values of c2 and c3 as a function of psi.
%
% Reference:
% - Vallado, Fundamentals of Astrodynamics and Applications, 2001,
%   2.2 Kepler's Equation,
%   2.2.4 Universal Formulation.
%
%#codegen

if psi > 1e-6
    sqrtPsi = sqrt(psi);
    c2 = (1 - cos(sqrtPsi)) / psi;
    c3 = (sqrtPsi - sin(sqrtPsi)) / (sqrtPsi^3);
elseif psi < -1e-6
    sqrtPsi = sqrt(-psi);
    c2 = (1 - cosh(sqrtPsi)) / psi;
    c3 = (sinh(sqrtPsi) - sqrtPsi) / (sqrtPsi^3);
else
    c2 = 1/2;
    c3 = 1/6;
end

end
