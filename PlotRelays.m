close all
clc

preisachPlots = PreisachPlots();

for i=1:size(simRelays,3)
    plotRelayState(simRelays(:,:,i), xyGrid)
    drawnow
end 
    
function plotRelayState(relays, xyGrid)
    stdDevColorFactor = 2.2;    
    avgColorFactor = 3.5;

    posMu = max(relays,0);
    posNnz = nnz(posMu);
    posAvg = sum(sum(posMu))/posNnz;
    posOnes = spones(posMu);
    posStdDev = sqrt(sum(sum( (posMu - posAvg.*posOnes).^2 ))/posNnz);  
    negMu = min(relays,0);
    negNnz = nnz(negMu);
    negAvg = sum(sum(negMu))/negNnz;
    negOnes = spones(negMu);
    negStdDev = sqrt(sum(sum( (negMu - negAvg.*negOnes).^2 ))/negNnz);

    maxStdDev = nanmax([posStdDev, negStdDev]);
    maxAvg = nanmax([abs(posAvg), abs(negAvg)]);

    [xMesh, yMesh] = meshgrid(xyGrid, fliplr(xyGrid));
    surf(xMesh, yMesh, relays, 'edgecolor', 'none');
    xlim([xyGrid(1) xyGrid(end)]);
    ylim([xyGrid(1) xyGrid(end)]);

    caxis([-stdDevColorFactor*maxStdDev, stdDevColorFactor*maxStdDev]);

    colorbar
    colormap jet
    shading interp
    view([0 90])

    axis square;
end