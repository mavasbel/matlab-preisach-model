clear all
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inputMin = -1;
inputMax = 1;
gridSize = 800;
sampleLength = 800;

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

% Zero area loop, all crossover points
% idx = find(xVals>=0,1,'first');
% weightFunc(1:end-idx,1:idx) = -1*weightFunc(1:end-idx,1:idx);
% weightFunc(end-idx+1:end,1:idx) = flipud(weightFunc(end-idx+1:end,1:idx));

% Two loops with same orientation
idx = find(xVals>=0,1,'first');
weightFunc(1:end-idx,1:idx) = -1*weightFunc(1:end-idx,1:idx);
weightFunc(end-idx+1:end,1:idx) = fliplr(weightFunc(end-idx+1:end,1:idx));

% weightFunc(end-idx+1:end,1:idx) = flipud(weightFunc(end-idx+1:end,1:idx));
% weightFunc(end-idx+1:end,1:idx) = fliplr(weightFunc(end-idx+1:end,1:idx));
% weightFunc(end-idx+1:end,1:idx) = zeros(idx,idx);


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
% Create Preisach model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
preisachRelayModel = PreisachRelayModel([inputMin, inputMax], gridSize);
preisachRelayModel.resetRelaysOff();
preisachRelayModel.weightFunc = flipud(weightFunc);
preisachRelayModel.printInfo();
preisachUtils = PreisachRelayUtils(preisachRelayModel);

%Generates major loop to compute the necesarry offset and after applying 
%offset generates the major loop again
inputSeq = [linspace(inputMin, inputMax, sampleLength), ...
    linspace(inputMax, inputMin, sampleLength)]';
[outputSeq, ~] = preisachUtils.generateOutputSeq(inputSeq);
dataHandler = DataHandler(inputSeq, outputSeq);
preisachRelayModel.offset = -dataHandler.outputOffset;
[outputSeq, relaysSeq] = preisachUtils.generateOutputSeq(inputSeq);
dataHandler = DataHandler(inputSeq, outputSeq);

%Major loop area
Area = 0;
for i=1:length(xVals)
    for j=1:length(yVals)
        if( yVals(j)<=xVals(i) ) 
            Area = Area + 2*weightFunc(i,j)*...
                (xVals(i)-yVals(j))*preisachRelayModel.relayArea;
        end
    end
end
disp(['Major loop area: ', num2str(Area)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DataPlotter.plotInputPeriod(dataHandler);
DataPlotter.plotOutputPeriod(dataHandler);
DataPlotter.plotLoopPeriod(dataHandler);
DataPlotter.plotWeightFunc(preisachRelayModel.weightFunc, preisachRelayModel.inputGrid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creating parameters for simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%run('./CreateSimulinkParams');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add rectangles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
linePoints = 350;
maxZ = max(max(weightFunc));

inputCross= 0;
plotRectangle([inputMin, inputCross;
    inputCross, inputCross;
    inputCross, inputMax;
    inputMin, inputMax;
    inputMin, inputCross], maxZ, linePoints);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotRectangle(vertix, maxZ, linePoints)
    for i=1:size(vertix,1)
        j = i+1;
        if i==size(vertix,1)
            j = 1;
        end
        line = [linspace(vertix(i,1), vertix(j,1), linePoints);
            linspace(vertix(i,2), vertix(j,2), linePoints);
            repmat(maxZ, 1, linePoints)]';
        plot3(line(:,1), line(:,2), line(:,3), '--k', 'linewidth', 7);
    end
end