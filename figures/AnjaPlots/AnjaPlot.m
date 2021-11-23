close all
clc

% Filter to use to find the date:
% fitMatchFilter = 'PNZT_x0.47_.*x3.*1200V';

% Save data
% time = dataHandler.inputSeq
voltage = dataHandler.inputSeq;
strain = dataHandler.outputSeq;
save('plot_data.mat','voltage','strain');

% Plot data
lineWidth = 1.2;
plot(voltage, strain, '-b', 'LineWidth', lineWidth);
xlabel('V')
ylabel('nm')
xticks([-1200,-600,0,600,1200])
yticks([-800,-400,0,400,800,1200])
grid on
axis square
% xlabel('V', 'Interpreter', 'Latex')
% ylabel('nm', 'Interpreter', 'Latex')
% grid on
% xlims([])
% ylims([])

