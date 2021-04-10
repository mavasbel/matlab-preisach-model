function handlers = plotRectangle(vertix, maxZ, linePoints)
    handlers = [];
    for i=1:size(vertix,1)
        j = i+1;
        if i==size(vertix,1)
            j = 1;
        end
        line = [linspace(vertix(i,1), vertix(j,1), linePoints);
            linspace(vertix(i,2), vertix(j,2), linePoints);
            repmat(maxZ, 1, linePoints)]';
        handlers = [handlers; plot3(line(:,1), line(:,2), line(:,3), '--k', 'linewidth', 7)];
    end
end