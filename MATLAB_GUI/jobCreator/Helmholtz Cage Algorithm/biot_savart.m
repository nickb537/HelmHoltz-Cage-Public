function I = biot_savart(magFieldIGRF,x,y,z)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  This function uses the magnetic field value
%%  provided by RUNME in the magnetic field sim
%%  and calculates the current that should be
%%  commanded to the coils using the Biot-Savart
%%  law.
%%
%%  Author: Meghan Prinkey (mprinkey@mit.edu)
%%  Date: 4/12/13
%%  Inputs: magfieldIGRF    muT, 3x1 vector
%%          r                 m, radial distance from origin
%%          z                 m, vertical distance from origin
%%  Outputs: I (current)      A, 3-dimensional vector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set up magnetic field values
% need basic propagator to estimate where satellite is
% output is 3x1 vector B

% declare variables
B = magFieldIGRF;
mu_not = 4*pi*1e-7; % T-m/A

% calculate a
a_side = [55,57,59]/2*.0254; % convert to metric
a_perim = a_side*4/pi;
a = a_perim;

% using Biot Savart law, calculate current

% set up vector
pos = [x,y,z];

% calculate the distance from center of cage to each coil line segment
dist = [.5055,.1281,-.1281,-.5055];
N_not(1:4) = 26;
N_not(5:12) = 11;
N_not(13:16) = 26;

% ordering of vectors is clockwise around each of the four line segments
% ordering of coils is from top to bottom/front to back

i = 1;
j = 1;
while i<17
    % calculates distance from center of cage to center of each line
    % segment
    coilx(i,:)   = 57*[dist(j),0,.5]*.0254;
    coilx(i+1,:) = 57*[dist(j),.5,0]*.0254;
    coilx(i+2,:) = 57*[dist(j),0,-.5]*.0254;
    coilx(i+3,:) = 57*[dist(j),-.5,0]*.0254;
    % calculates direction of current, with magnitude of length of coil
    dlx(i,:)   = 57*[0,1,0]*.0254;
    dlx(i+1,:) = 57*[0,0,-1]*.0254;
    dlx(i+2,:) = 57*[0,-1,0]*.0254;
    dlx(i+3,:) = 57*[0,0,1]*.0254;
    i = i+4;
    j = j+1;
end

i = 1;
j = 1;
while i<17
    coily(i,:)   = 55*[0,dist(j),.5]*.0254;
    coily(i+1,:) = 55*[-.5,dist(j),0]*.0254;
    coily(i+2,:) = 55*[0,dist(j),-.5]*.0254;
    coily(i+3,:) = 55*[.5,dist(j),0]*.0254;
    dly(i,:)   = 55*[-1,0,0]*.0254;
    dly(i+1,:) = 55*[0,0,-1]*.0254;
    dly(i+2,:) = 55*[1,0,0]*.0254;
    dly(i+3,:) = 55*[0,0,1]*.0254;
    i = i+4;
    j = j+1;
end

i = 1;
j = 1;
while i<17
    coilz(i,:)   = 59*[-.5,0,dist(j)]*.0254;
    coilz(i+1,:) = 59*[0,.5,dist(j)]*.0254;
    coilz(i+2,:) = 59*[.5,0,dist(j)]*.0254;
    coilz(i+3,:) = 59*[0,-.5,dist(j)]*.0254;
    dlz(i,:)   = 59*[0,1,0]*.0254;
    dlz(i+1,:) = 59*[1,0,0]*.0254;
    dlz(i+2,:) = 59*[0,-1,0]*.0254;
    dlz(i+3,:) = 59*[-1,0,0]*.0254;
    i = i+4;
    j = j+1;
end

% calculate integral
% for each set of coils
integral = 0;
for i = 1:16
    r = coilx(i,:) - pos;
    mag_r = sqrt(r(1)^2+r(2)^2+r(3)^2);
    integral = integral + N_not(i)*(cross(dlx(i,:),r)/(mag_r)^3);
end
for i = 1:16
    r = coily(i,:) - pos;
    mag_r = sqrt(r(1)^2+r(2)^2+r(3)^2);
    integral = integral + N_not(i)*(cross(dly(i,:),r)/(mag_r)^3);
end
for i = 1:16
    r = coilz(i,:) - pos;
    mag_r = sqrt(r(1)^2+r(2)^2+r(3)^2);
    integral = integral + N_not(i)*(cross(dlz(i,:),r)/(mag_r)^3);
end

% multiply to get current
% compensate for extra biaas in z-axis
I(1) = B(1)*4*pi/mu_not/integral(1);
I(2) = B(2)*4*pi/mu_not/integral(2);
I(3) = (B(3)+3*1e-6)*4*pi/mu_not/integral(3);

end