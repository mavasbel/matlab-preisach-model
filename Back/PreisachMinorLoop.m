if (isBatch ~= true) clc; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dataHandler = DataHandler(origInputSeq, origOutputSeq);
dataHandler.resetOrigSequences();
dataHandler.trimSecondMaxLastMinInput();
dataHandler.repeatNotPeriodic();
dataHandler.interpSequence(1000);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input, Output, Fitting parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(['--Fitting parameters--']);
disp(['Original data length: ', num2str(dataHandler.origSampleLength)]);
disp(['Adjusted data length: ', num2str(dataHandler.sampleLength)]);
disp(['Min input: ', num2str(dataHandler.inputMin)]);
disp(['Max input: ', num2str(dataHandler.inputMax)]);
disp(['Min output: ', num2str(dataHandler.outputMin)]);
disp(['Max output: ', num2str(dataHandler.outputMax)]);

% Plot input and output
inputOutputFig = figure;
currentPos = get(inputOutputFig, 'Position');
set(inputOutputFig, 'Position', currentPos.*[1 1 2 1] + [-currentPos(3)/2 0 0 0] );

inputSubFig = subplot(1,2,1); hold on; grid on;
plot(1:dataHandler.origSampleLength, dataHandler.origInputSeq, 'r');
plot(dataHandler.indexesSeq, dataHandler.inputSeq, 'b');
currentPos = get(inputSubFig, 'Position');
set(inputSubFig, 'Position', currentPos.*[0.9 1 1 1] + [0 0 0 0] );
legend('Original Input', 'Adjusted Input');

outputSubFig = subplot(1,2,2); hold on; grid on;
plot(1:dataHandler.origSampleLength, dataHandler.origOutputSeq, 'r');
plot(dataHandler.indexesSeq, dataHandler.outputSeq, 'b');
currentPos = get(outputSubFig, 'Position');
set(outputSubFig, 'Position', currentPos.*[1.0 1 1 1] + [0 0 0 0] );
legend('Original Output', 'Adjusted Output');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fitting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

preisachUtils = PreisachRelayUtils(preisachRelayModel);

% Generating fitted output
fittedOutputTic = tic;
preisachRelayModel.resetRelaysOff();
% preisachRelayModel.setRelaysUpperLeftCorner(dataHandler.inputMin);
[fittedOutputSeq, fittedRelaysSeq] = preisachUtils.generateOutputSeq(dataHandler.inputSeq);
% fittedOutputSeq = fittedOutputSeq + 150;
fittedOutputTime = toc(fittedOutputTic);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Error calculation
errorVector = abs( fittedOutputSeq(:) - dataHandler.outputSeq(:) );
relativeErrorVector = errorVector./abs(dataHandler.outputMax - dataHandler.outputMin);
disp(['--Results--']);
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

% Add fitted curve and weight plane
outputSubFig;
plot(dataHandler.indexesSeq, fittedOutputSeq, 'k');
legend('Original Output', 'Adjusted Output', 'Fitted Output');

% Plot fitted curve and weight plane
loopPlaneFig = figure;
currentPos = get(loopPlaneFig, 'Position');
set(loopPlaneFig, 'Position', currentPos.*[1 1 2 1] + [-currentPos(3)/2 0 0 0] );

loopSubFig = subplot(1,2,1); hold on; grid on;
plot(dataHandler.origInputSeq, dataHandler.origOutputSeq, 'r');
plot(dataHandler.inputSeq, fittedOutputSeq, 'b');
currentPos = get(loopSubFig, 'Position');
set(loopSubFig, 'Position', currentPos.*[0.85 1 1 1] + [0 0 0 0] );
legend('Real data', 'Fitted result');
axis square;

planeSubFig = subplot(1,2,2); hold on; grid on;
preisachUtils.plotSurface(planeSubFig, preisachRelayModel.weightFunc, ...
    preisachRelayModel.xyGrid, preisachRelayModel.gridDen);
currentPos = get(planeSubFig, 'Position');
set(planeSubFig, 'Position', currentPos.*[0.95 1 1 1] + [0 0 0 0] );
axis square;