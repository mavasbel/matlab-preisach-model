% Create parameters
props = string(properties(preisachRelayModel));
for i = 1:length(props)
    propName = char(props(i,:));
    propVal = get(preisachRelayModel, propName);
    var = genvarname(propName);
    evalc([ var, ' = ', mat2str(propVal) ]);
end

preisachRelayModel.resetRelaysOff();
initialRelays = preisachRelayModel.relays;
inputMin = xyGrid(1);
inputMax = xyGrid(end);
outputMin = dataHandler.outputMin;
outputMax = dataHandler.outputMax;
inputFactor = 1.25;
outputFactor = 1.25;
simTotalTime = 100*5;
initialInput = 0;

% sequenceTime = [0 3,...
%     3.01 6,... 
%     6.01 9,...
%     9.01 12,...
%     12.01 15,...
%     15.1 18]*simTotalTime/18;
% 
% sequenceVal = ([-0.5 -0.5,...
%     0.5 0.5,...
%     -0.75 -0.75,...
%     0.35 0.35,...
%     -0.8 -0.8,...
%     0.8 0.8])...
%     *(outputMax-outputMin)/2 + (outputMax+outputMin)/2;

stepsValues = [-0.5, -0.75, 0.35, -0.8, 0.8]...
    *(outputMax-outputMin)/2 + (outputMax+outputMin)/2;

switches = size(stepsValues, 2);
switchesTime = linspace(0, simTotalTime, switches+1);
sequenceVal = repelem(stepsValues, 2);
sequenceTime = zeros(1, switches*2);
sequenceTime(2:2:end) = switchesTime(2:end);
sequenceTime(3:2:end) = switchesTime(2:end-1)+0.01;
