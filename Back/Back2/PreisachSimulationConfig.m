% clear all
% close all
clc

%Parameters from input serie
inputMax=1;
inputMin=-1;

n=80; %side lenght of square region
alphabeta = linspace(inputMin, inputMax, n);
disLength = (inputMax-inputMin)/(n-1);
disArea = disLength^2;
mu = -1*tril(fliplr(triu(ones(n,n)))) + triu(fliplr(triu(ones(n,n))));
shift = 0;
hysteronMax= 1;
hysteronMin=-1;

initialRelays = -1*fliplr(triu(ones(n,n)));
initialOutput = sum(sum(initialRelays.*mu));
% outputMinApprox = -sum(sum(abs(mu)));
% outputMaxApprox =  sum(sum(abs(mu)));
outputMinApprox = floor(min(outputSerie));
outputMaxApprox = ceil(max(outputSerie));

disp(['Max input: ', num2str(inputMax)]);
disp(['Min input: ', num2str(inputMin)]);
disp(['Initial Output: ',num2str(initialOutput)]);
disp(['Discretization divisions per side: ', num2str(n)]);
disp(['Discretization single region area: ', num2str(disArea)]);
disp(['Total relays: ', num2str(n*(n+1)/2)]);
disp(['Max rank for constant amplitude periodic signal: ',num2str(2*n)]);

fhalf=floor(n/2);
chalf=ceil(n/2);

%Second subdivision of areas (Butterfly area 0)
% mu(1:fhalf,1:fhalf)=-1*mu(1:fhalf,1:fhalf);

%boundary tilt = 0 (Butterfly)
% mu(1:fhalf,1:fhalf)=1*ones(fhalf,fhalf);
% mu(fhalf+1:size(mu,1),1:fhalf)=-3*flipud(tril(ones(chalf)));

%Double upper concentration
% mu(1:fhalf,1:fhalf)=mu(1:fhalf,1:fhalf)-tril(ones(fhalf))-eye(fhalf);
% mu(fhalf+1:size(mu,1),1:fhalf)=zeros(chalf);