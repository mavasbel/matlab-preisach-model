close all
clc

% Print all measurements names
for i=1:length(measurements), disp(measurements(i).sampleName), end

% Name of measurement to plot
fullName = 'RMN_1400V_500V_600V';

for i=1:length(measurements)
    if strcmp(measurements(i).sampleName, fullName)>0 && ...
        strcmp(measurements(i).waveform, 'ManualWaveform: 1')>0 
        
        % Print measurement
        disp('----------------------------------------')
        disp(horzcat('Plotting Measurement ', num2str(i), ': '))
        disp(measurements(i))
    
        % Find voltage and strain after initialization
        idx = find(measurements(i).time>=2.75 & measurements(i).time<=3.0);
        afterInitVoltage = mean(measurements(i).voltage(idx));
        afterInitStrain = mean(measurements(i).strain(idx));
%         endIdx = find(measurements(i).time>=4.25 & measurements(i).time<=4.5, 1, 'last');
        endIdx = length(measurements(i).time);
        
        % Strain vs Time plot
        figure; grid on; hold on;
        plot(measurements(i).time(1:endIdx), ...
            measurements(i).strain(1:endIdx) - afterInitStrain)
        xlabel('Time (s)')
        ylabel('Deformation (nm)')
        title(horzcat('Measurement ', num2str(i), ': ', ...
                        measurements(i).sampleName, ...
                        ' [', measurements(i).error, ']'), ...
                        'interpreter', 'none')
        
        % Voltage vs Time plot
        figure; grid on; hold on;
        plot(measurements(i).time(1:endIdx), ...
            measurements(i).voltage(1:endIdx) - afterInitVoltage)
        xlabel('Time (s)')
        ylabel('Voltage (V)')
        title(horzcat('Measurement ', num2str(i), ': ', ...
                        measurements(i).sampleName, ...
                        ' [', measurements(i).error, ']'), ...
                        'interpreter', 'none')
        
        % Voltage vs Strain plot
        figure; grid on; hold on;
        plot(measurements(i).voltage(1:endIdx) - afterInitVoltage, ...
            measurements(i).strain(1:endIdx) - afterInitStrain)
        xlabel('Voltage (V)')
        ylabel('Deformation (nm)')
        title(horzcat('Measurement ', num2str(i), ': ', ...
                        measurements(i).sampleName, ...
                        ' [', measurements(i).error, ']'), ...
                        'interpreter', 'none')

        % Create data handler
        dataHandler = DataHandler(measurements(i).voltage(1:endIdx) - afterInitVoltage, ...
            measurements(i).strain(1:endIdx) - afterInitStrain, ...
            measurements(i).time(1:endIdx));
    end
end

