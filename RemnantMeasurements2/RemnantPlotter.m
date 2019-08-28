close all
clc

% Print all measurements names
for i=1:length(measurements), disp(measurements(i).sampleName), end

% Select base name
baseName = 'RMN_1400V_';

% Map to save remnants, the key is pulse amplitude and
% all remnants with same pulse amplitude will be averaged
remnants = containers.Map('KeyType', 'double', 'ValueType', 'any');

% Start voltages loop
for voltage=200:100:1600
    
    % Build the full name of the measurement with voltage
    fullName = strcat([baseName, num2str(voltage), 'V_100V']);
%     fullName = strcat([baseName, num2str(voltage), 'V']);
    
    % Start measurments loop
    for i=1:length(measurements)
        
        % If measurment has no error and name coincides
        if strcmp(measurements(i).sampleName, fullName)>0 && ...
            isempty(measurements(i).error) && ...
            strcmp(measurements(i).waveform, 'Manual1')>0
            
            try
                % Get remnant if exists
                remnant = remnants(voltage);
                remnant.repeatedCounter = remnant.repeatedCounter + 1;
            catch
                % If doesn't exists create remnant
                remnant = RemnantClass();
                remnant.repeatedCounter = 1;
                remnant.voltagePulse = 0;
                remnant.voltageOffset = 0;
                remnant.offsetStrain = 0;
                remnant.finalStrain = 0;
                remnant.initMaxStrain = 0;
                remnant.pulseMaxStrain = 0;
                remnant.minStrain = 0;
            end
            
            % Find and add voltage pulse peak
            idx = find(measurements(i).time>=3.125 & measurements(i).time<=3.375);
            remnant.voltagePulse = remnant.voltagePulse + max(measurements(i).voltage(idx));
            
            % Find and add voltage offset and initial strain
            idx = find(measurements(i).time>=2.75 & measurements(i).time<=3.0);
            remnant.voltageOffset = remnant.voltageOffset + mean(measurements(i).voltage(idx));
            remnant.offsetStrain = remnant.offsetStrain + mean(measurements(i).strain(idx));
            
            % Find and add final strain
            idx = find(measurements(i).time>=4.25 & measurements(i).time<=4.5);
            remnant.finalStrain = remnant.finalStrain + mean(measurements(i).strain(idx));
            
            % Find and add max strain during initialization
            idx = find(measurements(i).time>=1.2 & measurements(i).time<=1.3);
            remnant.initMaxStrain = remnant.initMaxStrain + max(measurements(i).strain(idx));
            
            % Find and add max strain during pulse
            idx = find(measurements(i).time>=3.2 & measurements(i).time<=3.3);
            remnant.pulseMaxStrain = remnant.pulseMaxStrain + max(measurements(i).strain(idx));
            
            % Add min strain
            remnant.minStrain = remnant.minStrain + min(measurements(i).strain);
            
            % Add or replace remnant in map
            remnants(voltage) = remnant;
        end
        
    end
end

% Convert map to array taking average into account
voltagePulse = [];
voltageOffset = [];
offsetStrain = [];
finalStrain = [];
initMaxStrain = [];
pulseMaxStrain = [];
minStrain = [];
remnants = values(remnants);
for i=1:length(remnants)
    voltagePulse = [voltagePulse; remnants{i}.voltagePulse/remnants{i}.repeatedCounter];
    voltageOffset = [voltageOffset; remnants{i}.voltageOffset/remnants{i}.repeatedCounter];
    offsetStrain = [offsetStrain; remnants{i}.offsetStrain/remnants{i}.repeatedCounter];
    finalStrain = [finalStrain; remnants{i}.finalStrain/remnants{i}.repeatedCounter];
    initMaxStrain = [initMaxStrain; remnants{i}.initMaxStrain/remnants{i}.repeatedCounter];
    pulseMaxStrain = [pulseMaxStrain; remnants{i}.pulseMaxStrain/remnants{i}.repeatedCounter];
    minStrain = [minStrain; remnants{i}.minStrain/remnants{i}.repeatedCounter];
end

% Plot Remnant vs Pulse amplitude
figure
plot(voltagePulse-voltageOffset, finalStrain-offsetStrain, '-o')
xlabel('Pulse Amp (V)')
ylabel('Deformation (nm)')
grid on

% hold on
% plot(voltagePulse-voltageOffset, initMaxStrain-offsetStrain, '-o')
% plot(voltagePulse-voltageOffset, pulseMaxStrain-offsetStrain, '-o')
% legend('Remnant','Initialization Max','Pulse Max')