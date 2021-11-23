clear all
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Models params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
totalModels = 6;
inputMin = -1;
inputMax = 1;
gridSize = 500;
inputSeqLength = 100;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create weighting function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xVals = linspace(inputMin, inputMax, gridSize);
yVals = linspace(inputMin, inputMax, gridSize);
[gridX, gridY] = meshgrid(xVals,yVals);

% Journal function:
% weightFunc = (sin(2*pi*(gridY-gridX))) + (sin(2*pi*(gridX+gridY)));

% Piecewise continuous symmetric weighting function
weightFunc = zeros(gridSize, gridSize);
for i=1:length(xVals)
    for j=1:length(yVals)
        if( gridY(i,j)>=-gridX(i,j) ) 
            weightFunc(i,j) = 1;
        else
            weightFunc(i,j) = -1;
        end
    end
end

% Piecewise continuous ascending boundary
% weightFunc = zeros(gridSize, gridSize);
% for i=1:length(xVals)
%     for j=1:length(yVals)
%         if( gridY(i,j)>=0.2*gridX(i,j)+0.50 )
%             weightFunc(i,j) = 1;
%         else
%             weightFunc(i,j) = -1;
%         end
%     end
% end

% Everything outside Preisach domain is 0
for i=1:length(xVals)
    for j=1:length(yVals)
        if( yVals(j)>xVals(i) ) 
            weightFunc(i,j) = 0;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Preisach models
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
baseModel = PreisachRelayModel([inputMin, inputMax], gridSize);
baseModel.resetRelaysOff();
baseModel.weightFunc = flipud(weightFunc);
baseModel.printInfo();

%Generates major loop to compute the necesarry offset and after applying 
%offset generates the major loop again
preisachUtils = PreisachRelayUtils(baseModel);
inputSeq = [linspace(inputMin, inputMax, inputSeqLength), ...
    linspace(inputMax, inputMin, inputSeqLength)]';
[outputSeq, ~] = preisachUtils.generateOutputSeq(inputSeq);
dataHandler = DataHandler(inputSeq, outputSeq);
baseModel.offset = -dataHandler.outputOffset;
[outputSeq, ~] = preisachUtils.generateOutputSeq(inputSeq);
dataHandler = DataHandler(inputSeq, outputSeq);

preisachArray = [];
for i=1:totalModels
    preisachModel = PreisachRelayModel([inputMin, inputMax], gridSize);
    preisachModel.resetRelaysOff();
    preisachModel.weightFunc = baseModel.weightFunc;
    preisachModel.offset = baseModel.offset;
    preisachArray = [preisachArray; preisachModel];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DataPlotter.plotInputPeriod(dataHandler);
DataPlotter.plotOutputPeriod(dataHandler);
DataPlotter.plotLoopPeriod(dataHandler);
DataPlotter.plotWeightFunc(baseModel.weightFunc, baseModel.inputGrid);