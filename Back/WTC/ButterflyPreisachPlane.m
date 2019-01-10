clearvars
% ----Initial Values----
M = 10;
COP = 7;                                                                    %Crossover Point

load Serie1.mat
v = V_S1_1500V_05Hz;
dis = D1_S1_1500V_05Hz;

N = size(v, 1);
R = zeros(N,M+1,M+1);
y = zeros(N);

a = 1;
b = -1;

%----Alpha Beta Initialization
alphabeta = linspace(min(v), max(v), M+1);

%----CW Relay Initial Loop----
R(1,:,:) = 0;
for t = 2:N
    for i = 1:M
        for j = i+1:M+1
            if v(t) <= alphabeta(i)
                R(t,i,j) = a;
            elseif v(t) >= alphabeta(j)
                R(t,i,j) = b; 
            else 
                R(t,i,j) = R(t-1,i,j);
            end
        end
    end
end

%----CW Relay Completion Loop----
R(1,:,:) = R(end,:,:);
for t = 2:N
    for i = 1:M
        for j = i+1:M+1
            if v(t) <= alphabeta(i)
                R(t,i,j) = a;
            elseif v(t) >= alphabeta(j)
                R(t,i,j) = b; 
            else 
                R(t,i,j) = R(t-1,i,j);
            end
        end
    end
end

for i = 1:M
    for j = i+1:M+1
        if i >= COP
            y = y + R(:,i,j);
        elseif j <= COP
            y = y - R(:,i,j);
        elseif COP - i > j - COP
            y = y - R(:,i,j);
        elseif COP - i < j - COP
            y = y + R(:,i,j);
        else
            y = y;
        end
    end
end

plot(v, y)
            




