close all
clc

lw = 2;
lwdash = 1.5;

figure
hold on
grid on
plot(xt.Time,xt.Data(:,1), 'linewidth', lw, 'linestyle', '-')
plot(xt.Time,xt.Data(:,2), 'linewidth', lw, 'linestyle', '-')
plot(xt.Time,xt.Data(:,3), 'linewidth', lw, 'linestyle', '-')
xlabel('t','fontsize',11);
legend('x_1(t)', 'x_2(t)', 'x_3(t)')
xlim([0,5])

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
xlabel('u','fontsize',11);
ylabel('\Phi(u)','fontsize',11,'Rotation',0);
xlim([-1.1,1.1])
ylim([-1 1])