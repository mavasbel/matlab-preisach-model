close all
clearvars
% ----Initial Values----
M = 50;

load MeasurementData.mat
v = Vplus_15kv;
dis = Displacement_15kv;
v_pred = Vplus_1kv;
dis_pred = Displacement_1kv;
N = size(v, 1);
p2D = zeros(M+1,M+1);

%----Alpha Beta Initialization
alphabeta = linspace(min(v), max(v), M+1);

%----Construct Relays----
disp('Start Relay Construction')
[~, R2D] = Relays(v,M,alphabeta);
disp('Relay Contstruction Finished')

%----SVD----
disp('Start Singular Value Decomposition')
[U,S,V] = svd(R2D'*R2D);
p=0;
for i = 1:(M^2+M)/2
    if S(i,i) > 10e-1
    p = p + U(:,i)'*(R2D'*dis)./S(i,i)*V(:,i);
    end
end
y = R2D*p;
disp([num2str(round(norm(y-dis)/norm(dis-p(1))*100,2)), '% error for ', num2str(.5*(M^2+M)), ' relays.']);
disp('Singular Value Decomposition Finished')

%----Prediction----
[~, R2D] = Relays(v_pred,M,alphabeta);
y_pred = R2D*p;
y_pred = y_pred  - y_pred(1);
disp([num2str(round(norm(y_pred-dis_pred)/norm(dis_pred-p(1))*100,2)), '% error for ', num2str(.5*(M^2+M)), ' relays.']);

%----Display----
disp('Start Display')
figure
plot(v, dis, v, y, v_pred,dis_pred, v_pred, y_pred);
legend('Exp. Data 1.5kV', 'Fit for 1.5kV', 'Exp Data 1kV', 'Prediction 1kV');

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