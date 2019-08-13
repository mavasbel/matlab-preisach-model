close all
clc

% Paremeters
lambda = 1.2;
K0 = 0.75/lambda;
K1 = 0/lambda;
triagAmp = 1.0;
pulseAmpMax = 1;
pulseAmpMin = 0.5;
inputSamples = 400;
errorThreshold = 0.0025;
iterationLimit = 30;

% Control objective and initial pulse amp
% Remnant max reachable: -0.33, Remnant min reachable: -0.83531
ref = max([min([-0.4, ...
                -0.33]),-0.83531]);
pulseAmp = max([min([1, ...
                pulseAmpMax]),pulseAmpMin]);

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
xlim([-1.2 1.2]);
ylim([-1.0 0.8]);
lineHandler = animatedline(gca);
colorMap = 0.97*rand(iterationLimit, 3);

% Video initialization
% videoWriter = VideoWriter(videoName);
% open(videoWriter);
while(true)
    % Update iteration counter
    iteration = iteration + 1;
    
    % Print iteration number
    disp('-------------------------')
    disp(['Iteration: ', num2str(iteration)])
    disp(['Pulse Amplitude: ', num2str(pulseAmp)])
    
    % Generate input signal
    [input, times] = generateInputSignal(triagAmp, pulseAmp, inputSamples);
    output = zeros(inputSamples, 1);
    lineHandler = animatedline(gca, 'Color', colorMap(iteration, :));
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
    
    % Print final output and error
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
    elseif iteration>=iterationLimit
        disp('-------------------------')
        disp('Iterations limit achieved!')
        disp('-------------------------')
        break
    end
    
    % Update pulse value for next iteration
%     L0 = 1-lambda*K0;
%     L1 = (1+lambda*K1)^(-1);
%     deltaPulseAmp = output(end)-lambda*pulseAmp;
%     constant = pulseAmp + deltaPulseAmp/lambda + (K0+K1*L1*L0)*error;
%     pulseAmp = pulseAmpNextByIter(preisachRelayModel, triagAmp, ...
%                                 lambda, constant, ...
%                                 pulseAmp, pulseAmpMin, pulseAmpMax);
    pulseAmp = pulseAmp + K0*error;
end

% Close video
% close(videoWriter);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to generate input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [signal, times] = generateInputSignal(triagAmp, pulseAmp, numSamples)
    pointTimes = [0; 0.25; 0.5; ...
            0.75; 1.0; 1.25; 1.5; ...
            1.75];
    pointSignal = [0; -triagAmp; 0;...
            0.5; 0.5; pulseAmp; 0; ...
            0;];
    times = linspace(0, pointTimes(end), numSamples);
    signal = interp1(pointTimes, pointSignal, times);
    
    times = times(:);
    signal = signal(:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to generate Phi from existing PreisachRelaysModel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function output = Phi(preisachRelayModel, triagAmp, pulseAmp)
    relays = preisachRelayModel.relays;
    preisachRelayModel.resetRelaysOff();
    preisachRelayModel.updateRelays(-triagAmp);
    preisachRelayModel.updateRelays(pulseAmp);
    preisachRelayModel.updateRelays(0);
    output = preisachRelayModel.getOutput();
    preisachRelayModel.relays= relays;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to generate PulseAmpNext from iteration of deltaPulseAmp
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pulseAmp = pulseAmpNextByIter(preisachRelayModel, triagAmp,...
                                lambda, constant, ...
                                pulseAmp, pulseAmpMin, pulseAmpMax)
    diffPrev = inf;
    while(true)
        deltaPulseAmpNext = Phi(preisachRelayModel, triagAmp, pulseAmp)...
                                - lambda*pulseAmp;
        pulseAmpNext = max([min([-deltaPulseAmpNext/lambda + constant, ...
                            pulseAmpMax]), pulseAmpMin]);
        diff = abs(pulseAmpNext - pulseAmp);
        
        pulseAmp = pulseAmpNext;
        if(diff<=0.001 || abs(diff-diffPrev)<=0.001), break; end
        diffPrev = diff;
    end
end