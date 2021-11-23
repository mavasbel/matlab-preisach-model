close all
clc

% Print all measurements names
for i=1:length(measurements), disp(measurements(i).sampleName), end

% Name of measurement to plot
fullName = 'RMN_1400V_1000V_600V';

for i=1:length(measurements)
    if strcmp(measurements(i).sampleName, fullName)>0 && ...
        strcmp(measurements(i).waveform, 'ManualWaveform: 1')>0 
        
        % Print measurement
        disp('----------------------------------------')
        disp(horzcat('Plotting Measurement ', num2str(i), ': '))
        disp(measurements(i))
    
        % Find voltage and strain after initialization
        idx = find(measurements(i).time>=2.75 & measurements(i).time<=3.0);
%         idx = find(measurements(i).time>=8.75 & measurements(i).time<=9.0);
        afterInitVoltage = mean(measurements(i).voltage(idx));
        afterInitStrain = mean(measurements(i).strain(idx));
        
        % Find index of final time
        endIdx = length(measurements(i).time);
%         endIdx = find(measurements(i).time>=4.25 & measurements(i).time<=4.5, 1, 'last');
%         endIdx = find(measurements(i).time>=4.75 & measurements(i).time<=5.0, 1, 'last');
%         endIdx = find(measurements(i).time>=5.75 & measurements(i).time<=6.0, 1, 'last');
%         endIdx = find(measurements(i).time>=6.75 & measurements(i).time<=7.0, 1, 'last');
        
        % Strain vs Time plot
        figure(); grid on; hold on;
        plot(measurements(i).time(1:endIdx), ...
            measurements(i).strain(1:endIdx) - afterInitStrain, ...
            '-b','LineWidth',1.25, ...
            'DisplayName', horzcat('Measurement ', num2str(i), ': ', ...
                                measurements(i).sampleName, ...
                                ' [', measurements(i).error, ']') )
        xlabel('Time ($s$)', 'interpreter', 'latex')
        ylabel('Strain ($nm$)', 'interpreter', 'latex')
        legend('interpreter', 'none', 'visible', 'off')
        xlim([0,6])
        
        % Voltage vs Time plot
        figure(); grid on; hold on;
        plot(measurements(i).time(1:endIdx), ...
            measurements(i).voltage(1:endIdx) - afterInitVoltage, ...
            '-b','LineWidth',1.25, ...
            'DisplayName', horzcat('Measurement ', num2str(i), ': ', ...
                                measurements(i).sampleName, ...
                                ' [', measurements(i).error, ']') )
        xlabel('Time ($s$)', 'interpreter', 'latex')
        ylabel('Voltage ($V$)', 'interpreter', 'latex')
        legend('interpreter', 'none', 'visible', 'off')
        xlim([0,6])
        
        % Voltage vs Strain plot
        figure(); grid on; hold on;
        plot(measurements(i).voltage(1:endIdx) - afterInitVoltage, ...
            measurements(i).strain(1:endIdx) - afterInitStrain, ...
            'DisplayName', horzcat('Measurement ', num2str(i), ': ', ...
                                measurements(i).sampleName, ...
                                ' [', measurements(i).error, ']') )
        xlabel('Voltage ($V$)', 'interpreter', 'latex')
        ylabel('Strain ($nm$)', 'interpreter', 'latex')
        legend('interpreter', 'none')
        
        % Create data handler
        dataHandler = DataHandler(measurements(i).voltage(1:endIdx) - afterInitVoltage, ...
            measurements(i).strain(1:endIdx) - afterInitStrain, ...
            measurements(i).time(1:endIdx));
    end
end

