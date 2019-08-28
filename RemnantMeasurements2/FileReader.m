clear all
close all
clc

% File paths

% Triangular inputs
% files = [
%         "./remnant_measurements/triag/RMN_1200V_VAR.dat";
%         "./remnant_measurements/triag/RMN_1400V_VAR.dat"; 
%         "./remnant_measurements/triag/RMN_FADE_VAR.dat"; 
%         "./remnant_measurements/triag/RMN_1400V_1000V_VAR.dat"; 
%     ];

% Trapezoidal inputs
files = [
        "./remnant_measurements/trap/RMN_TRAP_1200V_VAR.dat"; 
        "./remnant_measurements/trap/RMN_TRAP_1400V_VAR.dat"; 
        "./remnant_measurements/trap/RMN_TRAP_1400V_500V_VAR.dat"; 
        "./remnant_measurements/trap/RMN_TRAP_1400V_1000V_VAR.dat";
    ];

% Create measurements array
measurements = [];

for fileCounter=1:length(files)
    % Open file
    fid = fopen(files(fileCounter));
    
    % Reading loop
    while(1)
        % Read line
        line = fgetl(fid);

        % If end of file or error then end loop
        if ~ischar(line), break, end

        % If field 'Timestamp' found then create measurement
        if contains(line, 'Timestamp:')

            % Create measurement and add timestamp
            measurementData = MeasurementData();
            measurementData.timestamp = datetime( ...
                                erase(line, 'Timestamp: '), ...
                                'InputFormat', 'MM/dd/yyyy HH:mm:ss' );

            % Read lines until find begining of table 
            while(1)
                line = fgetl(fid);

                % Save parameters if found
                if contains(line, 'Waveform:')
                    measurementData.waveform = line;
                end
                if contains(line, 'SampleName:') 
                    measurementData.sampleName = line(13:end);
                end
                if contains(line, 'Error:') 
                    measurementData.error = line(8:end);
                end

                % Begining of table starts with 'Time [s]'
                if contains(line, 'Time [s]'), break, end
            end

            % Read table and add values
            data = fscanf(fid, '%f', [13, inf])';
            measurementData.time = data(:,1);
            measurementData.strain = data(:,10);
            measurementData.current = data(:,4);
            measurementData.voltage = 0.5*(data(:,2)+data(:,3)) + ...
                                    0.5*(data(:,2)-data(:,3));

            % Add measurement
            measurements = [measurements; measurementData]; 
        end
    end

    % Close file
    fclose(fid);
end