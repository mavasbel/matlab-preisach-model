clc

syms x y real
syms u umax umin real

mu = sin(2*pi*(x-y)) + sin(2*pi*(x+y));

int1 = (int(mu,   y, u, umax));
int2 = (int(int1, x, umin, u));

pretty(int2)
solve(int2==0, u)

figure
ezplot(subs(int2,[umin,umax],[-1 1]),[-1,1])