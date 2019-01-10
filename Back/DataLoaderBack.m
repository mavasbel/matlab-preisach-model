clear all
close all
clc

% Batch flag
isBatch = false

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PNZT_VI_TiPt(300)_3h
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\VI\V900-0.5Hz.csv');
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\VI\V1000-0.5Hz.csv');
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\VI\V1100-0.5Hz.csv');
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\VI\V1200-0.5Hz.csv');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PNZT_VIII_-TiAu-TiAu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\VIII\V700.csv');
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\VIII\V900.csv');
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\VIII\V1100.csv');
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\VIII\V1300.csv');
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\VIII\V1400.csv');
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\VIII\V1500.csv');
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\VIII\V1600.csv');
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\VIII\V1800.csv');
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\VIII\V2000.csv');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PNZT_IX_TiAu 300-100_4_mix6h
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\IX\V1000-0.5Hz.csv');
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\IX\V1100-0.5Hz.csv');
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\IX\V1200-0.5Hz.csv');
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\IX\V1300-0.5Hz.csv');
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\IX\V1400-0.5Hz.csv');
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\IX\V1500-0.5Hz.csv');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PNZT_XIII_TiAu_mix18h
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\XIII\kV1.7.csv');
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\XIII\kV1.9.csv');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PNZT_XIV_TiAu_7_mix42h
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\XIV\V1400.csv');
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\XIV\V1500.csv');
% [ndata, text, alldata] = xlsread('Grain Multi-Size Fitting\PNZT_loops_difGrainSize\XIV\V1600.csv');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Others
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Seqs generation and plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
header = string(strsplit(char(alldata(1,:)),','));
columns = size(header,2);
rows = size(alldata,1) - 1;
matrix = zeros(rows,columns);
for k=1:rows
    matrix(k,:) = str2double(strsplit(char(alldata(k+1)),','));
end
    
time = matrix(:,1);
inputSeq = matrix(:,3);
outputSeq = matrix(:,11);

figure
plot(inputSeq, outputSeq, 'r')
legend('Data to fit')
