close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data sequence params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inputMin = -1;
inputMax = 1;
totalTime = 10;
timeStep = 0.01;
inputFreq = 3/totalTime;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creates input sequence
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inputAmp = (inputMax - inputMin)/2;
inputOffset = (inputMax + inputMin)/2;
totalSamples = ceil(totalTime/timeStep);
timeSeq = linspace(0, totalTime, totalSamples);
inputSeq = inputAmp*sin(2*pi*inputFreq*timeSeq);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set Preisach model initial state and create data handler
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
preisachRelayModel.resetRelaysOff();
preisachRelayModel.updateRelays(inputSeq(1));
preisachUtils = PreisachRelayUtils(preisachRelayModel);
[outputSeq, relaysSeq] = preisachUtils.generateOutputSeq(inputSeq);
dataHandler = DataHandler(inputSeq, outputSeq, timeSeq);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot input, output and loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataPlotter = DataPlotter();
dataPlotter.plotInputPeriod(dataHandler);
dataPlotter.plotOutputPeriod(dataHandler);
dataPlotter.plotLoopPeriod(dataHandler);