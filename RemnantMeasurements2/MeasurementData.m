classdef MeasurementData < matlab.mixin.SetGet
    properties
        timestamp
        sampleName
        waveform
        error
        
        time
        strain
        current
        voltage
    end
end