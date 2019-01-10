clear all
close all
clc

close all;
if (~exist('isBatch', 'var') || isBatch ~= true) clc; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data handler and model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataHandler.resetOrigSequences();
% dataHandler.trimFirstZeroCrossInput();
% dataHandler.trimFirstMaxLastMinInput();
% dataHandler.trimFirstSecondMaxInput();
dataHandler.trimSecondThirdMaxInput();
dataHandler.interpSequence(401*2);
dataHandler.printInfo();

inputInterFact = -0.0005;
inputInter = abs(dataHandler.inputMax - dataHandler.inputMin);
preisachRelayModel = PreisachRelayModel([dataHandler.inputMin-inputInter*inputInterFact, ...
    dataHandler.inputMax+inputInter*inputInterFact], 120);
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
preisachUtils = PreisachRelayUtils(preisachRelayModel);
[filterTime, fittingTime, weightFuncTime] = preisachUtils...
    .fitModel(dataHandler.inputSeq, dataHandler.outputSeq);

% Generating fitted output
fittedOutputTic = tic;
preisachRelayModel.resetRelaysOff();

[fittedOutputSeq, fittedRelaysSeq] = preisachUtils.generateOutputSeq(dataHandler.inputSeq);
fittedOutputTime = toc(fittedOutputTic);