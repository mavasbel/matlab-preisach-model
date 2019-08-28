close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name prefix, suffix, and time limits for triangular inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% namePrefix = 'RMN_1400V_';
% nameSuffix = 'V_100V';
% initTimeLimits = [0, 2.0];
% afterInitTimeLimits = [2.75, 3.0];
% pulse1TimeLimits = [3.125, 3.375];
% afterPulse1TimeLimits = [4.25, 4.5];

% namePrefix = 'RMN_1200V_';
% nameSuffix = 'V_100V';
% initTimeLimits = [0, 2.0];
% afterInitTimeLimits = [2.75, 3.0];
% pulse1TimeLimits = [3.125, 3.375];
% afterPulse1TimeLimits = [4.25, 4.5];

% namePrefix = 'RMN_FADE_';
% nameSuffix = 'V';
% initTimeLimits = [0, 8.0];
% afterInitTimeLimits = [8.75, 9.0];
% pulse1TimeLimits = [9.0, 10.0];
% afterPulse1TimeLimits = [10.75, 11.0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name prefix, suffix, and time limits for trapezoidal inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% namePrefix = 'RMN_1200V_';
% nameSuffix = 'V';
% initTimeLimits = [0, 2.0];
% afterInitTimeLimits = [2.75, 3.0];
% pulse1TimeLimits = [3.025, 3.075];
% afterPulse1TimeLimits = [4.75, 5.0];

% namePrefix = 'RMN_1400V_';
% nameSuffix = 'V';
% initTimeLimits = [0, 2.0];
% afterInitTimeLimits = [2.75, 3.0];
% pulse1TimeLimits = [3.025, 3.075];
% afterPulse1TimeLimits = [4.75, 5.0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Print all measurements names
for i=1:length(measurements), disp(measurements(i).sampleName), end

% Map to save remnants, the key is pulse amplitude and
% all remnants with same pulse amplitude will be averaged
remnants = containers.Map('KeyType', 'double', 'ValueType', 'any');

% Start voltages loop
for voltage=200:100:1600
    
    % Build the full name of the measurement with voltage
    fullName = strcat([namePrefix, num2str(voltage), nameSuffix]);
    
    % Start measurments loop
    for i=1:length(measurements)
        
        % If measurment has no error and name coincides
        if strcmp(measurements(i).sampleName, fullName)>0 && ...
            isempty(measurements(i).error) && ...
            strcmp(measurements(i).waveform, 'ManualWaveform: 1')>0
            try % Get remnant if exists
                remnant = remnants(voltage);
            catch % If doesn't exists create remnant
                remnant = PlotData();
            end
            
            % Find and add max and min strain during initialization
            idx = find(measurements(i).time>=initTimeLimits(1) & measurements(i).time<=initTimeLimits(2));
            remnant.initMaxStrain = [remnant.initMaxStrain, max(measurements(i).strain(idx))];
            remnant.initMinStrain = [remnant.initMinStrain, min(measurements(i).strain(idx))];
            
            % Find and add voltage and strain after initialization
            idx = find(measurements(i).time>=afterInitTimeLimits(1) & measurements(i).time<=afterInitTimeLimits(2));
            remnant.afterInitVoltage = [remnant.afterInitVoltage, mean(measurements(i).voltage(idx))];
            remnant.afterInitStrain = [remnant.afterInitStrain, mean(measurements(i).strain(idx))];
            
            % Find and add max voltage and strain during pulse 1
            idx = find(measurements(i).time>=pulse1TimeLimits(1) & measurements(i).time<=pulse1TimeLimits(2));
            remnant.pulse1MaxVoltage = [remnant.pulse1MaxVoltage, max(measurements(i).voltage(idx))];
            remnant.pulse1MaxStrain = [remnant.pulse1MaxStrain, max(measurements(i).strain(idx))];
            
            % Find and add strain after pulse 1
            idx = find(measurements(i).time>=afterPulse1TimeLimits(1) & measurements(i).time<=afterPulse1TimeLimits(2));
            remnant.afterPulse1Strain = [remnant.afterPulse1Strain, mean(measurements(i).strain(idx))];
            
            % Add or replace remnant in map
            remnants(voltage) = remnant;
        end
    end
end

% Convert map to array
remnants = values(remnants);

% Compute averages
averages = PlotData();
props = properties(PlotData);
for i=1:length(remnants)
    for j=1:length(props)
        set(averages, props{j}, ...
            [get(averages, props{j}), mean( get(remnants{i},props{j}) )] )
    end
end

% Plot remnant vs pulse 1 amplitude
figure; hold on; grid on;
plot(averages.pulse1MaxVoltage-averages.afterInitVoltage, ...
    averages.afterPulse1Strain-averages.afterInitStrain,...
    '-o', ...
    'MarkerSize', 5)
for i=1:length(remnants) % Add each measurement independent
    for j=1:length(remnants{i}.pulse1MaxVoltage)
        plot(remnants{i}.pulse1MaxVoltage(j)-remnants{i}.afterInitVoltage(j), ...
            remnants{i}.afterPulse1Strain(j)-remnants{i}.afterInitStrain(j), ...
            'o', ...
            'Color', zeros(1,3), ...
            'MarkerSize', 4)
    end
end
xlabel('Pulse Amp (V)')
ylabel('Deformation (nm)')


