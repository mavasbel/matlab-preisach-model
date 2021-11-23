clear all
close all
clc

% Open file
fid = fopen('./data/PNZT_S1_triangular_pulse_rem_drift.dat');

% Create measurements array
measurements = [];

% Reading loop
while(1)
    % Read line
    line = fgetl(fid);
    
    % If end of file or error then end loop
    if ~ischar(line), break, end
    
    % If field 'Timestamp' found then create measurement
    if contains(line, 'Timestamp:')

        % Create measurement and add timestamp
        measurement = MeasurementClass();
        measurement.timestamp = datetime( ...
                            erase(line, 'Timestamp: '), ...
                            'InputFormat', 'MM/dd/yyyy HH:mm:ss' );
        
        % Read lines until find begining of table 
        while(1)
            line = fgetl(fid);
            
            % Save parameters if found
            if contains(line, 'Waveform:')
                measurement.waveform = erase(line, 'Waveform: ');
            end
            if contains(line, 'SampleName:') 
                measurement.sampleName = erase(line, 'SampleName: ');
            end
            if contains(line, 'Error:') 
                measurement.error = erase(line, 'Error: ');
            end
            
            % Begining of table starts with 'Time [s]'
            if contains(line, 'Time [s]'), break, end
        end
        
        % Read table and add values
        data = fscanf(fid, '%f', [13, inf])';
        measurement.time = data(:,1);
        measurement.strain = data(:,10);
        measurement.current = data(:,4);
        measurement.voltage = 0.5*(data(:,2)+data(:,3)) + ...
                                0.5*(data(:,2)-data(:,3));
        
        % Add measurement
        measurements = [measurements; measurement]; 
    end
end

fclose(fid);