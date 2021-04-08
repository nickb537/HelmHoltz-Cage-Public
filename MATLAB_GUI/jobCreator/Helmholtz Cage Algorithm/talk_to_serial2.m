% over serial port

% talk to serial port
% for testing, can change dt
dt = .2;


jj=1;
comm_port = serial('COM4','BaudRate',19200);
fopen(comm_port);

cmd = sprintf('%d,%d,%d\n', 127,127,160);
disp(cmd);
% keyboard
pause(1);
% for j = 1:length(current_cmd)
for k = 1:1
for jj = 1:256
    cmd = sprintf('%d,%d,%d\n', jj-1,jj-1,jj-1);
    disp(cmd);
    field = sprintf('Magnetic Field X: %d Y: %d Z: %d in MicroTeslas',magFieldIGRF(1,jj)/MICROTESLAS,magFieldIGRF(2,jj)/MICROTESLAS,magFieldIGRF(3,jj)/MICROTESLAS);
    disp(field);
    fwrite(comm_port,cmd);
    disp(jj);
    pause(dt*2);
    figure(2); clf;
    hold off;
    plot(time(1:jj)/MINUTES,magFieldIGRF(1:3,1:jj)/MICROTESLAS,'LineWidth',5)%'.','MarkerSize',10);
    hold on;
    plot(time/MINUTES,magFieldIGRF/MICROTESLAS,'Color',0.9*ones(1,3),'LineWidth',5);
    plot(time(1:jj)/MINUTES,magFieldIGRF(1:3,1:jj)/MICROTESLAS,'LineWidth',5)%'.','MarkerSize',10);
    xlim([0 time(jj)/MINUTES+10]);
    xlabel('Time [min]');
    ylabel('Magnetic Field [\muT]');
    title('Earth Magnetic Field in Orbit');
    legend('x','y','z')
    jj = jj+1;
    pause
end
end
fclose(comm_port);

