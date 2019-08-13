clear all
close all
clc

i=0;
X = double([]);
Y = double([]);
figure;
plot(X, Y,'b-','MarkerSize',8);
hold on; grid on;
xlim([-10 10]);
ylim([-10 10]);
while(true)
    [x, y] = ginput(1);
    if(~isempty(x) && ~isempty(y))
        X(i+1) = x;
        Y(i+1) = y;
        plot(X, Y,'b.','MarkerSize',8);
        plot(X, Y,'b-','MarkerSize',8);
        i=i+1;
    else
        break;
    end
end

if (X(1)>X(end))
    X = [X(end),X];
    Y = [Y(end),Y];
elseif (X(1)<X(end))
    X = [X,X(1)];
    Y = [Y,Y(1)];
end

[peaks, idxs] = findpeaks(X);
inputSeq = interp1(X, linspace(1,length(X),100), 'pchip');
outputSeq = interp1(Y, linspace(1,length(Y),100), 'pchip');

dataHandler = DataHandler(inputSeq(:), outputSeq(:));
createdLoopPlots = FitPlotter();
createdLoopPlots.subfigInput(1:dataHandler.sampleLength, dataHandler.inputSeq, 'Interp Input', 'r');
createdLoopPlots.subfigOutput(1:dataHandler.sampleLength, dataHandler.outputSeq, 'Interp Output', 'r');
createdLoopPlots.figLoop(X, Y, 'Captured Loop', 'b');
createdLoopPlots.figLoop(dataHandler.inputSeq, dataHandler.outputSeq, 'Interp Loop', 'r');
