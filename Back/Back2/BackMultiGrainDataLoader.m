clear all
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Files names array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileFullPaths = [
% PNZT_VI_TiPt(300)_3h
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/VI/V900-0.5Hz.csv";
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/VI/V1000-0.5Hz.csv";
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/VI/V1100-0.5Hz.csv";
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/VI/V1200-0.5Hz.csv";
% PNZT_VIII_-TiAu-TiAu
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/VIII/V700.csv";
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/VIII/V900.csv";
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/VIII/V1100.csv";
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/VIII/V1300.csv";
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/VIII/V1400.csv";
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/VIII/V1500.csv";
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/VIII/V1600.csv";
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/VIII/V1800.csv";
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/VIII/V2000.csv";
% PNZT_IX_TiAu 300-100_4_mix6h
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/IX/V1000-0.5Hz.csv";
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/IX/V1100-0.5Hz.csv";
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/IX/V1200-0.5Hz.csv";
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/IX/V1300-0.5Hz.csv";
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/IX/V1400-0.5Hz.csv";
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/IX/V1500-0.5Hz.csv";
% PNZT_XIII_TiAu_mix18h
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/XIII/kV1.7.csv";
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/XIII/kV1.9.csv";
% PNZT_XIV_TiAu_7_mix42h
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/XIV/V1400.csv";
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/XIV/V1500.csv";
"Grain Multi-Size Fitting/PNZT_loops_difGrainSize/XIV/V1600.csv"
];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Series generation and plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:length(fileFullPaths)
    [fileName, filePath, inputSerie, outputSerie, time] = readCSV(fileFullPaths(i));
    
    %Run fitting
    run("PreisachFit.m");
    
    folders = regexp(filePath, '/', 'split');
    %Save figures
    saveas(loopFig, strcat(filePath, "/Fitting results/Loop-", fileName, ".png") );
    saveas(planeFig, strcat(filePath, "/Fitting results/Plane-", fileName, ".png") );
    saveas(loopFig, strcat(folders(1), "/", folders(2), "/All/Loop-", folders(3), "-", fileName, ".png") );
    saveas(planeFig, strcat(folders(1), "/", folders(2), "/All/Plane-", folders(3), "-", fileName, ".png") );
    saveas(subFig, strcat(folders(1), "/", folders(2), "/All/Subfig-", folders(3), "-", fileName, ".png") );
end

clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fileName, filePath, inputSerie, outputSerie, time] = readCSV(fileFullPath)
    [filePath, fileName] = fileparts(fileFullPath);
    csv = xlsread(fileFullPath);
    time = csv(:,1);
    inputSerie = csv(:,3);
    outputSerie = csv(:,12);
end