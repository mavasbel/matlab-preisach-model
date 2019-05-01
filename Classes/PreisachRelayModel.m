classdef PreisachRelayModel < matlab.mixin.SetGet %handle
    properties
        hysteronMax =  1
        hysteronMin = -1
        
        gridDen;
        gridLength;
        gridArea;
        xyGrid;
        totalRelays;
        
        relays;
        
        weightFunc;
        offset;
        
    end

    methods (Access = public)
        function obj = PreisachRelayModel(inputLims, gridDen, offset)
            obj.gridDen = gridDen;
            obj.gridLength = (inputLims(2)- inputLims(1))/(obj.gridDen-1);
            obj.gridArea = obj.gridLength^2;
            obj.xyGrid = linspace(inputLims(1), inputLims(2), obj.gridDen);
            
            obj.totalRelays = obj.gridDen*(obj.gridDen+1)/2;
            obj.relays = obj.hysteronMin*fliplr(triu(ones(obj.gridDen, obj.gridDen)));
            
            obj.offset = 0;
        end
        
        function printInfo(obj)
            disp(['--Preisach parameters--']);
            disp(['Plane discretization: ', num2str(obj.gridDen)]);
            disp(['Plane discretization area: ', num2str(obj.gridArea)]);
            disp(['Total relays: ', num2str(obj.totalRelays)]);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function relays = setRelaysWindowValue(obj, relayValue, lowerIdx, upperIdx, leftIdx, rightIdx)
            for i=1:obj.gridDen
                ii = obj.gridDen-i+1; %index inversion for rows
                for j=1:i
                    if( ( (i>=lowerIdx && i<=upperIdx) && ...
                        ( (j>=leftIdx && j<=rightIdx)  ) ) )
                        obj.relays(ii,j) = relayValue;
                    end
                end
            end
            relays = obj.relays;
        end
        
        function relays = resetRelaysOff(obj)
            obj.relays = obj.hysteronMin*fliplr(triu(ones(obj.gridDen, obj.gridDen)));
            relays = obj.relays;
        end
        
        function relays = resetRelaysOn(obj)
            obj.relays = obj.hysteronMax*fliplr(triu(ones(obj.gridDen, obj.gridDen)));
            relays = obj.relays;
        end
        
        function relays = setRelaysOnLessThanInput(obj, inputVal)
            rightIdx = cellfun(@(v)v(1),{find(obj.xyGrid >= inputVal)});
            leftIdx = 1;
            upperIdx = obj.gridDen;
            lowerIdx = 1;

            relays = obj.setRelaysWindowValue(obj.hysteronMax, lowerIdx, upperIdx, leftIdx, rightIdx);
        end
        
        function relays = setRelaysUpperLeftCorner(obj, inputVal)
            leftIdx = 1;
            rightIdx = cellfun(@(v)v(1),{find(obj.xyGrid >= inputVal)});
            upperIdx = obj.gridDen;
            lowerIdx = obj.gridDen+1-cellfun(@(v)v(1),{find(obj.xyGrid >= inputVal)});

            relays = obj.setRelaysWindowValue(obj.hysteronMax, lowerIdx, upperIdx, leftIdx, rightIdx);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function relays = updateRelays(obj, input)
%             for i=1:obj.gridDen
%                 ii = obj.gridDen-i+1; %index inversion for rows
%                 for j=1:i
%                     if( input >= obj.xyGrid(i) && obj.relays(ii,j) ~= obj.hysteronMax )
%                         obj.relays(ii,j) = obj.hysteronMax;
%                     elseif( input <= obj.xyGrid(j) && obj.relays(ii,j) ~= obj.hysteronMin )
%                         obj.relays(ii,j) = obj.hysteronMin;
%                     end
%                 end
%             end
%             relays = obj.relays;


            if( obj.xyGrid(end) <= input )
                obj.relays = obj.hysteronMax*fliplr(triu(ones(obj.gridDen, obj.gridDen)));
            elseif( input < obj.xyGrid(1) )
                obj.relays = obj.hysteronMin*fliplr(triu(ones(obj.gridDen, obj.gridDen)));
            else
                idx0 = 1;
                while( idx0 <= obj.gridDen-1 )
                    if( obj.xyGrid(idx0) <= input && input < obj.xyGrid(idx0+1) )
                        col = idx0;
                        row = obj.gridDen-idx0+1;
                
%                         temp = obj.relays(row, col);
                        obj.relays(row:end, 1:col) = obj.hysteronMax*fliplr(triu(ones(col, col)));
                        obj.relays(1:row-1, col+1:end) = obj.hysteronMin*fliplr(triu(ones(row-1, row-1)));
%                         obj.relays(row,col) = temp;
                        break;
                    end
                    idx0 = idx0 + 1;
                end
            end
            relays=obj.relays;
        end
        
        function output = getOutput(obj)
            output = sum(sum(obj.relays(:,:).*obj.weightFunc))*obj.gridArea + obj.offset;
        end

    end
end