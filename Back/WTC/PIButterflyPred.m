close all
clearvars
% ----Initial Values----
M = 50;

load Serie1.mat
v = V_S1_1600V_05Hz;
dis = D1_S1_1600V_05Hz;
v_pred = V_S1_1300V_05Hz;
dis_pred = D1_S1_1300V_05Hz;
N = size(v, 1);

%----Construct Relays----
disp('Start Relay Construction')
InfNormV = norm(v,inf);
for i = 1:M
    r(i) = (i-1)/M*InfNormV; 
end
[F, Fas] = Backlash(v, M, r);
disp('Relay Contstruction Finished')

F = Fas; % Use F=Fas for the asymmetrical PI model

%----Least Squares----
disp('Start Least Squares')
mu = pinv(F'*F)*F'*dis;
y = F*mu;
disp([num2str(round(norm(y-dis)/norm(dis)*100,2)), '% error for ', num2str(M), ' backlash operators.']);
disp('Least Squares Finished')

%----Prediction----
[F, Fas] = Backlash(v_pred,M,r);
F = Fas;
y_pred = F*mu;
y_pred = y_pred  - y_pred(1);
disp([num2str(round(norm(y_pred-dis_pred)/norm(dis_pred)*100,2)), '% prediction error.']);

%----Display----
disp('Start Display')
figure
plot(v, dis, v, y, v_pred,dis_pred, v_pred, y_pred);
legend('Exp. Data 1.6kV', 'Fit for 1.6kV', 'Exp Data 1.3kV', 'Prediction 1.3kV');
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