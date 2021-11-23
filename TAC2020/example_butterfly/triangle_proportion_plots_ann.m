clear all
close all
clc

umin=-1;
umax=1;
l=(umax-umin)/2;
umid=(umax+umin)/2;

Ttotal=(l^2)/2;
mu=1;

n=1000;
u=[linspace(umin,umax,n),linspace(umax,umin,n)];
y=0;

T1=1;
T2=floor(n/2);
T3=n;
T4=floor(3*n/2);
T5=2*n;

for i=T1:T2
    u(i)= (((umid-umin)/(T2-T1))*i)^2 + umin;
    gamma=((u(i)-umin)^2)/(l^2);
    delta=0;
    ro=0;
    sigma=0;
    y(i)=-Ttotal*abs(mu)*(gamma-(1-gamma))-Ttotal*abs(mu)*(delta-(1-delta))+Ttotal*abs(mu)*(ro-(1-ro))+Ttotal*abs(mu)*(sigma-(1-sigma));
end
for i=T2:T3
    u(i)= (((umax-umid)/(T3-T2))*(i-T2))^2 + umid;
    gamma=1;
    delta=1-(l-(u(i)-umid))^2/(l^2);
    ro=(u(i)-umid)^2/(l^2);
    sigma=(u(i)-umid)^2/(l^2);
    y(i)=-Ttotal*abs(mu)*(gamma-(1-gamma))-Ttotal*abs(mu)*(delta-(1-delta))+Ttotal*abs(mu)*(ro-(1-ro))+Ttotal*abs(mu)*(sigma-(1-sigma));
end
for i=T3:T4
    u(i)= -(((umax-umid)/(T3-T4))*(i-T3))^2 + umax;
    gamma=1;
    delta=1;
    ro=1;
    sigma=1-(umax-u(i))^2/(l^2);
    y(i)=-Ttotal*abs(mu)*(gamma-(1-gamma))-Ttotal*abs(mu)*(delta-(1-delta))+Ttotal*abs(mu)*(ro-(1-ro))+Ttotal*abs(mu)*(sigma-(1-sigma));
end
for i=T4:T5
    gamma=1-(umid-u(i))^2/(l^2);
    delta=1-(umid-u(i))^2/(l^2);
    ro=(l-(umid-u(i)))^2/(l^2);
    sigma=0;
    y(i)=-Ttotal*abs(mu)*(gamma-(1-gamma))-Ttotal*abs(mu)*(delta-(1-delta))+Ttotal*abs(mu)*(ro-(1-ro))+Ttotal*abs(mu)*(sigma-(1-sigma));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Butterfly plot

fig=figure(1);
hold on
grid off
uy1=plot(u(T1:T2),y(T1:T2),'b');
uy2=plot(u(T2:T3),y(T2:T3),'g');
uy3=plot(u(T3:T4),y(T3:T4),'r');
uy4=plot(u(T4:T5),y(T4:T5),'y');

lw=1.3;
set(uy1,'linewidth',lw);
set(uy2,'linewidth',lw);
set(uy3,'linewidth',lw);
set(uy4,'linewidth',lw);
set(uy1,'color',[0 0 0]);
set(uy2,'color',[0 0 0]);
set(uy3,'color',[0 0 0]);
set(uy4,'color',[0 0 0]);
set(uy1,'linestyle','-');
set(uy2,'linestyle','--');
set(uy3,'linestyle',':');
set(uy4,'linestyle','-.');

annFontSize = 14;
legFontSize = 14;
labelFontSize = 14;
tickFontSize = 14;
% legend({'$\mathcal{P}(u,L_0)(t)\ |\ t_1 \leq t < t_2$',...
%     '$\mathcal{P}(u,L_0)(t)\ |\ t_2 \leq t < t_3$',...
%     '$\mathcal{P}(u,L_0)(t)\ |\ t_3 \leq t < t_4$',...
%     '$\mathcal{P}(u,L_0)(t)\ |\ t_4 \leq t \leq t_5$'},...
%     'interpreter','latex',...
%     'FontSize',legFontSize);
xlabel('$u(t)$',...
    'interpreter','latex',...
    'FontSize',labelFontSize);
ylabel('$\mathcal{P}(u,L_0)(t)$',...
    'interpreter','latex',...
    'FontSize',labelFontSize);
set(gca,'XTick',[umin:umax],...
    'XTickLabel',{'$u_{min}$','','$u_{max}$'},...
    'TickLabelInterpreter','latex',...
    'FontSize',tickFontSize);
set(gca,'YTick',[],'YTickLabel',{},...
    'TickLabelInterpreter','latex',...
    'FontSize',tickFontSize);
% set(get(gca,'YLabel'),'Rotation',0);
% set(get(gca,'YLabel'),'Position',get(get(gca,'Ylabel'),'Position')+[-0.425 0 0]);

axis('equal');
axis([-1.2 1.2 -1.5 0.25]);
drawnow;

% Add annotation
midIdx = find(uy1.XData>=umin*1/2-0.01,1,'first');
set(gcf,'Units','normalized');
[h1xMFig,h1yMFig] = axescoord2figurecoord(uy1.XData(midIdx), uy1.YData(midIdx));
annotation('textarrow',...
    [h1xMFig+0.02, h1xMFig+0.0025],...
    [h1yMFig+0.08, h1yMFig+0.0025],...
    'String','$t \in [t_1,t_2]$',...
    'interpreter','latex',...
    'fontsize',annFontSize);
drawnow;

% Add annotation
midIdx = find(uy3.XData<=umax*1/2+0.01,1,'first');
set(gcf,'Units','normalized');
[h3xMFig,h3yMFig] = axescoord2figurecoord(uy3.XData(midIdx), uy3.YData(midIdx));
annotation('textarrow',...
    [h3xMFig-0.02, h3xMFig-0.0025],...
    [h3yMFig+0.08, h3yMFig+0.0025],...
    'String','$t \in [t_3,t_4]$',...
    'interpreter','latex',...
    'fontsize',annFontSize);
drawnow;

% Add annotation
midIdx = find(uy2.XData>=umax*1/2+0.01,1,'first');
set(gcf,'Units','normalized');
[h2xMFig,h2yMFig] = axescoord2figurecoord(uy2.XData(midIdx), uy2.YData(midIdx));
annotation('textarrow',...
    [h2xMFig+0.05, h2xMFig+0.0025],...
    [h2yMFig-0.02, h2yMFig+0.0025],...
    'String','$t \in [t_2,t_3]$',...
    'interpreter','latex',...
    'fontsize',annFontSize);
drawnow;

% Add annotation
midIdx = find(uy4.XData<=umin*1/2+0.01,1,'first');
set(gcf,'Units','normalized');
[h4xMFig,h4yMFig] = axescoord2figurecoord(uy4.XData(midIdx), uy4.YData(midIdx));
annotation('textarrow',...
    [h4xMFig-0.05, h4xMFig-0.0025],...
    [h4yMFig-0.02, h4yMFig+0.0025],...
    'String','$t \in [t_4,t_5]$',...
    'interpreter','latex',...
    'fontsize',annFontSize);
drawnow;

saveas(fig,'example_butterfly_phase','epsc');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Input plot

shift=floor(2*n/10);
u=[zeros(1,shift),u];

T1=1+shift;
T2=floor(n/2)+shift;
T3=n+shift;
T4=floor(3*n/2)+shift;
T5=2*n+shift;

fig=figure(2);
hold on
grid off
u1=plot([T1:T2],u(T1:T2),'b');
u2=plot([T2:T3],u(T2:T3),'g');
u3=plot([T3:T4],u(T3:T4),'r');
u4=plot([T4:T5],u(T4:T5),'y');

lw=1.3;
set(u1,'linewidth',lw);
set(u2,'linewidth',lw);
set(u3,'linewidth',lw);
set(u4,'linewidth',lw);
set(u1,'color',[0 0 0]);
set(u2,'color',[0 0 0]);
set(u3,'color',[0 0 0]);
set(u4,'color',[0 0 0]);
set(u1,'linestyle','-');
set(u2,'linestyle','--');
set(u3,'linestyle',':');
set(u4,'linestyle','-.');

legFontSize = 18;
labelFontSize = 18;
tickFontSize = 18;
% legend({'$u(t)\ |\ t_1 \leq t < t_2$',...
%     '$u(t)\ |\ t_2 \leq t < t_3$',...
%     '$u(t)\ |\ t_3 \leq t < t_4$',...
%     '$u(t)\ |\ t_4 \leq t < t_5$'},...
%     'interpreter','latex',...
%     'FontSize',legFontSize);
xlabel('$t$',...
    'interpreter','latex',...
    'FontSize',labelFontSize);
ylabel('$u(t)$',...
    'interpreter','latex',...
    'FontSize',labelFontSize);
set(gca,'XTick',[T1,T2,T3,T4,T5],...
    'XTickLabel',{'$t_1$','$t_2$','$t_3$','$t_4$','$t_5$'},...
    'TickLabelInterpreter','latex',...
    'FontSize',tickFontSize);
set(gca,'YTick',[umin:umax],'YTickLabel',{'$u_{min}$','$0$','$u_{max}$'},...
    'TickLabelInterpreter','latex',...
    'FontSize',tickFontSize);
% set(get(gca,'YLabel'),'Rotation',0);
% set(get(gca,'YLabel'),'Position',get(get(gca,'Ylabel'),'Position')+[-0.35 -0.05 0]);

% axis('equal')
axis([0 T5*1.2 umin*1 umax*1.2])
drawnow;
saveas(fig,'example_butterfly_input','epsc');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Output plot

y=[zeros(1,shift),y];

fig=figure(3);
hold on
grid off
y1=plot([T1:T2],y(T1:T2),'b');
y2=plot([T2:T3],y(T2:T3),'g');
y3=plot([T3:T4],y(T3:T4),'r');
y4=plot([T4:T5],y(T4:T5),'y');

lw=1.3;
set(y1,'linewidth',lw);
set(y2,'linewidth',lw);
set(y3,'linewidth',lw);
set(y4,'linewidth',lw);
set(y1,'color',[0 0 0]);
set(y2,'color',[0 0 0]);
set(y3,'color',[0 0 0]);
set(y4,'color',[0 0 0]);
set(y1,'linestyle','-');
set(y2,'linestyle','--');
set(y3,'linestyle',':');
set(y4,'linestyle','-.');

legFontSize = 18;
labelFontSize = 18;
tickFontSize = 18;
% legend({'$\mathcal{P}(u,L_0)(t)\ |\ t_1 \leq t < t_2$'...
%     ,'$\mathcal{P}(u,L_0)(t)\ |\ t_2 \leq t < t_3$'...
%     ,'$\mathcal{P}(u,L_0)(t)\ |\ t_3 \leq t < t_4$'...
%     ,'$\mathcal{P}(u,L_0)(t)\ |\ t_4 \leq t < t_5$'},...
%     'interpreter','latex',...
%     'FontSize',legFontSize);
xlabel('$t$',...
    'interpreter','latex',...
    'FontSize',labelFontSize);
ylabel('$\mathcal{P}(u,L_0)(t)$',...
    'interpreter','latex',...
    'FontSize',labelFontSize);
set(gca,'XTick',[T1,T2,T3,T4,T5],...
    'XTickLabel',{'$t_1$','$t_2$','$t_3$','$t_4$','$t_5$'},...
    'TickLabelInterpreter','latex',...
    'FontSize',tickFontSize);
set(gca,'YTick',[],...
    'YTickLabel',{},...
    'TickLabelInterpreter','latex',...
    'FontSize',tickFontSize);
% set(get(gca,'YLabel'),'Rotation',0);
% set(get(gca,'YLabel'),'Position',get(get(gca,'Ylabel'),'Position')+[-190.0 0 0]);

% axis('equal')
axis([0 T5*1.2 min(y)*1.05 max(y)+0.05])
drawnow;
saveas(fig,'example_butterfly_output','epsc');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function getPoint(varargin)
    currentPoint = get(gca, 'CurrentPoint');
    fprintf('Hit Point! Coordinates: %f, %f \n', ... 
           currentPoint(1), currentPoint(3));
end
