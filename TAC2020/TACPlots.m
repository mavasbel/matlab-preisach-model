close all
clc

labelTextSize = 11;
tickTextSize = 10;
lineWidth = 1.5;
dashLineWidth = 1.5;
markerOSize = 14;
markerOSize = 10;

figure
hold on
grid on
plot(xt.Time,xt.Data(:,1), 'linewidth', lineWidth, 'linestyle', '-')
plot(xt.Time,xt.Data(:,2), 'linewidth', lineWidth, 'linestyle', '-')
plot(xt.Time,xt.Data(:,3), 'linewidth', lineWidth, 'linestyle', '-')
set(get(gca,'XAxis'),'FontSize', tickTextSize);
set(get(gca,'YAxis'),'FontSize', tickTextSize);
xlabel('$t$','interpreter','latex','fontsize',labelTextSize);
legend({'$x_1(t)$','$x_2(t)$','$x_3(t)$'},'interpreter','latex')
xlim([0,8])

figure
hold on
grid on
dataHandler.circShiftInputMinMax();
inputRange = dataHandler.inputMax - dataHandler.inputMin;
outputRange = dataHandler.outputMax - dataHandler.outputMin;
tline = linspace(-2,2,100);
T1=1;
T2=dataHandler.maxInputPeakIdx(1);
T3=dataHandler.sampleLength;
plot(dataHandler.inputSeq(T1:T2),dataHandler.outputSeq(T1:T2),...
    'k','linewidth',dashLineWidth,'linestyle','--');
plot(dataHandler.inputSeq(T2:T3),dataHandler.outputSeq(T2:T3),...
    'k','linewidth',dashLineWidth,'linestyle','--');
plot(tline,Phik*tline,'r','linewidth',dashLineWidth,'linestyle','--');
plot(Phiu.Data,Phiy.Data,'b','linewidth',lineWidth,'linestyle','-')
plot(Phiu.Data,Phiy.Data,'b','linewidth',lineWidth,'linestyle','-')
plot(Phiu.Data(1),Phiy.Data(1),'ob','linewidth',lineWidth,'markersize',markerOSize)
plot(Phiu.Data(end),Phiy.Data(end),'xb','linewidth',lineWidth,'markersize',markerOSize)
set(gca,'fontsize',tickTextSize,'TickLabelInterpreter','latex');
xlabel('$u$','interpreter','latex','fontsize',labelTextSize);
% ylabel('$\mathcal{P}(u,L_0)$','interpreter','latex',...
%     'fontsize',labelTextSize,...
%     'Rotation',0,...
%     'Position',[-1.32 -0.025 0]);
ylabel('$\mathcal{P}(u,L_0)$','interpreter','latex',...
    'fontsize',labelTextSize);
xlim([-1.1,1.1])
ylim([-0.45 0.45])