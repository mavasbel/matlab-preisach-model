clear all
close all
clc

isBatch = true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Paths to look for files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lookupPaths = [
"G:\My Drive\MATLAB\PhD\Results\Experimental Data\PNZT loops_dif_concentrations\PNZT_x0.47_mix";
"G:\My Drive\MATLAB\PhD\Results\Experimental Data\PNZT loops_dif_concentrations\PNZT_x0.48_mix";
"G:\My Drive\MATLAB\PhD\Results\Experimental Data\PNZT loops_dif_concentrations\PNZT_x0.465_mix";
"G:\My Drive\MATLAB\PhD\Results\Experimental Data\PNZT loops_dif_concentrations\PNZT_x0.475_mix";
];
fitMatchFilter = '';
compMatchFilter = '';
skipFilter = '.*(uni).*';

% fitMatchFilter = 'PNZT_x0.48_.*difV.*1600V';
% fitMatchFilter = 'PNZT_x0.48_.*x3.*1600V';
% compMatchFilter = 'PNZT_x0.48_.*x3.*';

% fitMatchFilter = 'PNZT_x0.475_.*difV.*1200V';
% fitMatchFilter = 'PNZT_x0.475_.*x3.*1200V';
% compMatchFilter = 'PNZT_x0.475_.*x3.*';

fitMatchFilter = 'PNZT_x0.47_.*difV.*1800V';
% fitMatchFilter = 'PNZT_x0.47_.*x3.*1400V';
% compMatchFilter = 'PNZT_x0.47_.*(x3|difV.*1400V).*';
compMatchFilter = 'PNZT_x0.47_.*(x3).*';

% fitMatchFilter = 'PNZT_x0.465_.*difV.*1600V';
% fitMatchFilter = 'PNZT_x0.465_.*x3.*1400V';
% compMatchFilter = 'PNZT_x0.465_.*x3.*';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fitting data handler and model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fitFileHandlers = FileHandler.lookForFiles(lookupPaths, fitMatchFilter, skipFilter);
fitFileHandlers(1).printInfo();
dataHandler = fitFileHandlers(1).getDataHandler();

% fitFileHandlers = getFileHandlers(lookupPaths, fitMatchFilter, skipFilter);
% for i=length(fitFileHandlers):-1:1
%     fitFileHandlers(i).printInfo();
%     dataHandler = fitFileHandlers(i).getDataHandler();
%     dataHandler.trimFirstZeroCrossInput(); 
% end
% dataHandler = DataHandler([
%     fitFileHandlers(3).getDataHandler().inputSeq;
%     fitFileHandlers(2).getDataHandler().inputSeq;
%     fitFileHandlers(1).getDataHandler().inputSeq;],...
%     [fitFileHandlers(3).getDataHandler().outputSeq;
%     fitFileHandlers(2).getDataHandler().outputSeq;
%     fitFileHandlers(1).getDataHandler().outputSeq;]);

run('./FitModel.m');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Comparing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
allRealPlots = PreisachPlots();
allModelPlots = PreisachPlots();
compFileHandlers = FileHandler.lookForFiles(lookupPaths, compMatchFilter, skipFilter);
for i=1:length(compFileHandlers) 
    disp('---------------------------------------------------------------');
    compFileHandlers(i).printInfo();
    
    dataHandler = compFileHandlers(i).getDataHandler();
    dataHandler.interpSequence(1000);
    dataHandler.printInfo();
    allRealPlots.plotInputSubFig(1:dataHandler.origSampleLength, ...
        dataHandler.origInputSeq, compFileHandlers(i).fileName);
    allRealPlots.plotOutputSubFig(1:dataHandler.origSampleLength, ...
        dataHandler.origOutputSeq, compFileHandlers(i).fileName);
    allRealPlots.plotLoopFig(dataHandler.inputSeq, ...
        dataHandler.outputSeq, compFileHandlers(i).fileName);
    title('Real', 'Interpreter', 'none');

    preisachRelayModel.resetRelaysOff();
%     preisachRelayModel.setRelaysWindowValue(1,1,preisachRelayModel.gridSize,1,30);
    [compOutputSeq, compRelaysSeq] = preisachUtils.generateOutputSeq(dataHandler.inputSeq);
    
    allModelPlots.plotLoopFig(dataHandler.inputSeq, ...
        compOutputSeq, compFileHandlers(i).fileName);
    title('Model', 'Interpreter', 'none');
    
    compPlots = PreisachPlots();
%     compPlots.plotInputSubFig(1:dataHandler.origSampleLength, dataHandler.origInputSeq, 'Input', 'r');
%     title(compFileHandlers(i).fileName, 'Interpreter', 'none');
%     compPlots.plotOutputSubFig(1:dataHandler.origSampleLength, dataHandler.origOutputSeq, 'Real Output', 'r');
%     compPlots.plotOutputSubFig(dataHandler.indexesSeq, compOutputSeq, 'Model Output', 'b');
%     title(compFileHandlers(i).fileName, 'Interpreter', 'none');
    compPlots.plotLoopFig(dataHandler.inputSeq, dataHandler.outputSeq, 'Real', 'r');
    compPlots.plotLoopFig(dataHandler.inputSeq, compOutputSeq, 'Model', 'b');
    title(compFileHandlers(i).fileName, 'Interpreter', 'none');
end
isBatch = false;