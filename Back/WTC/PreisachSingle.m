close all
clearvars
% ----Initial Values----
M = 50; 

load MeasurementData.mat
v = Vplus_15kv;
dis = Displacement_15kv;
N = size(v, 1);
p2D = zeros(M+1,M+1);

%----Alpha Beta Initialization
alphabeta = linspace(min(v), max(v), M+1);

%----Construct Relays----
disp('Start Relay Construction')
[R, R2D] = Relays(v,M,alphabeta);
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
z = surf(alphabeta, alphabeta, p2D);
xlabel('alpha')
ylabel('beta')
title('Relay Weights')
colorbar
for k = 1:length(z)
    zdata = z(k).ZData;
    z(k).CData = zdata;
    z(k).FaceColor = 'interp';
end
view(-270, -90)

figure
plot(v, p(1)*R2D(:,1), '--')
LegendInfo{1}= ['\mu_{shift} = ', num2str(round(p(1),3))];
hold on
k = 2;
for i = 1:M
    for j = i+1:M+1
        plot(v, p2D(i,j)*R(:,i,j), '--')
        LegendInfo{k}= ['\mu(', num2str(i), ',', num2str(j), ') = ', num2str(round(p2D(i,j),3))];
        k = k+1;
    end
end
plot(v, y, 'k')
LegendInfo{k}= ['Preisach'];
legend(LegendInfo)
hold off

figure
plot(v, dis, 'b', v, y, 'r')
legend('Exp. Data','Preisach')
disp('Display Finished')