clc
close all

relaysSamples = size(filteredRelaysSeq,3);
sampleStep = 1;%floor(relSamples/400);

disp(strcat(['Total Samples: ', num2str(relaysSamples)]))
disp(strcat(['Sample step: ', num2str(sampleStep)]))

preisachPlaneFig = figure;
for i = 1:sampleStep:relaysSamples
    disp(num2str(i))
    plotSurface(preisachPlaneFig ,filteredRelaysSeq(:,:,i),alphabeta,n);
    drawnow
end

function fig = plotSurface(fig, relays, alphabeta, n)  
    [beta, alpha] = meshgrid(alphabeta, fliplr(alphabeta));
    surf(beta, alpha, relays, 'edgecolor','none');
    caxis([-1, 1]);

    colorbar
    colormap jet
    shading interp
    view([0 90])
end