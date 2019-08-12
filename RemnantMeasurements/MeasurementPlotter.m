close all
clc

% Print all measurements names
for i=1:length(measurements), disp(measurements(i).sampleName), end

% Name of measurement to plot
fullName = 'PNZT_F_400V_1Hz';
for i=1:length(measurements)
    if strcmp(measurements(i).sampleName, fullName)>0 && ...
        strcmp(measurements(i).waveform, 'Manual1')>0 
        
        % Print measurement
        disp('----------------------------------------')
        disp(horzcat('Plotting Measurement ', num2str(i), ': '))
        disp(measurements(i))
    
        % Find and add voltage offset and initial strain
        idx = find(measurements(i).time>=2.75 & measurements(i).time<=3.0, ...
            1, 'first');
        voltageOffset = measurements(i).voltage(idx);
        strainOffset = measurements(i).strain(idx);
        voltageOffset = 0;
        strainOffset = 0;
        
        % Strain vs Time plot
        figure
        plot(measurements(i).time, ...
            measurements(i).strain - strainOffset)
                xlabel('Time (s)')
        title(horzcat('Measurement ', num2str(i), ': ', ...
            measurements(i).sampleName, ...
            ' [', measurements(i).error, ']'), ...
            'interpreter', 'none')
        ylabel('Deformation (nm)')
        grid on
        
        % Voltage vs Time plot
        figure
        plot(measurements(i).time, ...
            measurements(i).voltage - voltageOffset)
        title(horzcat('Measurement ', num2str(i), ': ', ...
            measurements(i).sampleName, ...
            ' [', measurements(i).error, ']'), ...
            'interpreter', 'none')
        xlabel('Time (s)')
        ylabel('Voltage (V)')
        grid on
        
        % Voltage vs Strain plot
        figure
        plot(measurements(i).voltage - voltageOffset, ...
            measurements(i).strain - strainOffset)
        title(horzcat('Measurement ', num2str(i), ': ', ...
            measurements(i).sampleName, ...
            ' [', measurements(i).error, ']'), ...
            'interpreter', 'none')
        xlabel('Voltage (V)')
        ylabel('Deformation (nm)')
        
        % Creep strain vs Time plot
%         figure
%         idx = find(measurements(i).time>=32.5 ...
%                 & measurements(i).time<=40, ...
%                 1, 'first');
%         plot(measurements(i).time(idx:end), ...
%             measurements(i).strain(idx:end) - strainOffset)
%                 xlabel('Time (s)')
%         ylabel('Deformation (nm)')
%         grid on
        
        % Create data handler
        dataHandler = DataHandler(measurements(i).voltage - voltageOffset, ...
            measurements(i).strain - strainOffset, ...
            measurements(i).time);
    end
end

