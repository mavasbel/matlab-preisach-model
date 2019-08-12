close all
clc

% Paremeters
ref = - 0.4 - 0.3582;
pulseAmp = 0.5;
k0 = 2.0;
k1 = 1.0;
lambda = 1.0;
initAmp = 1.0;
inputSamples = 400;
errorThreshold = 0.001;
iterationLimit = 20;

% Video parameters
videoName = 'video.avi';
videoWidth = 720;
videoHeight = 480;

disp(['Target Output: ', num2str(ref)])
disp(['Error Threshold: ', num2str(errorThreshold)])

% Loop Initialization
pulses = [];
remnants = [];
errors = [];
iteration = 0;
preisachRelayModel.resetRelaysOn();
fig = figure;
plotHandler = plot(0, ref, 'ro', 'markersize', 4);
lineHandler = animatedline(gca);

% Video initialization
% videoWriter = VideoWriter(videoName);
% open(videoWriter);
while(true)
    % Update iteration counter
    iteration = iteration + 1;
    
    % Generate input signal
    [input, times] = generateInputSignal(initAmp, pulseAmp, inputSamples);
    output = zeros(inputSamples, 1);
    for i=1:inputSamples
        % Apply input value
        preisachRelayModel.updateRelays(input(i));
        output(i) = preisachRelayModel.getOutput();
        addpoints(lineHandler, input(i), output(i));
        drawnow limitrate;
        % Write video
%         frame = getframe(fig);
%         writeVideo(videoWriter, frame);
    end
    error = (ref - output(end));
    
    % Print stats
    disp('-------------------------')
    disp(['Iteration: ', num2str(iteration)])
    disp(['Pulse Amplitude: ', num2str(pulseAmp)])
    disp(['Final Output: ', num2str(output(end))])
    disp(['Error: ', num2str(error)])
    
    % Save iteration params and stats
    pulses = [pulses; pulseAmp];
    remnants = [remnants; output(end)];
    errors = [errors; error];
    
    % Break cycle condition
    if abs(error)<=errorThreshold
        disp('-------------------------')
        disp('Error threshold achieved')
        disp('-------------------------')
        break
    elseif iteration>iterationLimit
        disp('-------------------------')
        disp('Iterations limit achieved!')
        disp('-------------------------')
        break
    end
    
    % Update pulse value for next iteration
    deltaPulseAmp = Phi(preisachRelayModel, pulseAmp)-lambda*pulseAmp;
    temp = pulseAmp - deltaPulseAmp/lambda + (k0 + k1*inv(1+lambda*k1)*(1-lambda*k0))*error;
    pulseAmp = deltaByIteration(preisachRelayModel, lambda, temp, 1);
end

% Close video
% close(videoWriter);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to generate input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [signal, times] = generateInputSignal(initAmp, pulseAmp, numSamples)
    pointTimes = [0; 0.25; 0.5; ...
            0.75; 1; 1.25; ...
            1.5];
    pointSignal = [0; -initAmp; 0;...
            0; pulseAmp; 0; ...
            0;];
    times = linspace(0, pointTimes(end), numSamples);
    signal = interp1(pointTimes, pointSignal, times);
    
    times = times(:);
    signal = signal(:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to generate Phi from existing PreisachRelaysModel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function output = Phi(preisachRelayModel, pulseAmp)
    relays = preisachRelayModel.relays;
    preisachRelayModel.resetRelaysOff();
    preisachRelayModel.updateRelays(pulseAmp);
    preisachRelayModel.updateRelays(0);
    output = preisachRelayModel.getOutput();
    preisachRelayModel.relays= relays;
end

function pulseAmp = deltaByIteration(preisachRelayModel, lambda, temp, pulseAmp)
    diff = inf;
    while(true)
        pulseAmpNext = max([(Phi(preisachRelayModel, pulseAmp)-lambda*pulseAmp) + temp, 0]);
        newDiff = abs(pulseAmpNext - pulseAmp);
        pulseAmp = pulseAmpNext;
        if(diff == newDiff || newDiff<0.0001), break; end
        diff = newDiff;
    end
end