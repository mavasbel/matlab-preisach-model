classdef PreisachRelayModel < matlab.mixin.SetGet %handle
    properties
        relayOnVal =  1
        relayOffVal = -1
        
        gridSize;
        inputGrid;
        relayLength;
        relayArea;
        relaysNum;
        
        relays;
        
        weightFunc;
        offset;
    end

    methods (Access = public)
        function obj = PreisachRelayModel(inputLims, gridSize, offset)
            obj.gridSize = gridSize;
            obj.inputGrid = linspace(inputLims(1), inputLims(2), obj.gridSize);
            obj.relayLength = (inputLims(2)-inputLims(1))/(obj.gridSize-1);
            obj.relayArea = obj.relayLength^2;
            
            obj.relaysNum = obj.gridSize*(obj.gridSize+1)/2;
            obj.relays = obj.relayOffVal*fliplr(triu(ones(obj.gridSize, obj.gridSize)));
            if(exist('offset','var')), obj.offset = offset;
            else, obj.offset = 0; end
        end
        
        function printInfo(obj)
            disp(['--Preisach parameters--']);
            disp(['Plane discretization: ', num2str(obj.gridSize)]);
            disp(['Plane discretization area: ', num2str(obj.relayArea)]);
            disp(['Total relays: ', num2str(obj.relaysNum)]);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Set all relays to off value
        function relays = resetRelaysOff(obj)
            obj.relays = obj.relayOffVal*fliplr(triu(ones(obj.gridSize, obj.gridSize)));
            relays = obj.relays;
        end
        
        % Set all relays to off value
        function relays = resetRelaysOn(obj)
            obj.relays = obj.relayOnVal*fliplr(triu(ones(obj.gridSize, obj.gridSize)));
            relays = obj.relays;
        end
        
        % Set all relays in square region delimited by indexes to given
        % state
        function relays = setRelaysWindow(obj,...
                leftIdx, rightIdx,...
                lowerIdx, upperIdx,...
                relayState)
             
            obj.relays(lowerIdx:upperIdx, leftIdx:rightIdx) = ...
                relayState*ones(col, col);
            obj.relays = obj.relays.*...
                        fliplr(triu(ones(obj.gridSize, obj.gridSize)));
            relays = obj.relays;
        end
        
        % Set all relays in square region delimited by values (alpha, beta)
        % to a given state
        function relays = setRelaysWindowByValue(obj,...
                leftVal, rightVal,...
                lowerVal, upperVal,...
                relayState)
            leftVal = min([max([leftVal, obj.inputGrid(1)]), obj.inputGrid(end)]);
            rightVal = min([max([rightVal, leftVal]), obj.inputGrid(end)]);
            
            lowerVal = min([max([lowerVal, obj.inputGrid(1)]), obj.inputGrid(end)]);
            upperVal = min([max([upperVal, lowerVal]), obj.inputGrid(end)]);
            
            leftIdx = cellfun(@(v)v(1),{find(obj.inputGrid >= leftVal)});
            rightIdx = cellfun(@(v)v(end),{find(obj.inputGrid <= rightVal)});
            lowerIdx = obj.gridSize - ...
                cellfun(@(v)v(1),{find(obj.inputGrid >= lowerVal)}) + 1;
            upperIdx = obj.gridSize - ...
                cellfun(@(v)v(end),{find(obj.inputGrid <= upperVal)}) + 1;
            
            relays = obj.setRelaysWindow(leftIdx, rightIdx,...
                lowerIdx, upperIdx,...
                relayState);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Update the state of relays according to input value
        function relays = updateRelays(obj, input)
            if( input >= obj.inputGrid(end))
                obj.relays = obj.relayOnVal*fliplr(triu(ones(obj.gridSize, obj.gridSize)));
            elseif( input <= obj.inputGrid(1) )
                obj.relays = obj.relayOffVal*fliplr(triu(ones(obj.gridSize, obj.gridSize)));
            else
                inputIdx = cellfun(@(v)v(1),{find(obj.inputGrid >= input)});
                col = inputIdx;
                row = obj.gridSize - inputIdx + 1;
                obj.relays(row:end, 1:col) = obj.relayOnVal*fliplr(triu(ones(col, col)));
                obj.relays(1:row-1, col+1:end) = obj.relayOffVal*fliplr(triu(ones(row-1, row-1)));
            end
            relays=obj.relays;
        end
        
        % Compute the output
        function output = getOutput(obj)
            output = sum(sum(obj.relays(:,:).*obj.weightFunc))*obj.relayArea + obj.offset;
        end

    end
end