close all
clc

lw = 3;
lwdash = 2;

figure
hold on
grid on
plot(xt.Time,xt.Data(:,1), 'linewidth', lw, 'linestyle', '-')
plot(xt.Time,xt.Data(:,2), 'linewidth', lw, 'linestyle', '-')
plot(xt.Time,xt.Data(:,3), 'linewidth', lw, 'linestyle', '-')
set(get(gca,'XAxis'),'FontSize', 14);
set(get(gca,'YAxis'),'FontSize', 14);
xlabel('$t$','fontsize',16);
legend({'$x_1(t)$', '$x_2(t)$', '$x_3(t)$'},'fontsize',16)
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
plot(dataHandler.inputSeq(T1:T2),dataHandler.outputSeq(T1:T2),'k','linewidth',lwdash,'linestyle','--');
plot(dataHandler.inputSeq(T2:T3),dataHandler.outputSeq(T2:T3),'k','linewidth',lwdash,'linestyle','--');
plot(tline,Phik*tline,'r','linewidth',lwdash,'linestyle','--');
plot(Phiu.Data,Phiy.Data,'b','linewidth',lw,'linestyle','-')
plot(Phiu.Data,Phiy.Data,'b','linewidth',lw,'linestyle','-')
plot(Phiu.Data(1),Phiy.Data(1),'ob','linewidth',lw,'markersize',10)
plot(Phiu.Data(end),Phiy.Data(end),'xb','linewidth',lw,'markersize',14)
set(get(gca,'XAxis'),'FontSize', 14);
set(get(gca,'YAxis'),'FontSize', 14);
xlabel('$u$','fontsize',16);
% ylabel('\Phi(u)','Rotation',0,'fontsize',16);
ylabel('$\mathcal{P}(u,L_0)$','fontsize',16);
xlim([-1.1,1.1])
ylim([-1 1])