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

legend('\Phi(u(t)) | T_1 \leq t < T_2'...
    ,'\Phi(u(t)) | T_2 \leq t < T_3'...
    ,'\Phi(u(t)) | T_3 \leq t < T_4'...
    ,'\Phi(u(t)) | T_4 \leq t < T_5');
xlabel('u(t)');
ylabel('\Phi(u(t))');
set(gca,'XTick',[umin:umax],'XTickLabel',{'u_{min}','','u_{max}'});
set(gca,'YTick',[],'YTickLabel',{});
set(get(gca,'YLabel'),'Rotation',0);
set(get(gca,'YLabel'),'Position',get(get(gca,'Ylabel'),'Position')+[-0.4 0 0]);

axis('equal');
axis([-1.2 1.2 -1.6 0.8]);

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

legend('u(t) | T_1 \leq t < T_2'...
    ,'u(t) | T_2 \leq t < T_3'...
    ,'u(t) | T_3 \leq t < T_4'...
    ,'u(t) | T_4 \leq t < T_5');
xlabel('t','fontsize',11);
ylabel('u(t)','fontsize',11);
set(gca,'XTick',[T1,T2,T3,T4,T5],'XTickLabel',{'T_1','T_2','T_3','T_4','T_5'},'fontsize',10);
set(gca,'YTick',[umin:umax],'YTickLabel',{'u_{min}','0','u_{max}'},'fontsize',10);
set(get(gca,'YLabel'),'Rotation',0);
set(get(gca,'YLabel'),'Position',get(get(gca,'Ylabel'),'Position')+[-0.3 0 0]);

% axis('equal')
axis([0 T5*1.2 umin*1 umax*1.2])

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

legend('\Phi(t) | T_1 \leq t < T_2'...
    ,'\Phi(t) | T_2 \leq t < T_3'...
    ,'\Phi(t) | T_3 \leq t < T_4'...
    ,'\Phi(t) | T_4 \leq t < T_5');
xlabel('t','fontsize',11);
ylabel('\Phi(t)','fontsize',11);
set(gca,'XTick',[T1,T2,T3,T4,T5],'XTickLabel',{'T_1','T_2','T_3','T_4','T_5'},'fontsize',10);
set(gca,'YTick',[],'YTickLabel',{},'fontsize',10);
set(get(gca,'YLabel'),'Rotation',0);
set(get(gca,'YLabel'),'Position',get(get(gca,'Ylabel'),'Position')+[-100.0 0 0]);

% axis('equal')
axis([0 T5*1.2 min(y)*1.05 max(y)+0.05])