function I = helmholtz(magFieldIGRF)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  This function uses the magnetic field value
%%  provided by RUNME in the magnetic field sim
%%  and calculates the current that should be
%%  commanded to the coils based on the field
%%  value.
%%
%%  Author: Meghan Prinkey (mprinkey@mit.edu)
%%  Date: 1/23/12
%%  Inputs: magfieldIGRF     uT, 3-dimensional vector
%%  Outputs: I (current)      A, 3-dimensional vector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set up magnetic field values
% need basic propagator to estimate where satellite is
% output is 3x1 vector B

B = magFieldIGRF;
mu_not = 1.26e-6; % T-m/A
n_thin = 11; % number of turns in thinner coils
n_thick = 26; % number of turns in thicker coils
n_avg = (n_thin+n_thick)/2;
rad = [55,57,59]*.0254; % radii of 3 axes of coils,
    % converts from inches to meters

% set up loop to get current for different coils
for i=1:3
    I(i) = 1.3975*B(i)*rad(i)/mu_not/n_avg;
    %I_thincoils(i) = 1.3975*B(i)*rad(i)/mu_not/n_thin;
    %I_thickcoils(i) = 1.3975*B(i)*rad(i)/mu_not/n_thick;
end

% command those values to become analog
end