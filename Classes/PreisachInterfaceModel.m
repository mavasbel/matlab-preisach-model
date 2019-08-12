classdef PreisachInterfaceModel < matlab.mixin.SetGet %handle
    properties
        relayOnVal =  1;
        relayOffVal = -1;
        
        gridSize;
        inputGrid;
        relayLength;
        relayArea;
        relaysNum;
        
        relays;
        
        weightFunc;
        offset;
        
        memory;
    end

    methods (Access = public)
        function obj = PreisachInterfaceModel()
        end
        
        function printInfo(obj)
            disp(['--Preisach parameters--']);
            disp(['Plane discretization: ', num2str(obj.gridSize)]);
            disp(['Plane discretization area: ', num2str(obj.relayArea)]);
            disp(['Total relays: ', num2str(obj.relaysNum)]);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function initMaxInput(obj, initialInput)
            obj.memory = [        -inf, initialInput;
                          initialInput, initialInput];
        end
        
        function initMinInput(obj, initialInput)
            obj.memory = [initialInput, inf;
                          initialInput, initialInput];
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function updateInterface(obj, input)
            if isempty(obj.memory)
                obj.initMinInput(input);
            elseif input>obj.memory(end,1)
                idx = find(obj.memory(:,2)>input, 1, 'last');
                if isempty(idx)
                    obj.initMaxInput(input);
                else
                    obj.memory = [obj.memory(1:idx,:);
                                  obj.memory(idx,1), input;
                                  input, input];
                end
            elseif input<obj.memory(end,1)
                idx = find(obj.memory(:,1)<input, 1, 'last');
                if isempty(idx)
                    obj.initMinInput(input);
                else
                    obj.memory = [obj.memory(1:idx,:);
                                  input, obj.memory(idx,2);
                                  input, input];
                end
            elseif input==obj.memory(end,1)
            end
        end
        
        function output = getOutput(obj)
            output = 0;
            for idx = size(obj.memory,1):-1:2
                if(obj.memory(idx,2) == obj.memory(idx-1,2))
                    col0 = find(obg.inputGrid>=obj.memory(idx-1,1), 1, 'first');
                    col1 = find(obg.inputGrid<=obj.memory(  idx,1), 1, 'last');
                    row0 = obj.gridSize - find(obg.inputGrid<=obj.memory(idx,2), 1, 'last') + 1;
                    output = output + sum(sum(obj.weightFunc(row0:end,col0:col1)))*obj.relayArea;
                    if(obg.inputGrid(col0)~=obj.memory(idx-1,1))
                    end
                    if(obg.inputGrid(col1)~=obj.memory(idx,1))
                    end
                end
            end
        end

    end
end