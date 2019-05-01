%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
inputAmp = dataHandler.inputAmp;
outputMin = dataHandler.outputMin;
outputMax = dataHandler.outputMax;
outputAmp = dataHandler.outputAmp;
inputFactor = 0.25;
outputFactor = 0.75;
simTotalTime = 300;
initialInput = 0.0*dataHandler.inputAmp + dataHandler.inputOffset;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Time steps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

stepsValues = 1*[-0.9, 0.9, -0.35, 0.35, -0.8, 0.8]...
    *(outputMax-outputMin)/2 + (outputMax+outputMin)/2;

switches = size(stepsValues, 2);
switchesTime = linspace(0, simTotalTime, switches+1);
sequenceVal = repelem(stepsValues, 2);
sequenceTime = zeros(1, switches*2);
sequenceTime(2:2:end) = switchesTime(2:end);
sequenceTime(3:2:end) = switchesTime(2:end-1)+0.01;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Linear system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s = tf('s');
G0poles = [-2.0000 + 2.0000i,
         -2.0000 - 2.0000i,
         -3.0000 + 0.0000i];
G0zeros = [-1.0000 + 0.0000i,
         -3.0000 - 2.0000i,
         -3.0000 + 2.0000i];
numG0 = poly(G0zeros);
denG0 = poly(G0poles);

% Plant
% Gtf = 5/(s^3 + 7*s^2 + 16*s +10);
G0 = ss( tf(1*denG0(end),denG0) );
% G0 = ss( tf(numG0,denG0) );
G0 = ss2ss(G0, inv(ctrb(G0.A, G0.B)));
GA = G0.A'; GB = G0.C'; GC = G0.B'; GD = G0.D;
% Gx0 = -0.8*(1./GC)/length(GC); Gx0(isinf(Gx0)) = 0;
% Gx0 = [-0.7, -0.8, 0.9];
Gx0 = [0 0 0];