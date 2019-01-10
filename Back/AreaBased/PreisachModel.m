% close all;
% clc;

% t = linspace(0,250,250);
% input = (100 - t/2.5).*cos(2*pi*t/50);
% xLims = [-100, 100];
% yLims = [-100, 100];
% xyGrid = linspace(xLims, 200);
% [xMesh, yMesh] = meshgrid(xyGrid, xyGrid);
% weightFunc = maskSimpleMu(xMesh, yMesh);
% maksSimpleMuFig = figure;
% surf(xMesh, yMesh, weightFunc,'edgecolor','none')
% colorbar
% colormap jet
% shading interp
% view([0 90])

tEnd = 200;
t = linspace(0,tEnd,300);
% inputAmp = (inputMax - inputMin)/2;
% inputOffset = mean([inputMin, inputMax]);
% inputSeq = (inputAmp - 0*(t*inputAmp/tEnd)/2).*cos((2*pi*t/tEnd)*4) + inputOffset;
xLims = [inputMin, inputMax];
yLims = [inputMin, inputMax];
[xMesh, yMesh] = meshgrid(xyGrid, xyGrid);

L = [];
areas = [];
intLFig = figure;
% weightFunc2 = flipud(weightFunc);
weightFunc2 = weightFunc;
for i=1:length(inputSeq)
    LTic = tic;
    L = updateL(L, inputSeq(i), xLims, yLims);
    Ltoc = toc(LTic);
    
    outputTic = tic;
    [output(i), areas] = computeOutput(L, areas, weightFunc2, xMesh, yMesh, xLims, yLims);
    outputToc = toc(outputTic);
    
    ppTic = tic;
    plotL(intLFig, L, xLims, yLims);
    ppToc = toc(ppTic);
end

IOFig = figure;
for i=1:length(inputSeq)
    plotIO(IOFig, inputSeq(1:i), output(1:i));
%     pause(0.01);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val = simpleMu(x,y)
    if(x>=-y)
        val = 0.1;
    else
        val = -0.1;
    end
end

function val = maskSimpleMu(xMesh, yMesh)
    val = zeros(size(xMesh));
    for m=1:size(val,1)
        for n=1:size(val,2)
            if(xMesh(m,n)<=yMesh(m,n))
                val(m,n) = simpleMu(xMesh(m,n),yMesh(m,n));
            end
        end
    end
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

function plotIO(fig, input, output)
    figure(fig);

    clf
    plot(input(:),output(:),'b-x');
    hold on; grid on; axis square;
    drawnow
end

function [output, areas] = computeOutput(L, areas, weightFunc, xMesh, yMesh, xLims, yLims)
    output = 0;
    
    if(size(areas,1)<1 || size(areas,2)~=5)
        areas = zeros(1,5);
    end
    
    if(size(L,1)<2)
        return;
    end
    
    for i=1:size(L,1)-1
        if(L(i,2)==L(i+1,2))
            if( size(areas,1)>=i && isequal(areas(i,1:4), [L(i,1), L(i+1,1), L(i,2), yLims(2)]) )
                output = output + areas(i,5);
            else
                integralVal = computeIntegral(xMesh, yMesh, weightFunc, [L(i,1), L(i+1,1)], [L(i,2), yLims(2)]);
                areas = [areas; L(i,1), L(i+1,1), L(i,2), yLims(2), integralVal];
                output = output + integralVal;
            end
        elseif(L(i,1)==L(i+1,1))
            if( size(areas,1)>=i && isequal(areas(i,1:4), [xLims(1), L(i,1), L(i+1,2), L(i,2)]) )
                output = output - areas(i,5);
            else
                integralVal = computeIntegral(xMesh, yMesh, weightFunc, [xLims(1), L(i,1)], [L(i+1,2), L(i,2)]);
                areas = [areas; xLims(1), L(i,1), L(i+1,2), L(i,2), integralVal]; 
                output = output - integralVal;
            end
        end 
    end
    if (size(areas,1)>=i+1 && isequal(areas(i+1,1:4), [xLims(1), L(end,1), yLims(1), L(end,2)]) )
        output = output + areas(i+1,5);
    else
        integralVal = computeIntegral(xMesh, yMesh, weightFunc, [xLims(1), L(end,1)], [yLims(1), L(end,2)]);
        areas = [areas; xLims(1), L(end,1), yLims(1), L(end,2), integralVal];
        output = output + integralVal;
    end
    if (size(areas,1)>=i+2 && isequal(areas(i+2,1:4), [L(end,1), xLims(2), L(end,2), yLims(2)]) )
        output = output - areas(i+2,5);
    else
        integralVal = computeIntegral(xMesh, yMesh, weightFunc, [L(end,1), xLims(2)], [L(end,2), yLims(2)]);
        areas = [areas; L(end,1), xLims(2), L(end,2), yLims(2), integralVal];
        output = output - integralVal;
    end
    areas = areas(1:i+2,:);

%     output = output...
%         - integral2(@maskSimpleMu, areas(end,1), xLims(2), areas(end,2), yLims(2))...
%         + integral2(@maskSimpleMu, xLims(1), areas(end,1), yLims(1), areas(end,2));  
%     for i=2:size(areas,1)
%         if(areas(i,2)==areas(i+1,2))
%             output = output...
%                 + integral2(@maskSimpleMu, areas(i,1), areas(i+1,1), areas(i,2), yLims(2));
%         elseif(areas(i,1)==areas(i+1,1))
%             output = output...
%                 - integral2(@maskSimpleMu, xLims(1), areas(i+1,1), areas(i+1,2), areas(i,2));
%         end 
%     end
end

function val = computeIntegral(xMesh, yMesh, weightFunc, xLims, yLims)
%     interpXN = max([600, min([100, ceil(abs(xLims(2)-xLims(1)))/0.1])]);
%     interpYN = max([300, min([50, ceil(abs(yLims(2)-yLims(1)))/10])]);
    interpXN = 300;
    interpYN = 300;
    xDiff = (xLims(2)-xLims(1))/(interpXN-1);
    yDiff = (yLims(2)-yLims(1))/(interpYN-1);
    xInterpGrid = linspace(xLims(1), xLims(2), interpXN);
    yInterpGrid = linspace(yLims(1), yLims(2), interpYN);
    [xInterpMesh, yInterpMesh] = meshgrid(xInterpGrid, yInterpGrid);
    
    interpMu = interp2(xMesh, yMesh, weightFunc, xInterpMesh, yInterpMesh, 'cubic');
    interpMu(isnan(interpMu)) = 0;
    
    val = sum(sum(interpMu.*(xDiff*yDiff)));
end




