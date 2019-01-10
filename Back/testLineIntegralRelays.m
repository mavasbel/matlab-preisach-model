clc

%weightFunc, offset, hysteronMin, hysteronMax, gridLength, gridDen, gridArea, xyGrid
relays = [
1     1     1     1     1     1     1     1
1     1     1     1     1     1     1     0
1    -1     1     1     1     1     0     0
1    -1     1    -1     1     0     0     0
1     1     1    -1     0     0     0     0
1     1     1     0     0     0     0     0
1     1     0     0     0     0     0     0
1     0     0     0     0     0     0     0
]
xyGrid

input=0;
weightFunc = abs(relays);

lineInt = [0; 0];
if( xyGrid(end) <= input )
    return;
elseif( input < xyGrid(1) )
    return;
else
    idx0 = 1;
    while( idx0 <= gridDen-1 )
        if( xyGrid(idx0) <= input && input < xyGrid(idx0+1) )
            col = idx0;
            row = gridDen-idx0+1;
            
            for var=col:-1:1
                if( relays(row-1,var)==hysteronMin )
                    lineInt(1) = lineInt(1) + gridLength*weightFunc(row-1,var);
                end
            end
            
            for var=row:-1:1
                if( relays(var,col)==hysteronMax )
                    lineInt(2) = lineInt(2) - gridLength*weightFunc(var,col);
                end
            end
            
            break;
        end
        idx0 = idx0 + 1;
    end
end
lineInt = 2*lineInt;