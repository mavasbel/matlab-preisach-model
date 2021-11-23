clear all
close all
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inputMin = -1;
inputMax = 1;
gridSize = 600;
sampleLength = 200;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create weighting function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xVals = linspace(inputMin, inputMax, gridSize);
yVals = linspace(inputMin, inputMax, gridSize);
[gridX, gridY] = meshgrid(xVals,yVals);

% Journal function:
weightFunc = (sin(2*pi*(gridY-gridX))) + (sin(2*pi*(gridX+gridY)));

% Piecewise continuous symmetric weighting function
% weightFunc = zeros(gridSize, gridSize);
% for i=1:length(xVals)
%     for j=1:length(yVals)
%         if( gridY(i,j)>=-gridX(i,j) ) 
%             weightFunc(i,j) = 1;
%         else
%             weightFunc(i,j) = -1;
%         end
%     end
% end

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

%Generates major loop to compute the necesarry offset and after applying 
%offset generates the major loop again
% preisachRelayModel.resetRelaysOff();
% preisachRelayModel.updateRelays(inputMax*1.0);
% preisachRelayModel.updateRelays(inputMin*0.9);
% preisachRelayModel.updateRelays(inputMax*0.9);
% preisachRelayModel.updateRelays(inputMin*0.8);
% preisachRelayModel.updateRelays(inputMax*0.8);
% preisachRelayModel.updateRelays(inputMin*0.7);
% preisachRelayModel.updateRelays(inputMax*0.7);
% preisachRelayModel.updateRelays(inputMin*0.6);
% preisachRelayModel.updateRelays(inputMax*0.6);
% preisachRelayModel.updateRelays(inputMin*0.5);

% preisachRelayModel.resetRelaysOff();
% preisachRelayModel.updateRelays(inputMax*0.7);
% preisachRelayModel.updateRelays(inputMin*0.7);
% minorInputSeq = [linspace(inputMin*0.7, inputMax*0.7, sampleLength), ...
%     linspace(inputMax*0.7, inputMin*0.7, sampleLength)]';
% [minorOutputSeq, ~] = preisachUtils.generateOutputSeq(minorInputSeq);
% minorDataHandler = DataHandler(minorInputSeq, minorOutputSeq);

% preisachRelayModel.resetRelaysOff();
% preisachRelayModel.updateRelays(inputMax*1.0);
% preisachRelayModel.updateRelays(inputMin*0.2);
% minorInputSeq = [linspace(inputMin*0.2, inputMax*0.2, sampleLength), ...
%     linspace(inputMax*0.2, inputMin*0.2, sampleLength)]';
% [minorOutputSeq, ~] = preisachUtils.generateOutputSeq(minorInputSeq);
% minorDataHandler = DataHandler(minorInputSeq, minorOutputSeq);

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
saveas(gcf,'example_multiloop_input','epsc');
DataPlotter.plotOutputPeriod(dataHandler);
saveas(gcf,'example_multiloop_output','epsc');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
DataPlotter.plotLoopPeriod(dataHandler);

% preisachRelayModel.resetRelaysOff();
% preisachRelayModel.updateRelays(-1.0);
% minorInputSeq = [linspace(-1.0, -0.5, sampleLength), ...
%     linspace(-0.5, -1.0, sampleLength)]';
% [minorOutputSeq, ~] = preisachUtils.generateOutputSeq(minorInputSeq);
% minorDataHandler = DataHandler(minorInputSeq, minorOutputSeq);
% T1=1;
% T2=sampleLength;
% T3=minorDataHandler.sampleLength;
% hand1=plot(minorDataHandler.inputSeq(T1:T2),minorDataHandler.outputSeq(T1:T2),...
%     'linewidth',1.3,...
%     'color',[0 0 0.80],...
%     'linestyle','-');
% hand2=plot(minorDataHandler.inputSeq(T2:T3),minorDataHandler.outputSeq(T2:T3),...
%     'linewidth',1.3,...
%     'color',[0 0 0.80],...
%     'linestyle','--');
% drawnow;

% preisachRelayModel.resetRelaysOn();
% preisachRelayModel.updateRelays(1.0);
% minorInputSeq = [linspace(1.0, 0.5, sampleLength), ...
%     linspace(0.5, 1.0, sampleLength)]';
% [minorOutputSeq, ~] = preisachUtils.generateOutputSeq(minorInputSeq);
% minorDataHandler = DataHandler(minorInputSeq, minorOutputSeq);
% T1=1;
% T2=sampleLength;
% T3=minorDataHandler.sampleLength;
% hand1=plot(minorDataHandler.inputSeq(T1:T2),minorDataHandler.outputSeq(T1:T2),...
%     'linewidth',1.3,...
%     'color',[0.80 0 0],...
%     'linestyle','-');
% hand2=plot(minorDataHandler.inputSeq(T2:T3),minorDataHandler.outputSeq(T2:T3),...
%     'linewidth',1.3,...
%     'color',[0.80 0 0],...
%     'linestyle','--');
% drawnow;

preisachRelayModel.resetRelaysOff();
preisachRelayModel.updateRelays(0.40);
preisachRelayModel.updateRelays(-0.40);
minorInputSeq = [linspace(-0.40, 0.40, sampleLength), ...
    linspace(0.40, -0.40, sampleLength)]';
[minorOutputSeq, ~] = preisachUtils.generateOutputSeq(minorInputSeq);
minorDataHandler = DataHandler(minorInputSeq, minorOutputSeq);
T1=1;
T2=sampleLength;
T3=minorDataHandler.sampleLength;
hand1=plot(minorDataHandler.inputSeq(T1:T2),minorDataHandler.outputSeq(T1:T2),...
    'linewidth',1.3,...
    'color',[0.80 0 0],...
    'linestyle','-');
hand2=plot(minorDataHandler.inputSeq(T2:T3),minorDataHandler.outputSeq(T2:T3),...
    'linewidth',1.3,...
    'color',[0.80 0 0],...
    'linestyle','--');
drawnow;

% preisachRelayModel.resetRelaysOn();
% preisachRelayModel.updateRelays(0.50);
% minorInputSeq = [linspace(0.50, -0.50, sampleLength), ...
%     linspace(-0.50, 0.50, sampleLength)]';
% [minorOutputSeq, ~] = preisachUtils.generateOutputSeq(minorInputSeq);
% minorDataHandler = DataHandler(minorInputSeq, minorOutputSeq);
% T1=1;
% T2=sampleLength;
% T3=minorDataHandler.sampleLength;
% hand1=plot(minorDataHandler.inputSeq(T1:T2),minorDataHandler.outputSeq(T1:T2),...
%     'linewidth',1.3,...
%     'color',[0.0 0.80 0],...
%     'linestyle','--');
% hand2=plot(minorDataHandler.inputSeq(T2:T3),minorDataHandler.outputSeq(T2:T3),...
%     'linewidth',1.3,...
%     'color',[0.0 0.80 0],...
%     'linestyle','-');
% drawnow;

% preisachRelayModel.resetRelaysOff();
% preisachRelayModel.updateRelays(0.65);
% preisachRelayModel.updateRelays(-0.65);
% minorInputSeq = [linspace(-0.65, 0.65, sampleLength), ...
%     linspace(0.65, -0.65, sampleLength)]';
% [minorOutputSeq, ~] = preisachUtils.generateOutputSeq(minorInputSeq);
% minorDataHandler = DataHandler(minorInputSeq, minorOutputSeq);
% T1=1;
% T2=sampleLength;
% T3=minorDataHandler.sampleLength;
% hand1=plot(minorDataHandler.inputSeq(T1:T2),minorDataHandler.outputSeq(T1:T2),...
%     'linewidth',1.3,...
%     'color',[0.0 0 0.80],...
%     'linestyle','-');
% hand2=plot(minorDataHandler.inputSeq(T2:T3),minorDataHandler.outputSeq(T2:T3),...
%     'linewidth',1.3,...
%     'color',[0.0 0 0.80],...
%     'linestyle','--');
% drawnow;

saveas(gcf,'example_multiloop_phase','epsc');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DataPlotter.plotWeightFunc(preisachRelayModel.weightFunc, preisachRelayModel.inputGrid);
% saveas(gcf,'example_multiloop_mu','epsc');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creating parameters for simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%run('./CreateSimulinkParams');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add rectangles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% linePoints = 350;
% maxZ = max(max(weightFunc));
% 
% inputCross= -0.5;
% handlers = plotRectangle([inputMin, inputCross;
%     inputCross, inputCross;
%     inputCross, inputMax;
%     inputMin, inputMax;
%     inputMin, inputCross], maxZ, linePoints);
% saveas(gcf,'example_multiloop_mu_omegac1','epsc');
% delete(handlers(:));
% 
% inputCross= 0;
% handlers = plotRectangle([inputMin, inputCross;
%     inputCross, inputCross;
%     inputCross, inputMax;
%     inputMin, inputMax;
%     inputMin, inputCross], maxZ, linePoints);
% saveas(gcf,'example_multiloop_mu_omegac2','epsc');
% delete(handlers(:));
% 
% inputCross= 0.5;
% handlers = plotRectangle([inputMin, inputCross;
%     inputCross, inputCross;
%     inputCross, inputMax;
%     inputMin, inputMax;
%     inputMin, inputCross], maxZ, linePoints);
% saveas(gcf,'example_multiloop_mu_omegac3','epsc');
% delete(handlers(:));