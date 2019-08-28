classdef PlotData < matlab.mixin.SetGet
    
    properties
        initMaxStrain = [];
        initMinStrain = [];
        
        afterInitVoltage = [];
        afterInitStrain = [];
        
        pulse1MaxVoltage = [];
        pulse1MaxStrain = [];
        afterPulse1Strain = [];
        
        pulse2MaxVoltage = [];
        pulse2MaxStrain = [];
        afterPulse2Strain = [];
    end
    
end