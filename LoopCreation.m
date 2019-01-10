clear all
close all
clc

% Batch flag
isBatch = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ascending  : sine + line
% Descending : line
% Loops : 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% x = linspace(0, (3/2)*(2*pi), 2000);
% 
% ascIn = x;
% ascInOut = sin(x) + x;
% descIn = fliplr(x);
% descInOut = fliplr(-sin(x) + x);
% inputSeq = [ascIn descIn] - 0*pi*3/2;
% outputSeq = [ascInOut descInOut];
% outputSeq = wrev([ascInOut descInOut]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ascending  : sine
% Descending : sine phase shifted
% Loops : n
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n = 5;
x = linspace(-n*pi/2, n*pi/2, 200*n);

res = mod(n,2); if( res == 0 ) f = 0; else f = 1; end
ascIn = x;
descIn = x;
ascInOut = -sin(x - f*pi/2);
descInOut = sin(x - f*pi/2);
inputSeq = [ascIn fliplr(descIn)];
outputSeq = -[ascInOut fliplr(descInOut)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lemniscate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% T = 50;
% w = 2*pi/T;
% t = linspace(0,T,200);
% ampInput = 10;
% ampOutput = 10;
% inputSeq = ampInput*cos(w*t-pi/2)./(sin(w*t-pi/2).^2+1);
% outputSeq = -2*ampOutput*sqrt(2)*cos(w*t-pi/2).*sin(w*t-pi/2)./(sin(w*t-pi/2).^2+1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Multiple amplitude Lemniscate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inputSeq = double([]);
% outputSeq = double([]);
% 
% T = 50;
% w = 2*pi/T;
% t = linspace(0,T,100);
% loopsNumber = 60;
% ampInput = linspace(10,0,loopsNumber);
% ampOutput = linspace(10,0,loopsNumber);
% for i=1:length(ampInput)
%     inputSeq = [inputSeq, ampInput(i)*cos(w*t-pi/2)./(sin(w*t-pi/2).^2+1)];
%     outputSeq = [outputSeq, -2*ampOutput(i)*sqrt(2)*cos(w*t-pi/2).*sin(w*t-pi/2)./(sin(w*t-pi/2).^2+1)];
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lemniscate with varying amplitude
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% T = 50; w = 2*pi/T; phase = pi/2*0;
% ampIn = 2; ampOut = 10;
% 
% x1 = linspace(0,T/2,200)';
% x2 = linspace(T/2,T,200)';
% 
% ascAmpIn  = 3*(x1/4.5 - x2(end))/x2(end); 
% descAmpIn = 3*(x2/4.5 - x2(end))/x2(end);
% 
% ascAmpInOut  = 10*(x1/3.5 - x2(end))/x2(end); 
% descAmpInOut = 10*(x2/3.5 - x2(end))/x2(end);
% 
% ascIn = sqrt(2).*ascAmpIn.*cos(w*x1-phase)./( (sin(w*x1-phase).^2) + 1);
% ascInOut = sqrt(2)*ascAmpInOut.*cos(w*x1-phase).*sin(w*x1-phase)./( (sin(w*x1-phase).^2) + 1);
% descIn = sqrt(2).*descAmpIn.*cos(w*x2-phase)./( (sin(w*x2-phase).^2) + 1);
% descInOut = sqrt(2)*descAmpInOut.*cos(w*x2-phase).*sin(w*x2-phase)./( (sin(w*x2-phase).^2) + 1);
% inputSeq = [ascIn; descIn];
% outputSeq = [ascInOut; descInOut];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desplay info and plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataHandler = DataHandler(inputSeq(:), outputSeq(:));
createdLoopPlots = PreisachPlots();
createdLoopPlots.plotInputSubFig(1:dataHandler.sampleLength, dataHandler.inputSeq, 'Created Input', 'k');
createdLoopPlots.plotOutputSubFig(1:dataHandler.sampleLength, dataHandler.outputSeq, 'Created Output', 'k');
createdLoopPlots.plotLoopFig(dataHandler.inputSeq, dataHandler.outputSeq, 'Created Loop', 'k');