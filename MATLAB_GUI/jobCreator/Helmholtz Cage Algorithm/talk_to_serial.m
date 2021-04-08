% talk over serial port

% talk to serial port
% for testing, can change dt
dt_cmd = .2;


ii=1;
comm_port = serial('COM4','BaudRate',19200);
fopen(comm_port);
% for j = 1:length(current_cmd)
for k = 1:1
for ii = 1:length(time)
    cmd = sprintf('%d,%d,%dc', current_cmd(1,ii),current_cmd(2,ii),current_cmd(3,ii));
%     disp(cmd);
    field = sprintf('Magnetic Field X: %2.3f Y: %2.3f Z: %2.3f MicroTeslas',magFieldIGRF(2,ii)/MICROTESLAS,magFieldIGRF(1,ii)/MICROTESLAS,magFieldIGRF(3,ii)/MICROTESLAS);
    disp(field);
    fwrite(comm_port,cmd);
    disp(ii);
    pause(dt_cmd);
    figure(2); clf;
    hold off;
    plot(time(1:ii)/MINUTES,magFieldIGRF(1:3,1:ii)/MICROTESLAS,'LineWidth',5)
    hold on;
    plot(time/MINUTES,magFieldIGRF/MICROTESLAS,'Color',0.9*ones(1,3),'LineWidth',5)
    plot(time(1:ii)/MINUTES,magFieldIGRF(1:3,1:ii)/MICROTESLAS,'LineWidth',5)
    xlim([0 time(ii)/MINUTES+10]);
    xlabel('Time [min]');
    ylabel('Magnetic Field [\muT]');
    title('Earth Magnetic Field in Orbit');
    legend('x','y','z')
    ii = ii+1;
%     
%     cmd = sprintf('%d,%d,%d\n',0,0,0);
%     fwrite(comm_port,cmd);
%     fprintf('paused at zero\n')
%     pause
end
cmd = sprintf('%d,%d,%dc',127,127,127);
fwrite(comm_port,cmd);
pause(1);
end
fclose(comm_port);

