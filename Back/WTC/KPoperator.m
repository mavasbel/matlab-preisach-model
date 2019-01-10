function[Kp, Kp2D] = KPoperator(v,M,rho,a)
N = size(v, 1);
Kp = zeros(N,M+1,M+1);
Kp2D = zeros(N,(M^2+M)/2+1);

vmax = max(v);
vmin = min(v);
vdot = diff(v);
vdot = [vdot; vdot(N-1)];

%----CCW Relay Initial Loop----
Kp(1,:,:) = 0;
for t = 2:N
    for i = 1:M
        for j = i+1:M+1
            if vdot(t) > 0
                if v(t) <= rho(j)
                    Kp(t,i,j) = -1;
                elseif v(t) >= rho(j) + a
                    Kp(t,i,j) = 1;
                else 
                    Kp(t,i,j) = -1 + 2/a*(v(t)-rho(j));
                end
            else
                if v(t) <= rho(i)
                    Kp(t,i,j) = -1;
                elseif v(t) >= rho(i) + a
                    Kp(t,i,j) = 1;
                else 
                    Kp(t,i,j) = -1 + 2/a*(v(t)-rho(i));
                end
            end
        end
    end
end

%----CCW Relay Completion Loop----
Kp(1,:,:) = Kp(end,:,:);
for t = 2:N
    for i = 1:M
        for j = i+1:M+1
            if vdot(t) > 0
                if v(t) <= rho(j)
                    Kp(t,i,j) = -1;
                elseif v(t) >= rho(j) + a
                    Kp(t,i,j) = 1;
                else 
                    Kp(t,i,j) = -1 + 2/a*(v(t)-rho(j));
                end
            else
                if v(t) <= rho(i)
                    Kp(t,i,j) = -1;
                elseif v(t) >= rho(i) + a
                    Kp(t,i,j) = 1;
                else 
                    Kp(t,i,j) = -1 + 2/a*(v(t)-rho(i));
                end
            end
        end
    end
end

%----Disregard Operators Outside Input Range----
for i = 1:M
    for j = i+1:M+1
        if vmax < rho(j) + a || vmin > rho(i)
        Kp(:,i,j) = 0;
        end
    end
end        

%----Kp3D to Kp2D----
Kp2D(:,1) = 1; %Shifting Operator
k = 2;
for i = 1:M
    for j = i+1:M+1
        Kp2D(:,k) = Kp(:,i,j);
        k = k+1;
    end
end

%----Display KP operators----
% for i = 1:M
% 	for j = i+1:M+1
%         figure
%         plot(v,Kp(:,i,j))
%         title(['\rho_1 = ' num2str(i) ', \rho_2 = ' num2str(j)])
%     end
% end