close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data sequence params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inputMin = -1;
inputMax = 1;
totalTime = 3;
timeStep = 0.001;
inputFreq = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creates input sequence
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inputAmp = (inputMax - inputMin)/2;
inputOffset = (inputMax + inputMin)/2;
totalSamples = ceil(totalTime/timeStep);
timeSeq = linspace(0, totalTime, totalSamples);
inputSeq = inputAmp*sin(2*pi*inputFreq*timeSeq) + inputOffset;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set Preisach model initial state and create data handler
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
preisachRelayModel.resetRelaysOff();
% preisachRelayModel.setRelaysWindowByValue(-inf,-dataHandler.inputAmp/2,-inf,inf,1);
%preisachRelayModel.setRelaysWindowByValue(-inf,-dataHandler.inputAmp/5,-inf,inf,1);
preisachRelayModel.updateRelays(inputSeq(1));
preisachUtils = PreisachRelayUtils(preisachRelayModel);
[outputSeq, relaysSeq] = preisachUtils.generateOutputSeq(inputSeq);
dataHandler = DataHandler(inputSeq, outputSeq, timeSeq);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot input, output and loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataPlotter = DataPlotter();
DataPlotter.plotInput(dataHandler);
DataPlotter.plotOutput(dataHandler);
DataPlotter.plotLoop(dataHandler);
dataHandler.resetOrigSequences();