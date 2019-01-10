close all;
if (isBatch ~= true) clc; end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parametrization for fitting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inputSeq = origInputSeq;
outputSeq = origOutputSeq;

% Trimming first samples
sampleLength = length(origInputSeq);
[~,startTrimIndex] = findpeaks(origInputSeq);

startTrimIndex = 1;
endTrimIndex = sampleLength;
% startTrimIndex = cellfun(@(v)v(1),{find(inputSeq >= 100)});
% endTrimIndex = cellfun(@(v)sampleLength-v(1),{find(wrev(inputSeq) <= -1100)});
inputSeq = inputSeq(startTrimIndex:endTrimIndex);
outputSeq = outputSeq(startTrimIndex:endTrimIndex);

% Parameters from input Seq
inputMin = min(inputSeq);
inputMax = max(inputSeq);

% Parameters from output Seq
outputMin = min(outputSeq);
outputMax = max(outputSeq);

% Discretization
n = 60;
inputMinFactor = 1.00;
inputMaxFactor = 1.00;
alphabeta = linspace(inputMinFactor*inputMin, inputMaxFactor*inputMax, n);
disLength = (inputMaxFactor*inputMax - inputMinFactor*inputMin)/(n-1);
disArea = disLength^2;

% Hysteron
hysteronMax =  1;
hysteronMin = -1;

% Initial relays generation
% initialRelays = hysteronMax*fliplr(triu(ones(n,n)));
initialRelays = hysteronMin*fliplr(triu(ones(n,n)));
% initialRelays = flipud(tril(ones(n,n))).*(-triu(ones(n,n)) + tril(ones(n,n)) + diag(ones(n,1)));

% % Initial conditions adjusment (square window)
% upperIndex = cellfun(@(v)v(1),{find(alphabeta >= 220)});
% lowerIndex = cellfun(@(v)v(end),{find(alphabeta <= 0)});
% leftIndex = cellfun(@(v)v(1),{find(alphabeta >= -1500)});
% rightIndex = cellfun(@(v)v(end),{find(alphabeta <= -1000)});
% for i=1:n
%     ii = n-i+1; %index inversion for rows
%     for j=1:i
%         if( ( (i>=lowerIndex && i<=upperIndex) && ...
%             ( (j>=leftIndex && j<=rightIndex)  ) ) || ...
%              false )
%             initialRelays(ii,j) = hysteronMax;
%         end
%     end
% end

% Initial conditions adjusment (Edges)
initialInput = inputSeq(1);
% i=1; finished = false;
% while(~finished)
%     finished = true;
%     ii = n-i+1; %index inversion
%     if (alphabeta(i) < inputMin)
%         initialRelays(:,i) = hysteronMax;
%         finished = false;
%     end
%     if (alphabeta(ii) > inputMax)
%         initialRelays(i,:) = hysteronMax;
%         finished = false;
%     end
%     i = i+1;
% end
% while(~finished)
%     if (alphabeta(i) > initialInput)
%         ii = n-i+1; %index inversion
%         initialRelays(1:ii, 1:i) = hysteronMax*ones(ii, i);
%         finished = true;
%     end
%     i = i+1;
% end
% cornerSize = floor(length(alphabeta)*0.30);
% initialRelays(1:cornerSize, 1:cornerSize) = hysteronMax*ones(cornerSize, cornerSize);

% Other simulation vars
outputMinApprox = floor(min(outputSeq));
outputMaxApprox = ceil(max(outputSeq));
simTotalTime = 200;
% [butterNum, butterDen] = butter(2,100000,'s');
% figure;
% bodemag(tf(butterNum,butterDen));
% hold on;
% grid on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input, Output, Fitting parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(['--Fitting parameters--']);
disp(['Data set size: ', num2str(size(inputSeq,1))]);
disp(['Min input: ', num2str(inputMin)]);
disp(['Max input: ', num2str(inputMax)]);
disp(['Min output: ', num2str(outputMin)]);
disp(['Max output: ', num2str(outputMax)]);
disp(['Plane discretization: ', num2str(n)]);
disp(['Total relays: ', num2str(n*(n+1)/2)]);
disp(['Plane discretization area: ', num2str(disArea)]);

% Plot both input output
subFigIO = figure;
currentPos = get(subFigIO, 'Position');
set(subFigIO, 'Position', currentPos.*[1 1 2 1] + [-currentPos(3)/2 0 0 0] );

inputSubFig = subplot(1,2,1); hold on; grid on;
plot(1:sampleLength, origInputSeq, 'r');
plot(startTrimIndex:endTrimIndex, inputSeq, 'b');
currentPos = get(inputSubFig, 'Position');
set(inputSubFig, 'Position', currentPos.*[0.85 1 1 1] + [0 0 0 0] );
legend('Complete Input', 'Trimmed Input');

outputSubFig = subplot(1,2,2); hold on; grid on;
plot(1:sampleLength, origOutputSeq, 'r');
plot(startTrimIndex:endTrimIndex, outputSeq, 'b');
currentPos = get(outputSubFig, 'Position');
set(outputSubFig, 'Position', currentPos.*[0.95 1 1 1] + [0 0 0 0] );
legend('Complete Output', 'Trimmed Output');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fitting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generating filtered sequences
filterTic = tic;
[filteredInputSeq, filteredOutputSeq, filteredRelaysSeq] = generateFilteredSeqs...
    (inputSeq, outputSeq, initialRelays, alphabeta, hysteronMin, hysteronMax, n);
P = [buildRelaysMatrix(filteredRelaysSeq, n)*disArea ones(size(filteredRelaysSeq,3),1)];
filterTime = toc(filterTic);

% Computing weights
fittingTic = tic;
gamma = 0.0;
% weightVector = ( P'*P + gamma*eye(size(P,2)) ) \ P'*filteredOutputSeq;
weightVector = P'*( (P*P' + gamma*eye(size(P,1)) ) \ filteredOutputSeq );
% Old method
% [U,S,V] = svd(P'*P);
% weightVector = 0;
% for i = 1:(n^2+n)/2
%     if S(i,i) > 10e-1
%         weightVector = weightVector + U(:,i)'*(P'*filteredOutputSeq)./S(i,i)*V(:,i);
%     end
% end
fittingTime = toc(fittingTic);

% Building weightsplane
weightPlaneTic = tic;
shift = weightVector(end);
weightPlane = buildWeightPlane(weightVector, n);
weightPlaneTime = toc(weightPlaneTic);

% Generating fitted output
fittedOutputTic = tic;
relaysSeq = generateRelaysSeq(inputSeq, initialRelays, alphabeta, hysteronMin, hysteronMax, n);
fittedOutput = generateOutputSeq(relaysSeq, weightPlane, disArea, shift);
fittedOutputTime = toc(fittedOutputTic);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Error calculation
errorVector = abs( fittedOutput(:) - outputSeq(:) );
relativeErrorVector = errorVector./abs(outputMax - outputMin);
disp(['--Results--']);
disp(['Filtering time: ', num2str(mean(filterTime)), ' seconds']);
disp(['Fitting time: ', num2str(mean(fittingTime)), ' seconds']);
disp(['Weightplane time: ', num2str(mean(weightPlaneTime)), ' seconds']);
disp(['Output time: ', num2str(mean(fittedOutputTime)), ' seconds']);
disp(['Min absolute error: ', num2str(min(errorVector))]);
disp(['Max absolute error: ', num2str(max(errorVector))]);
disp(['Mean absolute error: ', num2str(mean(errorVector))]);
disp(['Min relative error: ', num2str(min(relativeErrorVector))]);
disp(['Max relative error: ', num2str(max(relativeErrorVector))]);
disp(['Mean relative error: ', num2str(mean(relativeErrorVector))]);

% Plot both same figure
subFig = figure;
currentPos = get(subFig, 'Position');
set(subFig, 'Position', currentPos.*[1 1 2 1] + [-currentPos(3)/2 0 0 0] );

loopSubFig = subplot(1,2,1); hold on; grid on;
plot(origInputSeq, origOutputSeq, 'r');
plot(inputSeq, fittedOutput, 'b');
currentPos = get(loopSubFig, 'Position');
set(loopSubFig, 'Position', currentPos.*[0.85 1 1 1] + [0 0 0 0] );
legend('Real data', 'Fitted result');
axis square;

planeSubFig = subplot(1,2,2); hold on; grid on;
plotSurface(subFig, weightPlane, alphabeta, n);
currentPos = get(planeSubFig, 'Position');
set(planeSubFig, 'Position', currentPos.*[0.95 1 1 1] + [0 0 0 0] );
axis square;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hash = generateHash(matrix)
    bytes = getByteStreamFromArray(matrix);
    md = java.security.MessageDigest.getInstance('SHA-1');
    md.update(bytes);
    hash = char(reshape(dec2hex(typecast(md.digest(),'uint8'))',1,[]));
end

function [relays, switched] = nextRelays(input, initialRelays, alphabeta, hysteronMin, hysteronMax, n)
    relays = initialRelays;
    switched = false;
    for i=1:n
        ii = n-i+1; %index inversion for rows
        for j=1:i
            if( input <= alphabeta(j) && relays(ii,j) ~= hysteronMin ) 
                switched = true;
                relays(ii,j) = hysteronMin; 
            elseif( input >= alphabeta(i) && relays(ii,j) ~= hysteronMax) 
                switched = true;
                relays(ii,j) = hysteronMax;
            end
        end
    end
end

function relaysSeq = generateRelaysSeq(inputSeq, initialRelays, alphabeta, hysteronMin, hysteronMax, n)
    relays = initialRelays;
    sampleLength = length(inputSeq);
    relaysSeq = zeros(n,n,sampleLength);
    for i=1:sampleLength
        [relays, ~] = nextRelays(inputSeq(i), relays, alphabeta, hysteronMin, hysteronMax, n);
        relaysSeq(:,:,i) = relays;
    end
end

function outputSeq = generateOutputSeq(relaysSeq, weightPlane, disArea, offset)
    sampleLength = length(relaysSeq);
    outputSeq = zeros(sampleLength,1);
    for i=1:sampleLength
        outputSeq(i) = sum(sum(relaysSeq(:,:,i).*weightPlane))*disArea + offset;
    end
end

function [repeated, repeatedIndex, hash] = isRepeated(relays, matrixHashes, hashCounter)
    repeatedIndex = 0;
    repeated = false;
    hash = generateHash(relays);
    for i=[hashCounter, 1:hashCounter-1]
        if( strcmp(hash,matrixHashes(i)) )
            repeatedIndex = i;
            repeated = true;
            break;
        end
    end
end

function [filteredInputSeq, filteredOutputSeq, filteredRelaysSeq] = generateFilteredSeqs(inputSeq, outputSeq, initialRelays, alphabeta, hysteronMin, hysteronMax, n)
    relays = initialRelays;
    sampleLength = length(inputSeq);
    
    filteredOutputSeq = zeros(sampleLength,1);
    filteredOutputCounters = ones(sampleLength,1);
    filteredInputSeq = zeros(sampleLength,1);
    filteredInputCounters = ones(sampleLength,1);
    filteredRelaysSeq = zeros(n,n,sampleLength);
    matrixHashes = string(zeros(sampleLength,1));
    hashCounter = 1;
    for i=1:sampleLength
        relays = nextRelays(inputSeq(i), relays, alphabeta, hysteronMin, hysteronMax, n);
        [repeated, repeatedIndex, hash] = isRepeated(relays, matrixHashes, hashCounter);
        if( repeated == true )
            filteredOutputSeq(repeatedIndex) = filteredOutputSeq(repeatedIndex) + outputSeq(i);
            filteredOutputCounters(repeatedIndex) = filteredOutputCounters(repeatedIndex) + 1;
            filteredInputSeq(repeatedIndex) = filteredInputSeq(repeatedIndex) + inputSeq(i);
            filteredInputCounters(repeatedIndex) = filteredInputCounters(repeatedIndex) + 1;
        else
            matrixHashes(hashCounter) = hash;
            filteredOutputSeq(hashCounter) = outputSeq(i);
            filteredInputSeq(hashCounter) = inputSeq(i);
            filteredRelaysSeq(:,:,hashCounter) = relays;
            hashCounter = hashCounter + 1;
        end
    end
    filteredRelaysSeq = filteredRelaysSeq(:,:,1:hashCounter-1);
    filteredInputCounters = filteredInputCounters(1:hashCounter-1);
    filteredOutputCounters = filteredOutputCounters(1:hashCounter-1);
    filteredInputSeq = filteredInputSeq(1:hashCounter-1)./filteredInputCounters;
    filteredOutputSeq = filteredOutputSeq(1:hashCounter-1)./filteredOutputCounters;
end

function relaysMatrix = buildRelaysMatrix(relaysSeq, n)
    totalRelays = n*(n+1)/2;
    samplesLength = size(relaysSeq, 3);
    
    relaysMatrix = zeros(samplesLength, totalRelays);

    relay = 1;
    for i=1:n
        ii = n-i+1; %index inversion for rows
        for j=1:i
            relaysMatrix(:,relay) = relaysSeq(ii,j,:);
            relay = relay + 1;
        end
    end
end

function weightPlane = buildWeightPlane(weightVector, n)
    weightPlane = zeros(n, n);
    vindex = 1;
    for i=1:n
        ii = n-i+1; %index inversion for rows
        for j=1:i
            weightPlane(ii,j) = weightVector(vindex);
            vindex = vindex + 1;
        end
    end
end

function fig = plotSurface(fig, mu, alphabeta, n)  
    stdDevColorFactor = 2.0;    
    avgColorFactor = 3.5;

    posMu = max(mu,0);
    posNnz = nnz(posMu);
    posAvg = sum(sum(posMu))/posNnz;
    posStdDev = sqrt(sum(sum( (posMu - posAvg).^2 ))/posNnz);  
    negMu = min(mu,0);
    negNnz = nnz(negMu);
    negAvg = sum(sum(negMu))/negNnz;
    negStdDev = sqrt(sum(sum( (negMu - negAvg).^2 ))/negNnz);
    
    maxStdDev = nanmax([posStdDev, negStdDev]);
    maxAvg = nanmax([abs(posAvg), abs(negAvg)]);
    
    [beta, alpha] = meshgrid(alphabeta, fliplr(alphabeta));
    surf(beta, alpha, mu, 'edgecolor','none')
    
    caxis([-stdDevColorFactor*maxStdDev, stdDevColorFactor*maxStdDev]);
%     zlim([-avgColorFactor*maxStdDev, avgColorFactor*maxStdDev]);
%     caxis([-avgColorFactor*maxAvg, avgColorFactor*maxAvg]);
%     zlim([-avgColorFactor*maxAvg, avgColorFactor*maxAvg]);
    
    colorbar
    colormap jet
    shading interp
    view([0 90])
end
