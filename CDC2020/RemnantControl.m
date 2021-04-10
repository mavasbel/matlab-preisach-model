close all
clc

% Paremeters
K0 = 0.28;
triagAmp = 1.0;
inputMax = 1400;
inputMin = -1400;
remnantMax = 400;
remnantMin = -200;
inputSamples = 400;
errorThreshold = 0.00001;
iterationLimit = 20;

% Control objective and initial pulse amp
% Remnant max reachable: -0.33, Remnant min reachable: -0.83531
ref = max([min([250, ...
                remnantMax]),remnantMin]);
initialPulse = max([min([500, ...
                inputMax]),inputMin]);

disp(['Target Output: ', num2str(ref)])
disp(['Error Threshold: ', num2str(errorThreshold)])

% Video parameterscl
videoName = 'video.avi';
videoWidth = 720;
videoHeight = 480;

% Plot parameters
refMarkerSize = 8;
lineWidth = 1.2;

% Figure initialization
fig = figure;
plotHandler = plot(0, ref, 'xb', ...
    'markersize', refMarkerSize, 'LineWidth', lineWidth); hold on;
plot(dataHandler.inputSeq, dataHandler.outputSeq, '-r', ...
    'LineWidth', lineWidth);
xlim([inputMin-0.2*(inputMax-inputMin)...
    inputMax+0.2*(inputMax-inputMin)]);
ylim([remnantMin-0.15*(remnantMax-remnantMin)...
    remnantMax+1.15*(remnantMax-remnantMin)]);
lineHandler = animatedline(gca);

% Loop Initialization
baseModel = preisachRelayModel;
baseModel.resetRelaysOff();
baseModel.setRelaysWindowByValue(inputMin,-800,inputMin,inputMax,1);
% baseModel.setRelaysWindowByValue(inputMin,-800,inputMin,1200,1);
% baseModel.setRelaysWindowByValue(inputMin,-700,inputMin,1000,1);
baseModel.updateRelays(0);
remnants = baseModel.getOutput();
errors = baseModel.getOutput()-ref;
inputAmps = initialPulse;
iter = 1;
inputs = [];
outputs = [];

% Plot initial and final points in phase plot
plot(gca,0,baseModel.getOutput(),'bo',...
    'LineWidth',1.5,...
    'markerSize',7);
plot(gca,0,ref,'bx',...
    'LineWidth',1.5,...
    'markerSize',8);

% Video initialization
videoWriter = VideoWriter(videoName);
open(videoWriter);
while(true)
    % Print iteration number
    disp('-------------------------')
    disp(['Iteration: ', num2str(iter)])
    disp(['Pulse Amplitude: ', num2str(inputAmps(end))])
    
    % Generate input signal
    [input, times] = generateInputSignal(triagAmp, inputAmps(end), inputSamples);
    output = zeros(inputSamples, 1);
    lineHandler = animatedline(gca, ...
        'LineWidth', lineWidth, ...
        'Color', 0.7*rand(1, 3)+[0.1, 0.1, 0.1]);
    for i=1:inputSamples
        % Apply input value
        baseModel.updateRelays(input(i));
        output(i) = baseModel.getOutput();
        addpoints(lineHandler, input(i), output(i));
        drawnow limitrate;
        % Write video
        frame = getframe(fig);
        writeVideo(videoWriter, frame);
    end
    inputs = [inputs, input(:)];
    outputs = [outputs, output(:)];
    
    % Save iteration params and stats
    remnants = [remnants; output(end)];
    errors = [errors; (output(end)-ref)];
    
    % Update pulse value for next iteration
    inputAmps = [inputAmps, inputAmps(end)-K0*errors(end)];
    
    % Print final output and error
    disp(['Final Output: ', num2str(remnants(end))])
    disp(['Error: ', num2str(errors(end))])
    
    % Break cycle condition
    if abs(errors(end))<=errorThreshold
        disp('-------------------------')
        disp('Error threshold achieved')
        disp('-------------------------')
        break
    elseif iter>=iterationLimit
        disp('-------------------------')
        disp('Iterations limit achieved!')
        disp('-------------------------')
        break
    end
    
    % Update iteration counter
    iter = iter+1;

end

% Close video
close(videoWriter);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to generate input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [signal, times] = generateInputSignal(triagAmp, pulseAmp, numSamples)
%     pointTimes = [0; 0.25; 0.5; ...
%             0.75; 1.0; 1.25; 1.5; ...
%             1.75];
%     pointSignal = [0; -triagAmp; 0;...
%             0.5; 0.5; pulseAmp; 0; ...
%             0;];
    pointTimes = [0; 0.5; 1.0];
    pointSignal = [0; pulseAmp; 0];
    times = linspace(0, pointTimes(end), numSamples);
    signal = interp1(pointTimes, pointSignal, times);
    
    times = times(:);
    signal = signal(:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to generate Phi from existing PreisachRelaysModel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function output = Phi(baseModel, triagAmp, pulseAmp)
    relays = baseModel.relays;
    baseModel.resetRelaysOff();
    baseModel.updateRelays(-triagAmp);
    baseModel.updateRelays(pulseAmp);
    baseModel.updateRelays(0);
    output = baseModel.getOutput();
    baseModel.relays= relays;
end