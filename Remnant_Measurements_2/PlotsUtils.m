%% Single pulse axis ticks
handler = gca;
get(handler,'yTick');
set(handler,'yTick',[0,1000,1400]);
set(handler,'yTickLabel',{'0V', ...
    'Pulse Amp', ...
    'Initialization Amp'});

%% Multi pulse axis ticks
% handler = gca;
% get(handler,'yTick');
% set(handler,'yTick',[0,600,1000,1400]);
% set(handler,'yTickLabel',{'0V', ...
%     'Pulse 2 Amp', ...
%     'Pulse 1 Amp', ...
%     'Initialization Amp'});

%% Create plot of ideal remnant change
pulseAmp = linspace(0, 10, 1000);
difference = horzcat(linspace(0, 0, 700), linspace(0, 100, 300) );
plot(pulseAmp, difference, 'LineWidth', 2.0);
grid on;
handlerAxes = gca;
ylim([-20,100])
ylabel('Remnant Difference (nm)');
hanlderXLabel = xlabel('Pulse 2 Amp (V)');
set(handlerAxes,'yTick',[0]);
set(handlerAxes,'yTickLabel',{'0 nm'});
set(handlerAxes,'xTick',[0 7 10]);
set(handlerAxes,'xTickLabel',{'0V', 'Pulse 1 Amp', ''});
set(hanlderXLabel, 'position', get(hanlderXLabel, 'position') + [0 -1 0]);
