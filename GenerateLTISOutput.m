close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data sequence params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inputMin = -1;
inputMax = 1;
totalTime = 3;
timeStep = 0.001;
inputFreq = 5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creates input sequence
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inputAmp = (inputMax - inputMin)/2;
inputOffset = (inputMax + inputMin)/2;
totalSamples = ceil(totalTime/timeStep);
timeSeq = linspace(0, totalTime, totalSamples);
inputSeq = inputAmp*sin(2*pi*inputFreq*timeSeq) + inputOffset;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate linear system output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% num = [0,4];
% den = [1,4];
num = [0,0,1000];
den = [1,32,1000];
ltiSys = tf(num,den);
[outputSeq, timeSeq, stateSeq] = lsim(ltiSys, inputSeq, timeSeq);
dataHandler = DataHandler(inputSeq, outputSeq, timeSeq);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot input, output and loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataHandler.resetOrigSequences();
dataHandler.outputMin = inputMin;
dataHandler.outputMax = inputMax;
dataHandler.outputAmp = (dataHandler.outputMax - dataHandler.outputMin)/2;
dataHandler.outputOffset = (dataHandler.outputMax + dataHandler.outputMin)/2;

DataPlotter.plotInput(dataHandler);
DataPlotter.plotOutput(dataHandler);
DataPlotter.plotLoop(dataHandler);