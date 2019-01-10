function[R, R2D] = Relays(v,M,alphabeta)
N = size(v, 1);
R = zeros(N,M+1,M+1);
R2D = zeros(N,(M^2+M)/2+1);

a = 1;
b = -1;

%----CCW Relay Initial Loop----
R(1,:,:) = 0;
for t = 2:N
    for i = 1:M
        for j = i+1:M+1
            if v(t) <= alphabeta(i)
                R(t,i,j) = b;
            elseif v(t) >= alphabeta(j)
                R(t,i,j) = a; 
            else 
                R(t,i,j) = R(t-1,i,j);
            end
        end
    end
end

%----CCW Relay Completion Loop----
R(1,:,:) = R(end,:,:);
for t = 2:N
    for i = 1:M
        for j = i+1:M+1
            if v(t) <= alphabeta(i)
                R(t,i,j) = b;
            elseif v(t) >= alphabeta(j)
                R(t,i,j) = a; 
            else 
                R(t,i,j) = R(t-1,i,j);
            end
        end
    end
end

%----R3D to R2D----
R2D(:,1) = 1; %Shifting relay
k = 2;
for i = 1:M
    for j = i+1:M+1
        R2D(:,k) = R(:,i,j);
        k = k+1;
    end
end

%----Display Relays----
% for i = 1:M
% 	for j = i+1:M+1
%         figure
%         plot(v,R(:,i,j))
%         title(['beta = ' num2str(i) ', alpha = ' num2str(j)])
%     end
% end