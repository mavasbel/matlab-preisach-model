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
p2D = zeros(M+1,M+1);

%----Parameter a----
a=225;

%----Rho Initialization
rho = linspace(min(v), max(v)-a, M+1);

%----Construct Relays----
disp('Start KP operator Construction')
[~, Kp2D] = KPoperator(v,M,rho,a);
disp('operator Contstruction Finished')

%----SVD----
disp('Start Singular Value Decomposition')
[U,S,V] = svd(Kp2D'*Kp2D);
p=0;
for i = 1:(M^2+M)/2
    if S(i,i) > 10e-1
    p = p + U(:,i)'*(Kp2D'*dis)./S(i,i)*V(:,i);
    end
end
y = Kp2D*p;
disp([num2str(round(norm(y-dis)/norm(dis-p(1))*100,2)), '% error for ', num2str(.5*(M^2+M)), ' operators.']);
disp('Singular Value Decomposition Finished')

%----Prediction----
[~, Kp2D] = KPoperator(v_pred,M,rho,a);
y_pred = Kp2D*p;
y_pred = y_pred  - y_pred(1);
disp([num2str(round(norm(y_pred-dis_pred)/norm(dis_pred-p(1))*100,2)), '% prediction error']);

%----Display----
disp('Start Display')
figure
plot(v, dis, v, y, v_pred, dis_pred, v_pred, y_pred);
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