close all;
if (isBatch ~= true) clc; end

% Conversion to column vector
origInputSeq = origInputSeq(:);
origOutputSeq = origOutputSeq(:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parametrization for fitting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Original sample length
origSampleLength = length(origInputSeq);

% Trimming samples
startTrim = 1;
endTrimIdx = origSampleLength;
[~,maxInputPeakIdx] = findpeaks(origInputSeq);
[~,minInputPeakIdx] = findpeaks(-origInputSeq);
[~,maxOutputPeakIdx] = findpeaks(origOutputSeq);
[~,minOutputPeakIdx] = findpeaks(-origOutputSeq);
zeroCrossInputIndexes = cell2mat(cellfun(@(v){find(v(:).*circshift(v(:), [-1 0]) <= 0)},{origInputSeq}));
zeroCrossOutputIndexes = cell2mat(cellfun(@(v){find(v(:).*circshift(v(:), [-1 0]) <= 0)},{origOutputSeq}));
if(length(maxInputPeakIdx)==3)
    startTrim = maxInputPeakIdx(1); 
%     endTrimIdx = maxInputPeakIdx(3);
%     startTrim = minInputPeakIdx(1); 
    endTrimIdx = minInputPeakIdx(3);
end
% startTrimIndex = cellfun(@(v)v(1),{find(interpInputSeq >= 650)});
trimmedInputSeq = origInputSeq(startTrim:endTrimIdx);
trimmedOutputSeq = origOutputSeq(startTrim:endTrimIdx);
trimmedSampleLength = length(trimmedInputSeq);

% Interpolation parameters
interpLength = trimmedSampleLength*2;
interpIdx = linspace(1, length(trimmedInputSeq), interpLength)';
inputSeq = interp1(trimmedInputSeq, interpIdx, 'cubic');
outputSeq = interp1(trimmedOutputSeq, interpIdx, 'cubic');
% interpIdx = 1:length(trimmedInputSeq);
% inputSeq = trimmedInputSeq;
% outputSeq = trimmedOutputSeq;

% Parameters from input Seq
inputMin = min(inputSeq);
inputMax = max(inputSeq);

% Parameters from output Seq
outputMin = min(outputSeq);
outputMax = max(outputSeq);

% Discretization
gridDen = 100;
inputMinFactor = 1.00;
inputMaxFactor = 1.00;
xyGrid = linspace(inputMinFactor*inputMin, inputMaxFactor*inputMax, gridDen);
gridLength = (inputMaxFactor*inputMax - inputMinFactor*inputMin)/(gridDen-1);
gridArea = gridLength^2;

% Hysteron
hysteronMax =  1;
hysteronMin = -1;

% Initial relays generation
initialRelays = hysteronMin*fliplr(triu(ones(gridDen,gridDen)));
% initialRelays = hysteronMax*fliplr(triu(ones(n,n)));
% initialRelays = flipud(tril(ones(n,n))).*(-triu(ones(n,n)) + tril(ones(n,n)) + diag(ones(n,1)));

% Initial conditions adjusment (square window)
% upperIndex = n;
% lowerIndex = cellfun(@(v)v(1),{find(xyGrid >= 0)});
% leftIndex = 1;
% rightIndex = cellfun(@(v)v(1),{find(xyGrid >= 0)});
% initialRelays = setRelaysWindowValue(initialRelays, hysteronMax, lowerIndex, upperIndex, leftIndex, rightIndex, n);

% Other simulation vars
initialInput = inputSeq(1);
outputMinApprox = floor(min(outputSeq));
outputMaxApprox = ceil(max(outputSeq));
simTotalTime = 200;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input, Output, Fitting parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(['--Fitting parameters--']);
disp(['Original data length: ', num2str(origSampleLength)]);
disp(['Adjusted data length: ', num2str(size(inputSeq,1))]);
disp(['Min input: ', num2str(inputMin)]);
disp(['Max input: ', num2str(inputMax)]);
disp(['Min output: ', num2str(outputMin)]);
disp(['Max output: ', num2str(outputMax)]);
disp(['Plane discretization: ', num2str(gridDen)]);
disp(['Total relays: ', num2str(gridDen*(gridDen+1)/2)]);
disp(['Plane discretization area: ', num2str(gridArea)]);

% Plot input and output
inputOutputFig = figure;
currentPos = get(inputOutputFig, 'Position');
set(inputOutputFig, 'Position', currentPos.*[1 1 2 1] + [-currentPos(3)/2 0 0 0] );

inputSubFig = subplot(1,2,1); hold on; grid on;
plot(1:origSampleLength, origInputSeq, 'r');
plot(startTrim + interpIdx, inputSeq, 'b');
currentPos = get(inputSubFig, 'Position');
set(inputSubFig, 'Position', currentPos.*[0.9 1 1 1] + [0 0 0 0] );
legend('Original Input', 'Adjusted Input');

outputSubFig = subplot(1,2,2); hold on; grid on;
plot(1:origSampleLength, origOutputSeq, 'r');
plot(startTrim + interpIdx, outputSeq, 'b');
currentPos = get(outputSubFig, 'Position');
set(outputSubFig, 'Position', currentPos.*[1.0 1 1 1] + [0 0 0 0] );
legend('Original Output', 'Adjusted Output');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fitting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generating filtered sequences
filterTic = tic;
[filteredInputSeq, filteredOutputSeq, filteredRelaysSeq] = generateFilteredSeqs...
    (inputSeq, outputSeq, initialRelays, xyGrid, hysteronMin, hysteronMax, gridDen);
P = [buildRelaysMatrix(filteredRelaysSeq, gridDen)*gridArea, ones(size(filteredRelaysSeq,3),1)];
filterTime = toc(filterTic);

% Computing weights
fittingTic = tic;
gamma = 0.0;
% weightVector = ( P'*P + gamma*eye(size(P,2)) ) \ P'*filteredOutputSeq;
weightVector = P'*( (P*P' + gamma*eye(size(P,1)) ) \ filteredOutputSeq );
% weightVector = svdApproxInverse(P, filteredOutputSeq, gridDen);
fittingTime = toc(fittingTic);

% Building weight plane
weightPlaneTic = tic;
shift = weightVector(end);
weightFunc = buildWeightPlane(weightVector, gridDen);
weightFuncTime = toc(weightPlaneTic);

% Generating fitted output
fittedOutputTic = tic;
relaysSeq = generateRelaysSeq(trimmedInputSeq, initialRelays, xyGrid, hysteronMin, hysteronMax, gridDen);
fittedOutput = generateOutputSeq(relaysSeq, weightFunc, gridArea, shift);
fittedOutputTime = toc(fittedOutputTic);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Error calculation
errorVector = abs( fittedOutput(:) - trimmedOutputSeq(:) );
relativeErrorVector = errorVector./abs(outputMax - outputMin);
disp(['--Results--']);
disp(['Filtering time: ', num2str(mean(filterTime)), ' seconds']);
disp(['Fitting time: ', num2str(mean(fittingTime)), ' seconds']);
disp(['Weightplane time: ', num2str(mean(weightFuncTime)), ' seconds']);
disp(['Output time: ', num2str(mean(fittedOutputTime)), ' seconds']);
disp(['Min absolute error: ', num2str(min(errorVector))]);
disp(['Max absolute error: ', num2str(max(errorVector))]);
disp(['Mean absolute error: ', num2str(mean(errorVector))]);
disp(['Min relative error: ', num2str(min(relativeErrorVector))]);
disp(['Max relative error: ', num2str(max(relativeErrorVector))]);
disp(['Mean relative error: ', num2str(mean(relativeErrorVector))]);

% Add fitted curve and weight plane
outputSubFig;
plot(startTrim:endTrimIdx, fittedOutput, 'k');
legend('Original Output', 'Adjusted Output', 'Fitted Output');

% Plot fitted curve and weight plane
loopPlaneFig = figure;
currentPos = get(loopPlaneFig, 'Position');
set(loopPlaneFig, 'Position', currentPos.*[1 1 2 1] + [-currentPos(3)/2 0 0 0] );

loopSubFig = subplot(1,2,1); hold on; grid on;
plot(origInputSeq, origOutputSeq, 'r');
plot(trimmedInputSeq, fittedOutput, 'b');
currentPos = get(loopSubFig, 'Position');
set(loopSubFig, 'Position', currentPos.*[0.85 1 1 1] + [0 0 0 0] );
legend('Real data', 'Fitted result');
axis square;

planeSubFig = subplot(1,2,2); hold on; grid on;
plotSurface(planeSubFig, weightFunc, xyGrid, gridDen);
currentPos = get(planeSubFig, 'Position');
set(planeSubFig, 'Position', currentPos.*[0.95 1 1 1] + [0 0 0 0] );
axis square;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function relays = setRelaysWindowValue(relays, relayValue, lowerIndex, upperIndex, leftIndex, rightIndex, gridDen)
    for i=1:gridDen
        ii = gridDen-i+1; %index inversion for rows
        for j=1:i
            if( ( (i>=lowerIndex && i<=upperIndex) && ...
                ( (j>=leftIndex && j<=rightIndex)  ) ) )
                relays(ii,j) = relayValue;
            end
        end
    end
end

function weightVector = svdApproxInverse(P, filteredOutputSeq, gridDen)
    [U,S,V] = svd(P'*P);
    weightVector = 0;
    for i = 1:(gridDen^2+gridDen)/2
        if S(i,i) > 10e-1
            weightVector = weightVector + U(:,i)'*(P'*filteredOutputSeq)./S(i,i)*V(:,i);
        end
    end
end

function hash = generateHash(matrix)
    bytes = getByteStreamFromArray(matrix);
    md = java.security.MessageDigest.getInstance('SHA-1');
    md.update(bytes);
    hash = char(reshape(dec2hex(typecast(md.digest(),'uint8'))',1,[]));
end

function [relays, switched] = nextRelays(input, initialRelays, xyGrid, hysteronMin, hysteronMax, n)
    relays = initialRelays;
    for i=1:n
        ii = n-i+1; %index inversion for rows
        for j=1:i
            if( input >= xyGrid(i) && relays(ii,j) ~= hysteronMax )
                relays(ii,j) = hysteronMax;
            elseif( input <= xyGrid(j) && relays(ii,j) ~= hysteronMin )
                relays(ii,j) = hysteronMin;
            end
        end
    end
end

function relaysSeq = generateRelaysSeq(inputSeq, initialRelays, xyGrid, hysteronMin, hysteronMax, gridDen)
    relays = initialRelays;
    sampleLength = length(inputSeq);
    relaysSeq = zeros(gridDen,gridDen,sampleLength);
    for i=1:sampleLength
        relays = nextRelays(inputSeq(i), relays, xyGrid, hysteronMin, hysteronMax, gridDen);
        relaysSeq(:,:,i) = relays;
    end
end

function outputSeq = generateOutputSeq(relaysSeq, weightFunc, gridArea, offset)
    sampleLength = size(relaysSeq, 3);
    outputSeq = zeros(sampleLength,1);
    for i=1:sampleLength
        outputSeq(i) = sum(sum(relaysSeq(:,:,i).*weightFunc))*gridArea + offset;
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

function [filteredInputSeq, filteredOutputSeq, filteredRelaysSeq] = generateFilteredSeqs(inputSeq, outputSeq, initialRelays, xyGrid, hysteronMin, hysteronMax, gridDen)
    relays = initialRelays;
    sampleLength = length(inputSeq);
    
    filteredOutputSeq = zeros(sampleLength,1);
    filteredOutputCounters = ones(sampleLength,1);
    filteredInputSeq = zeros(sampleLength,1);
    filteredInputCounters = ones(sampleLength,1);
    filteredRelaysSeq = zeros(gridDen,gridDen,sampleLength);
    matrixHashes = string(zeros(sampleLength,1));
    hashCounter = 1;
    for i=1:sampleLength
        relays = nextRelays(inputSeq(i), relays, xyGrid, hysteronMin, hysteronMax, gridDen);
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

function relaysMatrix = buildRelaysMatrix(relaysSeq, gridDen)
    totalRelays = gridDen*(gridDen+1)/2;
    samplesLength = size(relaysSeq, 3);
    
    relaysMatrix = zeros(samplesLength, totalRelays);

    relay = 1;
    for i=1:gridDen
        ii = gridDen-i+1; %index inversion for rows
        for j=1:i
            relaysMatrix(:,relay) = relaysSeq(ii,j,:);
            relay = relay + 1;
        end
    end
end

function weightFunc = buildWeightPlane(weightVector, gridDen)
    weightFunc = zeros(gridDen, gridDen);
    vindex = 1;
    for i=1:gridDen
        ii = gridDen-i+1; %index inversion for rows
        for j=1:i
            weightFunc(ii,j) = weightVector(vindex);
            vindex = vindex + 1;
        end
    end
end

function fig = plotSurface(fig, weightFunc, xyGrid, gridDen)  
    stdDevColorFactor = 2.5;    
    avgColorFactor = 3.5;
    
    posMu = max(weightFunc,0);
    posNnz = nnz(posMu);
    posAvg = sum(sum(posMu))/posNnz;
    posOnes = spones(posMu);
    posStdDev = sqrt(sum(sum( (posMu - posAvg.*posOnes).^2 ))/posNnz);  
    negMu = min(weightFunc,0);
    negNnz = nnz(negMu);
    negAvg = sum(sum(negMu))/negNnz;
    negOnes = spones(negMu);
    negStdDev = sqrt(sum(sum( (negMu - negAvg.*negOnes).^2 ))/negNnz);
    
    maxStdDev = nanmax([posStdDev, negStdDev]);
    maxAvg = nanmax([abs(posAvg), abs(negAvg)]);
    
    [xMesh, yMesh] = meshgrid(xyGrid, fliplr(xyGrid));
    surf(xMesh, yMesh, weightFunc, 'edgecolor','none')
    
    caxis([-stdDevColorFactor*maxStdDev, stdDevColorFactor*maxStdDev]);
%     zlim([-stdDevColorFactor*maxStdDev, stdDevColorFactor*maxStdDev]);
%     caxis([-avgColorFactor*maxAvg, avgColorFactor*maxAvg]);
%     zlim([-avgColorFactor*maxAvg, avgColorFactor*maxAvg]);
    
    colorbar
    colormap jet
    shading interp
    view([0 90])
end
