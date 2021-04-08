clear all; close all; clc;

% linearity test
current_cmd = zeros(3,256);
% current_cmd = ones(3,256)*127;
for k = 1:256
    current_cmd(:,k) = k-1; 
end
dt = 0.2;

comm_port = serial('COM8','BaudRate',19200);
fopen(comm_port);

% sets current to range for each axis according to its control authority
% max is 50 microTesla, min is -49 microTesla
current_cmd(1,:) = round((current_cmd(1,:)+1.19)*((256/2.38)-1));
current_cmd(2,:) = round((current_cmd(2,:)+1.145)*((256/2.29)-1));
current_cmd(3,:) = round((current_cmd(3,:)+1.23)*((256/2.46)-1));

for j = 1:length(current_cmd);
    cmd = sprintf('%d,%d,%d\n', current_cmd(1,j),current_cmd(2,j),current_cmd(3,j));
    disp(cmd);
    fwrite(comm_port,cmd);
    pause(dt);
    j = j+1
% if j == 128
%    break
    pause
% end 
end
fclose(comm_port);

