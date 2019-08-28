close all
clc

% Print all measurements names
for i=1:length(measurements), disp(measurements(i).sampleName), end

% Select base name
baseName = 'RMN_1400V_500V_';
% baseName = 'RMN_1400V_1000V_';

% Map to save remnants, the key is pulse amplitude and
% all remnants with same pulse amplitude will be averaged
remnants = containers.Map('KeyType', 'double', 'ValueType', 'any');

% Start voltages loop
for voltage=200:100:1600
    
    % Build the full name of the measurement with voltage
    fullName = strcat([baseName, num2str(voltage), 'V']);
    
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
                
                remnant.voltageTrain = 0;
                remnant.strainTrain = 0;
            end
            
            % Find and add voltage offset and initial strain
            idx = find(measurements(i).time>=2.75 & measurements(i).time<=3.0);
            remnant.voltageOffset = remnant.voltageOffset + mean(measurements(i).voltage(idx));
            remnant.offsetStrain = remnant.offsetStrain + mean(measurements(i).strain(idx));
            
            % Find and add first voltage pulse
            idx = find(measurements(i).time>=3.25 & measurements(i).time<=3.5);
            remnant.voltagePulse = remnant.voltagePulse + max(measurements(i).voltage(idx));
            
            % Find and add train voltage pulse
            idx = find(measurements(i).time>=5.25 & measurements(i).time<=5.75);
            remnant.voltageTrain = remnant.voltageTrain + max(measurements(i).voltage(idx));
            
            % Find and add first pulse remnant
            idx = find(measurements(i).time>=4.75 & measurements(i).time<=5.0);
            remnant.finalStrain = remnant.finalStrain + mean(measurements(i).strain(idx));
            
            % Find and add train remnant
            idx = find(measurements(i).time>=6.75 & measurements(i).time<=7.0);
            remnant.strainTrain = remnant.strainTrain + mean(measurements(i).strain(idx));
            
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

strainTrain = [];
voltageTrain = [];

remnants = values(remnants);
for i=1:length(remnants)
    voltagePulse = [voltagePulse; remnants{i}.voltagePulse/remnants{i}.repeatedCounter];
    voltageOffset = [voltageOffset; remnants{i}.voltageOffset/remnants{i}.repeatedCounter];
    offsetStrain = [offsetStrain; remnants{i}.offsetStrain/remnants{i}.repeatedCounter];
    finalStrain = [finalStrain; remnants{i}.finalStrain/remnants{i}.repeatedCounter];
    initMaxStrain = [initMaxStrain; remnants{i}.initMaxStrain/remnants{i}.repeatedCounter];
    pulseMaxStrain = [pulseMaxStrain; remnants{i}.pulseMaxStrain/remnants{i}.repeatedCounter];
    minStrain = [minStrain; remnants{i}.minStrain/remnants{i}.repeatedCounter];
    
    strainTrain = [strainTrain; remnants{i}.strainTrain/remnants{i}.repeatedCounter];
    voltageTrain = [voltageTrain; remnants{i}.voltageTrain/remnants{i}.repeatedCounter];
end

% Plot Remnant vs Pulse amplitude
figure
plot(voltageTrain-voltageOffset, strainTrain-finalStrain, '-o')
xlabel('Pulse Amp (V)')
ylabel('Remnant Change (nm)')
grid on
ylim([-170,50])
% ylim([-50,400])
