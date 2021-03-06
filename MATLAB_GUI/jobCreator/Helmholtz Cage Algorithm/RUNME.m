clear all; close all; clc

% Add folders to path
path(path,'constants')
path(path,'units')
path(path,'utilities')

% Initial time parameters
initYear   = 2016;
initMonth  = 12;
initDay    = 08;
initHour   = 11;
initMinute = 00;
initSecond = 00;
julianDateInit = gregorianToJulianDate(...
    initYear, ...
    initMonth, ...
    initDay, ...
    initHour, ...
    initMinute, ...
    initSecond);

% Initial orbit parameters
perigee = 420 * KILOMETERS + EARTH_RADIUS;
apogee = 850 * KILOMETERS + EARTH_RADIUS;
inclination = 97.2 * DEGREES;
rightAscensionOfTheAscendingNode = 0 * DEGREES;
argumentOfPerigee = 0 * DEGREES;
trueAnomaly = 0 * DEGREES;
trueLongitude = 0 * DEGREES;
argumentOfLatitude = 0 * DEGREES;
longitudeOfPerigee = 0 * DEGREES;

% Orbit calculations
semimajorAxis = (apogee + perigee) / 2;
eccentricity = (apogee - perigee) / (apogee + perigee);
semiparameter = semimajorAxis * (1 - eccentricity^2);
orbitPeriod = 2*pi / sqrt(EARTH_GRAV_PARAM/(semimajorAxis)^3);
[posInit,velInit] = keplerianToPosVel( ...
    semiparameter, ...
    eccentricity, ...
    inclination, ...
    rightAscensionOfTheAscendingNode, ...
    argumentOfPerigee, ...
    trueAnomaly, ...
    trueLongitude, ...
    argumentOfLatitude, ...
    longitudeOfPerigee);

% Simulate an orbit
dt = 10; % in seconds
time = 0:dt:orbitPeriod;
magFieldDipole = zeros(3,length(time));
magFieldIGRF = zeros(3,length(time));
current = zeros(3,length(time));
current_cmd = zeros(3,length(time));

Bs=[];
  
for i = 1:length(time)
    [pos,vel] = keplersProblem(posInit,velInit,time(i));
    magFieldDipole(:,i) = earthIGRFDipole(julianDateInit+time(i)/DAYS,pos);
    magFieldIGRF(:,i) = earthIGRFModel(julianDateInit+time(i)/DAYS,pos);
    %current(:,i) = biot_savart(magFieldIGRF(:,i),0,0,0);
    Bs(:,i)=bound(magFieldIGRF(:,i)*1E6,-100,100);
end



% Plot magnetic field over an orbit
figure(1);
plot(time/MINUTES,magFieldIGRF/MICROTESLAS,'LineWidth',5);
xlim([0 orbitPeriod]/MINUTES);
xlabel('Time [min]');
ylabel('Magnetic Field [\muT]');
title('Earth Magnetic Field in Orbit');
%legend('x dipole','y dipole','z dipole','x IGRF','y IGRF','z IGRF');
legend('x IGRF','y IGRF','z IGRF');
hold on;

writeout=[time' Bs'];
writematrix(writeout, "job.csv")


function y = bound(x,bl,bu)
  % return bounded value clipped between bl and bu
  y=min(max(x,bl),bu);
end

