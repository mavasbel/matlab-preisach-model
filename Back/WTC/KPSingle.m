close all
clearvars
% ----Initial Values----
M = 50;

load MeasurementData.mat
v = Vplus_15kv;
dis = Displacement_15kv;
N = size(v, 1);
p2D = zeros(M+1,M+1);

%----Parameter a----
a=225;

%----Rho Initialization
rho = linspace(min(v), max(v)-a, M+1);

%----Construct Relays----
disp('Start KP operator Construction')
[Kp, Kp2D] = KPoperator(v,M,rho,a);
disp('Operator Contstruction Finished')

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

%----P1D to P2D----
k = 2;
for i = 1:M
    for j = i+1:M+1
        p2D(i,j) = p(k);
        k = k+1;
    end
end

%----Display----
disp('Start Display')
z = surf(rho, rho, p2D);
xlabel('\rho_2')
ylabel('\rho_1')
title('Operator Weights')
colorbar
for k = 1:length(z)
    zdata = z(k).ZData;
    z(k).CData = zdata;
    z(k).FaceColor = 'interp';
end
view(-270, -90)

figure
plot(v, p(1)*Kp2D(:,1), '--')
LegendInfo{1}= ['\mu_{shift} = ', num2str(round(p(1),3))];
hold on
k = 2;
for i = 1:M
    for j = i+1:M+1
        plot(v, p2D(i,j)*Kp(:,i,j), '--')
        LegendInfo{k}= ['\mu(', num2str(i), ',', num2str(j), ') = ', num2str(round(p2D(i,j),3))];
        k = k+1;
    end
end
plot(v, y, 'k')
LegendInfo{k}= ['KP'];
legend(LegendInfo)
hold off

figure
plot(v, dis, 'b', v, y, 'r')
legend('Exp. Data','KP')
disp('Display Finished')