clear all
close all
clc

inputMin = -1;
inputMax = 1;
gridDen = 400;
sampleLength = 800;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create weighting function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = linspace(inputMin, inputMax, gridDen);
y = linspace(inputMin, inputMax, gridDen);
[gridX, gridY] = meshgrid(x,y);

% Journal function:
% z = (sin(2*pi*(gridY-gridX))) + (sin(2*pi*(gridX+gridY)));

% Piecewise continuous symmetric weighting function
z = zeros(gridDen, gridDen);
for i=1:length(x)
    for j=1:length(y)
        if(gridY(i,j)>=-gridX(i,j)) 
            z(i,j) = 1;
        else
            z(i,j) = -1;
        end
    end
end

for i=1:length(x)
    for j=1:length(y)
        if(x(i)<y(j)) 
            z(i,j) = 0;
        end
    end
end
% surf(gridX, gridY, z, 'edgecolor', 'none');
% colorbar
% colormap jet
% shading interp
% view([0 90])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Preisach model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
preisachRelayModel = PreisachRelayModel([inputMin, inputMax], gridDen);
preisachRelayModel.resetRelaysOff();
preisachRelayModel.weightFunc = flipud(z);
preisachRelayModel.offset = 0;
preisachRelayModel.printInfo();
preisachUtils = PreisachRelayUtils(preisachRelayModel);

inputSeq = [linspace(inputMin, inputMax, sampleLength), linspace(inputMax, inputMin, sampleLength)]';
outputSeq = preisachUtils.generateOutputSeq(inputSeq);
dataHandler = DataHandler(inputSeq, outputSeq);
% dataHandler = DataHandler(inputSeq, outputSeq+1.34/2);

preisachRelayModel.offset = (dataHandler.outputMax-dataHandler.outputMin)/2;
[outputSeq, relaysSeq] = preisachUtils.generateOutputSeq(inputSeq);
dataHandler = DataHandler(inputSeq, outputSeq);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
preisachPlots = PreisachPlots();
preisachPlots.plotInputPaper(dataHandler);
preisachPlots.plotOutputPaper(dataHandler);
preisachPlots.plotPhasePaper(dataHandler);
preisachPlots.plotSurfaceFig(preisachRelayModel.weightFunc, preisachRelayModel.xyGrid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creating parameters for simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run('./SimulinkParams');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add rectangles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% linePoints = 350;
% maxZ = max(max(z));

% inputCross= -0.5;
% inputCross= 0;
% inputCross= 0.5;
% plotRectangle([inputMin, inputCross;
%     inputCross, inputCross;
%     inputCross, inputMax;
%     inputMin, inputMax;
%     inputMin, inputCross], maxZ, linePoints);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function plotRectangle(vertix, maxZ, linePoints)
%     for i=1:size(vertix,1)
%         j = i+1;
%         if i==size(vertix,1)
%             j = 1;
%         end
%         line = [linspace(vertix(i,1), vertix(j,1), linePoints);
%             linspace(vertix(i,2), vertix(j,2), linePoints);
%             repmat(maxZ, 1, linePoints)]';
%         plot3(line(:,1), line(:,2), line(:,3), '--k', 'linewidth', 7);
%     end
% end