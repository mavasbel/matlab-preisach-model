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
interpLength = trimmedSampleLength/4;
interpIdx = linspace(1, length(trimmedInputSeq), interpLength)';
inputSeq = interp1(trimmedInputSeq, interpIdx, 'spline');
outputSeq = interp1(trimmedOutputSeq, interpIdx, 'spline');

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

% Other simulation vars
initialInput = inputSeq(1);
outputMinApprox = floor(min(outputSeq));
outputMaxApprox = ceil(max(outputSeq));
simTotalTime = 200;

% Limits
xLims = [inputMin, inputMax];
yLims = [inputMin, inputMax];
[xMesh, yMesh] = meshgrid(xyGrid, xyGrid);
maxPow = 12;

L = [];
areas = [];
intLFig = figure;

termsSeq = zeros(maxPow+1, maxPow+1, length(inputSeq));
for i=1:length(inputSeq)
    LTic = tic;
    L = updateL(L, inputSeq(i), xLims, yLims);
    Ltoc = toc(LTic);
    
    polyTic = tic;
    matrix = getMatrixTerms(L, xLims, yLims, maxPow);
    termsSeq(:,:,i) = matrix;
    polyToc = toc(polyTic);
    
    ppTic = tic;
    plotL(intLFig, L, xLims, yLims);
    ppToc = toc(ppTic);
end
P = buildTermsMatrix(termsSeq);

% Computing weights
fittingTic = tic;
gamma = 0.0;
weightVector = ( P'*P + gamma*eye(size(P,2)) ) \ P'*outputSeq;
% weightVector = P'*( (P*P' + gamma*eye(size(P,1)) ) \ outputSeq );
fittingTime = toc(fittingTic);

% Generating fitted output
fittedOutputTic = tic;
weightMatrix = buildWeightMatrix(weightVector, maxPow+1, maxPow+1);
fittedOutput = zeros(length(inputSeq),1);
for i=1:length(inputSeq)
    fittedOutput(i) = sum(sum(weightMatrix.*termsSeq(:,:,i)));
end
fittedOutputTime = toc(fittedOutputTic);

figure; grid on; hold on;
plot(inputSeq, outputSeq);
plot(inputSeq, fittedOutput);

[xMesh, yMesh] = meshgrid(xyGrid, xyGrid);
weightFunc = zeros(size(xMesh,1),size(yMesh,2));
for i=1:size(xMesh,1)
    for j=1:size(yMesh,2)
        if(xMesh(i,j)<=yMesh(i,j))
            weightFunc(i,j) = computeWeightFunc(...
                xMesh(i,j), yMesh(i,j), weightMatrix, maxPow);
        end
    end
end
% weightFunc = flipud(weightFunc);

for i=1:length(inputSeq)
    fittedOutput(i) = sum(sum(weightMatrix.*termsSeq(:,:,i)));
end

figure; grid on; hold on;
surf(xMesh, yMesh, weightFunc, 'edgecolor','none')
colorbar
colormap jet
shading interp
view([0 90])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotL(fig, L, xLims, yLims)
    figure(fig);

    clf
    plot(L(:,1),L(:,2),'b-x');
    hold on; grid on; axis square;
    plot([xLims(1),xLims(2)],[yLims(1),yLims(2)],'r-');
    
    xlim(xLims);
    ylim(yLims);
    drawnow
end

function L = updateL(L, input, xLims, yLims)
    if(size(L,1)<1 || size(L,2)~=2)
        L = [xLims(1), yLims(2); 
            xLims(1), input; 
            input,input];
    end
    
    i = 2;
    while(i<size(L,1))
        if( (L(i-1,1)==L(i,1) && L(i,1)==L(i+1,1))...
            || (L(i-1,2)==L(i,2) && L(i,2)==L(i+1,2)) )
            L(i,:) = [];
        else
            i = i+1;
        end
    end
    
    for i=1:size(L,1)
        if((L(i,1)<=input && L(i,2)>input) || (L(i,1)<input && L(i,2)>=input))
            continue;
        elseif (L(i,1)>input && L(i,2)>input)
            L = [L(1:i-1,:); input, L(i,2); input,input];
            break;
        elseif (L(i,1)<input && L(i,2)<input)
            L = [L(1:i-1,:); L(i,1), input; input,input];
            break;
        else
            L = [L(1:i-1,:); input,input];
            break;
        end
    end
end

function termsMatrix = buildTermsMatrix(termsSeq)
    rows = size(termsSeq,1);
    colums = size(termsSeq,2);
    
    totalTerms = rows*colums;
    samplesLength = size(termsSeq, 3);
    
    element = 1;
    termsMatrix = zeros(samplesLength, totalTerms);
    for i=1:rows
        for j=1:colums
            termsMatrix(:,element) = termsSeq(i,j,:);
            element = element + 1;
        end
    end
end

function weightMatrix = buildWeightMatrix(termsMatrix, rows, columns)
    element = 1;
    weightMatrix = zeros(rows, columns);
    for i=1:rows
        for j=1:columns
            weightMatrix(i,j) = termsMatrix(element);
            element = element + 1;
        end
    end
end

function val = computeWeightFunc(x, y, weightMatrix, maxPow)
    val = sum(sum(weightMatrix.*...
        (powersVector(x, maxPow)*powersVector(y, maxPow)')));
end

function matrix = getMatrixTerms(L, xLims, yLims, maxPow)
    matrix = zeros(maxPow+1, maxPow+1);
    
    if(size(L,1)<2)
        return;
    end
    
    for i=1:size(L,1)-1
        if(L(i,2)==L(i+1,2))
            integralVal = integralSquareReg([L(i,1), L(i+1,1)], [L(i,2), yLims(2)], maxPow);
            matrix = matrix + integralVal;
        elseif(L(i,1)==L(i+1,1))
            integralVal = integralSquareReg([xLims(1), L(i,1)], [L(i+1,2), L(i,2)], maxPow);
            matrix = matrix - integralVal;
        end 
    end
    integralVal = integralTriReg([xLims(1), L(end,1)], [yLims(1), L(end,2)], maxPow);
    matrix = matrix + integralVal;
    
    integralVal = integralTriReg([L(end,1), xLims(2)], [L(end,2), yLims(2)], maxPow);
    matrix = matrix - integralVal;
end

function matrix = integralSquareReg(xLims, yLims, maxPow)
    matrix = (intPowersVector(xLims(2), maxPow) - intPowersVector(xLims(1), maxPow))...
        *(intPowersVector(yLims(2), maxPow) - intPowersVector(yLims(1), maxPow))';
end

function matrix = integralTriReg(xLims, yLims, maxPow)
    matrix = intPowersMatrix(yLims(2), maxPow) - intPowersMatrix(yLims(1), maxPow)...
        - intPowersVector(xLims(1), maxPow)...
        *(intPowersVector(yLims(2), maxPow) - intPowersVector(yLims(1), maxPow))';
end

function vector = powersVector(value, maxPow)
    vector = zeros(maxPow+1, 1);
    for i=0:maxPow
        vector(i+1) = value^i;
    end
end

function vector = intPowersVector(value, maxPow)
    vector = zeros(maxPow+1, 1);
    for i=0:maxPow
        vector(i+1) = (1/(i+1))*value^(i+1);
    end
end

function matrix = intPowersMatrix(value, maxPow)
    matrix = zeros(maxPow+1, maxPow+1);
    for i=0:maxPow
        for j=0:maxPow
            matrix(i+1,j+1) = 1/((i+j+2)*(i+1))*value^(i+j+2);
        end
    end
end