clear all
close all
clc

totalTime = 3;
totalSamples = 1000;

Vmax = 1600;
Vmin = -1600;
Period = 1;

Amp = (Vmax - Vmin)/2;
Offset = (Vmax + Vmin)/2;
Pk2Pk = Vmax - Vmin;

Pk2PkAscTime = Period/2;
AscSlope = Pk2Pk/Pk2PkAscTime;
DescSlope = Pk2Pk/Pk2PkAscTime;

times = linspace(0, totalTime, totalSamples);
waveGen = TriangleWaveGenerator;
% func = waveGen.periodic(Amp, Period, 0, Pk2PkAscTime, times);
% func = waveGen.periodicWithSlopes(Amp, AscSlope, DescSlope, times);
% func = waveGen.fading(Amp, Period, Pk2PkAscTime, 0.1, times);
func = waveGen.fadingWithSlopes(Amp, AscSlope, DescSlope, 0.1, times);
% func = waveGen.periodic(Amp, Period, -3*Period/4, Pk2PkAscTime, times);
% func = 0.898*Amp*triangularPulse(1, 1+Pk2PkAscTime, 1+Period, times);

plot(times, func)
xlabel('Time (s)')
ylabel('Voltage (V)')