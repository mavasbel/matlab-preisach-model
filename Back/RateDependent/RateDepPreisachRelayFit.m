close all;
if (~exist('isBatch', 'var') || isBatch ~= true) clc; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data handler and model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataHandler.resetOrigSequences();
dataHandler.interpSequence(401*2);
dataHandler.printInfo();

inputInterFact = -0.05;
inputInter = abs(dataHandler.inputMax - dataHandler.inputMin);
preisachRelayModel = RateDepPreisachRelayModel([dataHandler.inputMin-inputInter*inputInterFact, ...
    dataHandler.inputMax+inputInter*inputInterFact], 80);
preisachRelayModel.printInfo();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot originals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
preisachPlots = PreisachPlots();
preisachPlots.plotInputSubFig(1:dataHandler.origSampleLength, dataHandler.origInputSeq, 'Original Input', 'r');
preisachPlots.plotInputSubFig(dataHandler.indexesSeq, dataHandler.inputSeq, 'Adjusted Input', 'b');
preisachPlots.plotOutputSubFig(1:dataHandler.origSampleLength, dataHandler.origOutputSeq, 'Original Output', 'r');
preisachPlots.plotOutputSubFig(dataHandler.indexesSeq, dataHandler.outputSeq, 'Adjusted Output', 'b');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fitting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
preisachUtils = RateDepPreisachRelayUtils(preisachRelayModel);
[filterTime, fittingTime, weightFuncTime] = preisachUtils...
    .fitModel(dataHandler.inputSeq, dataHandler.outputSeq);

% Generating fitted output
fittedOutputTic = tic;
preisachRelayModel.resetRelaysOff();
[fittedOutputSeq, fittedRelaysSeq] = preisachUtils.generateOutputSeq(dataHandler.inputSeq);
fittedOutputTime = toc(fittedOutputTic);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Error calculation
printFittingInfo(dataHandler, fittedOutputSeq(:), filterTime, fittingTime, weightFuncTime, fittedOutputTime);

% Add fitted curve and weight plane
preisachPlots.plotOutputSubFig(dataHandler.indexesSeq, fittedOutputSeq, 'Fitted Output', 'k');
preisachPlots.plotIOSubFig(dataHandler.inputSeq, dataHandler.outputSeq, 'Real data', 'r');
preisachPlots.plotIOSubFig(dataHandler.inputSeq, fittedOutputSeq, 'Fitted result', 'b');
preisachPlots.plotSurfaceSubFig(preisachRelayModel.weightFunc, preisachRelayModel.xyGrid);
preisachPlots.plotSurfaceFig(preisachRelayModel.rateWeightFunc, preisachRelayModel.xyGrid);

run('./SimulinkParams');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function printFittingInfo(dataHandler, fittedOutputSeq, filterTime, fittingTime, weightFuncTime, fittedOutputTime)
    errorVector = abs( fittedOutputSeq(:) - dataHandler.outputSeq(:) );
    relativeErrorVector = errorVector./abs(dataHandler.outputMax - dataHandler.outputMin);
    disp('--Fit results--');
    disp(['Filtering time: ', num2str(mean(filterTime)), ' seconds']);
    disp(['Fitting time: ', num2str(mean(fittingTime)), ' seconds']);
    disp(['Weightplane time: ', num2str(mean(weightFuncTime)), ' seconds']);
    disp(['Output time: ', num2str(mean(fittedOutputTime)), ' seconds']);
    disp(['Min absolute error: ', num2str(min(errorVector))]);
    disp(['Max absolute error: ', num2str(max(errorVector))]);
    disp(['Mean absolute error: ', num2str(mean(errorVector))]);
    disp(['Min relative error: ', num2str(min(relativeErrorVector))]);
    disp(['Max relative error: ', num2str(max(relativeErrorVector))]);
    disp(['Mean relative error: ', num2str(mean(relativeErrorVector))]);
end