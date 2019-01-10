close all
clearvars
% ----Initial Values----
M =50;

load Serie1.mat
v = V_S1_1600V_05Hz;
dis = D1_S1_1600V_05Hz;
N = size(v, 1);

%----Construct Backlash Operators----
disp('Start Backlash Construction')
InfNormV = norm(v,inf);
for i = 1:M
    r(i) = (i-1)/M*InfNormV; 
end
[F, Fas] = Backlash(v,M,r);
disp('Backlash Contstruction Finished')

F = Fas; % Use F=Fas for the asymmetrical PI model

%----Least Squares----
disp('Start Least Squares')
mu = pinv(F'*F)*F'*dis;
y = F*mu;
disp([num2str(round(norm(y-dis)/norm(dis)*100,2)), '% error for ', num2str(M), ' backlash operators.']);
disp('Least Squares Finished')

%----Display----
disp('Start Display')
plot(r, mu(1:M))

figure
plot(v, mu(2*M+1)*F(:,2*M+1), '--')
LegendInfo{1}= ['\mu_{shift} = ', num2str(round(mu(2*M+1),3))];
hold on
k = 2;
for i = 1:2*M
    plot(v, mu(i)*F(:,i), '--')
    LegendInfo{k}= ['\mu(', num2str(i),') = ', num2str(round(mu(i),3))];
    k = k+1;
end
plot(v, y, 'k')
LegendInfo{k}= ['Sum Backlashes'];
plot(v, dis)
LegendInfo{k+1}= ['Exp. Data'];
legend(LegendInfo)
hold off
xlim([-1700, 1700])
ylim([-1400, 1100])
xticks([-1600 1600])
xticklabels({num2str(-1600),num2str(1600)})
yticks([-1000 1000])
yticklabels({num2str(-1000),num2str(1000)})
xlabel('u(t)')
ylabel('\epsilon')
set(get(gca,'ylabel'),'rotation',0)
set(gca, 'FontSize', 15)

figure
plot(v, dis, 'b', v, y, 'r')
legend('Exp. Data','PI')
xlim([-1700, 1700])
ylim([-1400, 1100])
xticks([-1600 1600])
xticklabels({num2str(-1600),num2str(1600)})
yticks([-1000 1000])
yticklabels({num2str(-1000),num2str(1000)})
xlabel('u(t)')
ylabel('\epsilon')
set(get(gca,'ylabel'),'rotation',0)
set(gca, 'FontSize', 15)
disp('Display Finished')