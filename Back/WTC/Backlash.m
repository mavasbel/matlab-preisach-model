function[F, Fas] = Backlash(v, M, r)

%----Initialization----
N = size(v, 1);
F = zeros(N,M);
Fr = zeros(N,2*M);
Fl = zeros(N,2*M);

%----Complete Backlash----
F(1,:) = max(v(1), min(v(1), 0));
for t = 2:N
    for i = 1:M
    F(t,i) = max([v(t) - r(i), min([v(t) + r(i), F(t-1,i)])]);
    end
end

F(1,:) = F(end,:);
for t = 2:N
    for i = 1:M
    F(t,i) = max([v(t) - r(i), min([v(t) + r(i), F(t-1,i)])]);
    end
end

F(:,M+1)=1; %Shifting operator in the symmetrical case

%----RHS/LHS Initialization----
maxv = max(v);
for i = 1:M
    maxFt(i) = max(F(:,i));
end
for i = 2:2:2*M
    z(i) = r(i/2);
    maxF(i) = maxFt(i/2);
end
for i=1:2:2*M
    z(i) = z(i+1);
    maxF(i) = maxF(i+1);
end

%----RHS Backlash----
Fr(1,:) = max(v(1), min(v(1), 0));
for t = 2:N
    for i = 1:2:2*M
    Fr(t,i) = max([v(t) - z(i), min([maxF(i)/maxv*v(t), Fr(t-1,i)])]);
    end
end

Fr(1,:) = Fr(end,:);
for t = 2:N
    for i = 1:2:2*M
    Fr(t,i) = max([v(t) - z(i), min([maxF(i)/maxv*v(t), Fr(t-1,i)])]);
    end
end

%----LHS Backlash----
Fl(1,:) = max(v(1), min(v(1), 0));
for t = 2:N
    for i = 2:2:2*M
    Fl(t,i) = min([v(t) + z(i), max([maxF(i)/maxv*v(t), Fl(t-1,i)])]);
    end
end

Fl(1,:) = Fl(end,:);
for t = 2:N
    for i = 2:2:2*M
    Fl(t,i) = min([v(t) + z(i), max([maxF(i)/maxv*v(t), Fl(t-1,i)])]);
    end
end

Fas = Fl+Fr;

%----Disregard Operators Outside Input Range----
for i=1:2*M
    if z(i)>norm(v,inf)
        Fas(:,i) = 0;
    end
end

Fas(:,2*M+1)=1; %Shifting operator in the asymmetrical case.