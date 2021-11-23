clear all
close all
clc

syms x y real
mu = (sin(2*pi*(y-x))) + (sin(2*pi*(y+x)))

intx = int(2*mu,x,x,y)
inty = int(2*mu,y,x,y)

figure; fsurf(intx,[-1 1 -1 1]);
title('intx');xlabel('x');ylabel('y');
view([0 90])
figure; fsurf(inty,[-1 1 -1 1]);
title('inty');xlabel('x');ylabel('y');
view([0 90])

diffxIntx = simplify(expand(diff(intx,x)),'Steps',25)
diffyIntx = simplify(expand(diff(intx,y)),'Steps',25)

diffxInty = simplify(expand(diff(inty,x)),'Steps',25)
diffyInty = simplify(expand(diff(inty,y)),'Steps',25)

maxintynum = subs(inty,[x,y],[0,0.5])
minintynum = subs(inty,[x,y],[-1/6,0])