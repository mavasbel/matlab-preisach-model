close all;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data handler and model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load Serie1.mat
dataHandler = DataHandler(V_S1_1600V_05Hz, D1_S1_1600V_05Hz);
dataHandler.resetOrigSequences();
dataHandler.interpSequence(401);
dataHandler.printInfo();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot originals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lineWidth = 1.25;
labelSize = 20;
tickSize = 16;
legendSize = 16;
inputLimFactor = 0.2;
outputLimFactor = 0.2;
inputTicks = linspace(-1600, 1600, 5);
outputTicks = linspace(-1000, 1000, 5);
plotLegStr = string(['Exp Data']);

fig = figure;
plotHandler = plot(dataHandler.inputSeq, dataHandler.outputSeq,...
    'color', 'k', 'linewidth', lineWidth);
plotLeg = legend(cellstr(plotLegStr), 'fontsize', legendSize);
set(plotLeg, 'Interpreter', 'none');
xticks(inputTicks)
yticks(outputTicks)
set(gca, 'XTick', inputTicks,...
    'XTickLabel', strtrim(cellstr(num2str(inputTicks', '%.0f'))),...
    'fontsize', tickSize);
set(gca, 'YTick', outputTicks,...
    'YTickLabel', strtrim(cellstr(num2str(outputTicks', '%.0f'))),...
    'fontsize', tickSize);
xlabel('\it E (kV/cm)', 'fontsize', labelSize);
ylabel('\epsilon \it(nm)', 'fontsize', labelSize');
xlim([dataHandler.inputMin-dataHandler.inputAmp*inputLimFactor,...
    dataHandler.inputMax+dataHandler.inputAmp*inputLimFactor])
ylim([dataHandler.outputMin-dataHandler.outputAmp*outputLimFactor,...
    dataHandler.outputMax+dataHandler.outputAmp*outputLimFactor])
hold on; grid on;
drawnow

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fitting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
resolutions = [10, 25, 50];
colors = [0, 0, 1;
        1, 0, 0;
        0, 0.4470, 0.7410];
for res=1:length(resolutions)
    inputInterFact = -0.005;
    preisachRelayModel = PreisachRelayModel(...
        [dataHandler.inputMin-dataHandler.inputAmp*inputInterFact, ...
        dataHandler.inputMax+dataHandler.inputAmp*inputInterFact], ...
        resolutions(res));
    preisachRelayModel.printInfo();

    preisachUtils = PreisachRelayUtils(preisachRelayModel);
    [filterTime, fittingTime, weightFuncTime] = preisachUtils...
        .fitModel(dataHandler.inputSeq, dataHandler.outputSeq);

    % Generating fitted output
    fittedOutputTic = tic;
    preisachRelayModel.resetRelaysOff();
    [fittedOutputSeq, fittedRelaysSeq] = preisachUtils.generateOutputSeq(dataHandler.inputSeq);
    fittedOutputTime = toc(fittedOutputTic);
    
    % Error calculation
    printFittingInfo(dataHandler, fittedOutputSeq(:), filterTime, fittingTime, weightFuncTime, fittedOutputTime);
    
    % Plotting
    plot(dataHandler.inputSeq, fittedOutputSeq,...
        'color', colors(res,:), 'linewidth', lineWidth);
    plotLegStr = cellstr([plotLegStr, string(strcat(...
        [num2str( resolutions(res)*(resolutions(res)+1)/2 ), ' Relays'] ))]);
    plotLeg = legend(plotLegStr, 'fontsize', legendSize);
    set(plotLeg, 'Interpreter', 'none');
    drawnow
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function printFittingInfo(dataHandler, fittedOutputSeq, filterTime, fittingTime, weightFuncTime, fittedOutputTime)
    errorVector = abs( fittedOutputSeq(:) - dataHandler.outputSeq(:) );
    relativeErrorVector = errorVector./abs(dataHandler.outputMax - dataHandler.outputMin);
    disp('--Fit results--');
    disp(['Filtering time: ', num2str(mean(filterTime)), ' seconds']);
    disp(['Fitting time: ', num2str(mean(fittingTime)), ' seconds']);
    disp(['Weightplane time: ', num2str(mean(weightFuncTime)), ' seconds']);
    disp(['Output time: ', num2str(mean(fittedOutputTime)), ' seconds']);
    disp(['Min absolute error: ', num2str(min(errorVector))]);
    disp(['Max absolute error: ', num2str(max(errorVector))]);
    disp(['Mean absolute error: ', num2str(mean(errorVector))]);
    disp(['Min relative error: ', num2str(min(relativeErrorVector))]);
    disp(['Max relative error: ', num2str(max(relativeErrorVector))]);
    disp(['Mean relative error: ', num2str(mean(relativeErrorVector))]);
end