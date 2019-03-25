clear all
close all
clc

isBatch = true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Paths to look for files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lookupPaths = [
"G:\My Drive\MATLAB\Project\Results\Experimental Data\PNZT loops_dif_concentrations\PNZT_x0.47_mix";
"G:\My Drive\MATLAB\Project\Results\Experimental Data\PNZT loops_dif_concentrations\PNZT_x0.48_mix";
"G:\My Drive\MATLAB\Project\Results\Experimental Data\PNZT loops_dif_concentrations\PNZT_x0.465_mix";
"G:\My Drive\MATLAB\Project\Results\Experimental Data\PNZT loops_dif_concentrations\PNZT_x0.475_mix";
"G:\My Drive\MATLAB\Project\Results\Experimental Data\PNZT_loops_difGrainSize\VI";
"G:\My Drive\MATLAB\Project\Results\Experimental Data\PNZT_loops_difGrainSize\VIII";
"G:\My Drive\MATLAB\Project\Results\Experimental Data\PNZT_loops_difGrainSize\IX";
"G:\My Drive\MATLAB\Project\Results\Experimental Data\PNZT_loops_difGrainSize\XIII";
"G:\My Drive\MATLAB\Project\Results\Experimental Data\PNZT_loops_difGrainSize\XIV";
];
fitMatchFilter = '';
skipFilter = '.*(uni).*';

% fitMatchFilter = 'PNZT_.*difV.*';
% fitMatchFilter = 'PNZT_.*x3.*';
% fitMatchFilter = 'PNZT_x0.48_.*difV.*1600V';
% fitMatchFilter = 'PNZT_x0.48_.*x3.*1600V';
% fitMatchFilter = 'PNZT_x0.475_.*difV.*1200V';
% fitMatchFilter = 'PNZT_x0.475_.*x3.*1200V';
% fitMatchFilter = 'PNZT_x0.47_.*difV.*1800V';
fitMatchFilter = 'PNZT_x0.47_.*x3.*1400V';
% fitMatchFilter = 'PNZT_x0.47_.*x3.*';
% fitMatchFilter = 'PNZT_x0.465_.*difV.*1600V';
% fitMatchFilter = 'PNZT_x0.465_.*x3.*1400V';
% fitMatchFilter = 'PNZT_x0.465_.*x3.*';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fitting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fitFileHandlers = DataLoader.getFileHandlers(lookupPaths, fitMatchFilter, skipFilter);
for fhCount=1:length(fitFileHandlers)
    disp('---------------------------------------------------------------');
    fitFileHandlers(fhCount).printInfo();
    dataHandler = fitFileHandlers(fhCount).getDataHandler();

    run('./PreisachRelayFit');
%     saveas(preisachPlots.loopPlaneFig  , strcat(cd, "\Fitting results\LoopPlane-"  , fitFileHandlers(fhCount).fileName, ".png") );
%     saveas(preisachPlots.inputOutputFig, strcat(cd, "\Fitting results\InputOutput-", fitFileHandlers(fhCount).fileName, ".png") );
end
isBatch = false;