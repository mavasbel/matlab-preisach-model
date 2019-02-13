% Create parameters
props = string(properties(preisachRelayModel));
for i = 1:length(props)
    propName = char(props(i,:));
    propVal = get(preisachRelayModel, propName);
    var = genvarname(propName);
    evalc([ var, ' = ', mat2str(propVal) ]);
end

preisachRelayModel.resetRelaysOn();
initialRelays = preisachRelayModel.relays;
inputMin = xyGrid(1);
inputMax = xyGrid(end);
outputMin = dataHandler.outputMin;
outputMax = dataHandler.outputMax;
inputFactor = 1.5;
outputFactor = 1.5;
simTotalTime = 10;
initialInput = 0;

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

stepsValues = [-0.5, -0.75, 0.35, -0.8, 0.8]...
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
clc
s = tf('s');

poles = [-2.0000 + 2.0000i,
         -2.0000 - 2.0000i,
         -3.0000 + 0.0000i];
chi = poly(poles);

% Plant
% Gtf = 5/(s^3 + 7*s^2 + 16*s +10);
Gtf = tf(0.5*chi(end),chi)
Gss = ss(Gtf);
Gss = ss2ss(Gss,inv(ctrb(Gss.A, Gss.B)));
Gss = ss(Gss.A',Gss.C',Gss.B',Gss.D);
GA = Gss.A'; GB = Gss.C'; GC = Gss.B'; GD = Gss.D;
% [Gnum, Gden] = ss2tf(GA, GB, GC, GD);
% Gtf = tf(Gnum, Gden)

% Initial conditions
Gx0 = 5*(1./GC)/length(GC); Gx0(isinf(Gx0)) = 0;
% Gx0 = [-0.5, -0.9, -0.4];
Gx0 = [-0.8, -0.8, 0.9];

% Steady state gains
Gk = (-GC*inv(GA)*GB + GD);
Phik = -1/Gk;

% Controller
% Ctf = (s+2)/(1*(s+5));
% Css = ss(Ctf);
% CA = Css.A; CB = Css.B; CC = Css.C; CD = Css.D;
% Cx0 = 0*(1./CC)/length(CC); Cx0(~isnumeric(Cx0)) = 0;

% No controller
Css = ss(1);
CA = 0; CB = 0; CC = 0; CD = 1;

% Stability conditions
lm = -2; lM = 2;
Gb = minreal((1+lM*Gtf*Ctf)/(1+lm*Gtf*Ctf));
disp(strcat('   Stable loop:', {' '}, string(isPassive(Gb))));
disp(strcat('   Phi_k:', {' '}, string(Phik)));
nyquist(Gb);
