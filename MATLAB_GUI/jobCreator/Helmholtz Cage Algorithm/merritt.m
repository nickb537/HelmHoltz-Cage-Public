function I = merritt(magFieldIGRF,r,z)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  This function uses the magnetic field value
%%  provided by RUNME in the magnetic field sim
%%  and calculates the current that should be
%%  commanded to the coils using the equations
%%  presented for the 4-coil Merritt design.
%%
%%  Author: Meghan Prinkey (mprinkey@mit.edu)
%%  Date: 3/20/13
%%  Inputs: magfieldIGRF    muT, 3-dimensional vector
%%          r                 m, radial distance from origin
%%          z                 m, vertical distance from origin
%%  Outputs: I (current)      A, 3-dimensional vector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set up magnetic field values
% need basic propagator to estimate where satellite is
% output is 3x1 vector B

% declare variables
B = magFieldIGRF;
mu_not = 4.7*pi*1e-6; % T-m/A

% calculate a
a_side = [55,57,59]/2*.0254; % convert to metric
a_perim = a_side*4/pi;
a = a_perim;

% calculate k
k(1) = sqrt((4*a(1)*r)/(((a(1)+r)^2)+z^2));
k(2) = sqrt((4*a(2)*r)/(((a(2)+r)^2)+z^2));
k(3) = sqrt((4*a(3)*r)/(((a(3)+r)^2)+z^2));
[K(1),E(1)] = ellipke(k(1));
[K(2),E(2)] = ellipke(k(2));
[K(3),E(3)] = ellipke(k(3));

% calculate the terms in the B field calculations for Eq 4
red(1) = 1/sqrt((a(1)+r)^2+z^2);
red(2) = 1/sqrt((a(2)+r)^2+z^2);
red(3) = 1/sqrt((a(3)+r)^2+z^2);
blue(1) = (K(1) + ((a(1)^2-r^2-z^2)/((a(1)-r)^2+z^2))*E(1));
blue(2) = (K(2) + ((a(2)^2-r^2-z^2)/((a(2)-r)^2+z^2))*E(2));
blue(3) = (K(3) + ((a(3)^2-r^2-z^2)/((a(3)-r)^2+z^2))*E(3));

% calculate current based on z field (Eq 4 from Merritt, et al)
I(1) = B(1)*2*pi/mu_not*(1/red(1))*(1/blue(1));
I(2) = B(2)*2*pi/mu_not*(1/red(2))*(1/blue(2));
I(3) = B(3)*2*pi/mu_not*(1/red(3))*(1/blue(3));

