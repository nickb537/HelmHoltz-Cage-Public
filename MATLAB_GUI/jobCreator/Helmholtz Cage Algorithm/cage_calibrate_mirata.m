  % Cage Calibration Test
clear all; close all; clc;

% Add folders to path
path(path,'constants')
path(path,'units')
path(path,'utilities')

dt = 0.01;

Tesla_lim = zeros(3,256);

for k = 1:3 
    Tesla_lim(k,:) = linspace(-50*MICROTESLAS,50*MICROTESLAS,256);
end
for i = 1:length(Tesla_lim)
    current(:,i) = biot_savart(Tesla_lim(:,i),0,0,0);
end

% sets current to range for each axis according to its control authority
% max is 50 microTesla, min is about -50 microTesla
current_cmd(1,:) = round((current(1,:)+1.192)*((256/2.38)-1))-5;
% current_cmd(1,:) = round((current(1,:)+1.100)*((256/2.30)-1));
current_cmd(2,:) = round((current(2,:)+1.140)*((256/2.29)-1))-5;
current_cmd(3,:) = round((current(3,:)+1.160)*((256/2.46)-1))-5;

% keyboard 

comm_port = serial('COM4','BaudRate',19200);
fopen(comm_port);
for j = 1:length(current_cmd);
    cmd = sprintf('%d,%d,%d\n', current_cmd(1,j),current_cmd(2,j),current_cmd(3,j));
%     cmd = sprintf('%d,%d,%d\n', 0,0,current_cmd(3 ,j));

    disp(cmd);
    fwrite(comm_port,cmd);
%     pause
    pause(dt)
    j = j+1
if j == 2
    pause
elseif j == 128
    pause
elseif j == 257
    pause
end
end
fclose(comm_port);

