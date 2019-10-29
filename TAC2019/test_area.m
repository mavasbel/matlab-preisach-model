clear all
close all
clc

umax=1;
umin=-1;

syms u
y1=-(umax+u).^2;
y2=-(umax-u).*(umax+3*u);
y3=-(umax-u).^2;
y4=-(umax+u)*(umax-3*u);

u1n = linspace(-1,0,100);
y1n = subs(y1,u,u1n);
u2n = linspace(0,1,100);
y2n = subs(y2,u,u2n);
u3n = linspace(1,0,100);
y3n = subs(y3,u,u3n);
u4n = linspace(0,-1,100);
y4n = subs(y4,u,u4n);

plot(u1n,y1n,'r', ...
    u2n,y2n,'b', ...
    u3n,y3n,'g', ...
    u4n,y4n,'y')

ccwArea = int(y3,u, 0,1)-int(y2,u, 0,1)
cwArea =  int(y4,u,-1,0)-int(y1,u,-1,0)

syms a b
ccwArea2 = ...
2*int( int(+a,a,-b, 1), b,-1,0 ) + ...
2*int( int(+a,a, b, 1), b, 0,1 ) + ...
2*int( int(-a,a, 0,-b), b,-1,0 ) - ...
2*int( int(+b,a, b, 1), b, 0,1 )