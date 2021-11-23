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

% Two "single" loops
% idx = find(xVals>=0,1,'first');
% weightFunc(1:end-idx,1:idx) = -1*weightFunc(1:end-idx,1:idx);
% weightFunc(end-idx+1:end,1:idx) = flipud(weightFunc(end-idx+1:end,1:idx));
% weightFunc(end-idx+1:end,1:idx) = fliplr(weightFunc(end-idx+1:end,1:idx));
% weightFunc(end-idx+1:end,1:idx) = zeros(idx,idx);

% Negative region vertical rectanble
% idx = find(xVals>=-0.5,1,'first');
% weightFunc = abs(weightFunc);
% weightFunc(idx*2:end,1:idx) = -1*weightFunc(idx*2:end,1:idx);
% weightFunc(idx*2:end,1:idx*2) = fliplr(weightFunc(idx*2:end,1:idx*2));

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
preisachRelayModel.resetRelaysOn();
preisachRelayModel.weightFunc = flipud(weightFunc);
preisachRelayModel.printInfo();
preisachUtils = PreisachRelayUtils(preisachRelayModel);

%Generates major loop to compute the necesarry offset and after applying 
%offset generates the major loop again
% factorPos = 0.75;
% factorNeg = 0.75;
factorPos = 1.0;
factorNeg = 1.0;
inputSeq = [linspace(inputMin*factorNeg, inputMax*factorPos, sampleLength), ...
    linspace(inputMax*factorPos, inputMin*factorNeg, sampleLength)]';
preisachRelayModel.resetRelaysOn();
[outputSeq, ~] = preisachUtils.generateOutputSeq(inputSeq);
dataHandler = DataHandler(inputSeq, outputSeq);
preisachRelayModel.offset = -dataHandler.outputOffset;
preisachRelayModel.resetRelaysOn();
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
saveas(gcf,'example_doubleloop_same_oriented_input','epsc');
DataPlotter.plotOutputPeriod(dataHandler);
saveas(gcf,'example_doubleloop_same_oriented_output','epsc');
DataPlotter.plotLoopPeriod(dataHandler);
saveas(gcf,'example_doubleloop_same_oriented_phase','epsc');
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
handlers = plotRectangle([inputMin, inputCross;
    inputCross, inputCross;
    inputCross, inputMax;
    inputMin, inputMax;
    inputMin, inputCross], maxZ, linePoints);
drawnow;
saveas(gcf,'example_doubleloop_same_oriented_mu_omegac','epsc');
delete(handlers(:));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handlers = plotRectangle(vertix, maxZ, linePoints)
    handlers = [];
    for i=1:size(vertix,1)
        j = i+1;
        if i==size(vertix,1)
            j = 1;
        end
        line = [linspace(vertix(i,1), vertix(j,1), linePoints);
            linspace(vertix(i,2), vertix(j,2), linePoints);
            repmat(maxZ, 1, linePoints)]';
        handlers = [handlers; plot3(line(:,1), line(:,2), line(:,3), '--k', 'linewidth', 7)];
    end
end