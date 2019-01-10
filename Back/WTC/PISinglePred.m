close all
clearvars
% ----Initial Values----
M = 50;

load MeasurementData.mat
v = Vplus_15kv;
dis = Displacement_15kv;
v_pred = Vplus_11kv;
dis_pred = Displacement_11kv;
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
legend('Exp. Data 1.5kV', 'Fit for 1.5kV', 'Exp Data 1.1kV', 'Prediction 1.1kV');
xlim([-1600, 1600])
ylim([-500, 1200])
xticks([-1500 1500])
xticklabels({num2str(-1500),num2str(1500)})
yticks([-300 1100])
yticklabels({num2str(-300),num2str(1100)})
xlabel('u(t)')
ylabel('\epsilon')
set(get(gca,'ylabel'),'rotation',0)
set(gca, 'FontSize', 15)
disp('Display Finished')