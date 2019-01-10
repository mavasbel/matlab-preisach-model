clear all
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input output data from ZIAM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data = load('Serie1.mat');
% inputSerie = data.V_S1_1300V_05Hz; outputSerie = data.D1_S1_1300V_05Hz;
% inputSerie = data.V_S1_1400V_05Hz; outputSerie = data.D1_S1_1400V_05Hz;
% inputSerie = data.V_S1_1500V_05Hz; outputSerie = data.D1_S1_1500V_05Hz;
inputSerie = data.V_S1_1600V_05Hz; outputSerie = data.D1_S1_1600V_05Hz;

% inputSerie = [data.V_S1_1300V_05Hz; data.V_S1_1400V_05Hz; data.V_S1_1500V_05Hz; data.V_S1_1600V_05Hz];
% outputSerie = [data.D1_S1_1300V_05Hz; data.D1_S1_1400V_05Hz; data.D1_S1_1500V_05Hz; data.D1_S1_1600V_05Hz];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input output data from ZIAM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% data = load('MeasurementData.mat');
% inputSerie = data.Vplus_1kv; outputSerie = data.Displacement_1kv;
% inputSerie = data.Vplus_08kv; outputSerie = data.Displacement_08kv;
% inputSerie = data.Vplus_11kv; outputSerie = data.Displacement_11kv;
% inputSerie = data.Vplus_15kv; outputSerie = data.Displacement_15kv;
% inputSerie = data.Vplus_19kv; outputSerie = data.Displacement_19kv;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure
plot(inputSerie, outputSerie, 'r')
legend('Data to fit')