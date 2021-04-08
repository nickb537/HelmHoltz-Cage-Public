comm_port = serial('COM4','BaudRate',19200);
fopen(comm_port);
fwrite(comm_port, '20,20,20\n');
c = fread(comm_port,50);
fclose(comm_port);

