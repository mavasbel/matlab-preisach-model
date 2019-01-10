classdef PreisachAreaBased < handle
    properties
        L;
        areas;
        inputLims;
    end
    methods
        function obj = PreisachAreaBased(inputLims)
            obj.inputLims = inputLims;
            obj.resetMinInputL();
        end
        
        function resetMinInputL(obj)
            obj.L = [obj.inputLims(1), obj.inputLims(2); 
                obj.inputLims(1), obj.inputLims(1)]; 
        end
        
        function resetMaxInputL(obj)
            obj.L = [obj.inputLims(1), obj.inputLims(2); 
                obj.inputLims(2), obj.inputLims(2)]; 
        end
        
        function removeMidPoints(obj)
            i = 2;
            while(i<size(obj.L,1))
                if( (obj.L(i-1,1)==obj.L(i,1) && obj.L(i,1)==obj.L(i+1,1))...
                    || (obj.L(i-1,2)==obj.L(i,2) && obj.L(i,2)==obj.L(i+1,2)) )
                    obj.L(i,:) = [];
                else
                    i = i+1;
                end
            end
        end
        
        function L = updateL(obj, input)
            obj.removeInlinePoints();
            
            for i=1:size(obj.L,1)
                if((obj.L(i,1)<=input && input<obj.L(i,2)) ...
                        || (obj.L(i,1)<input && input<=obj.L(i,2)))
                    continue;
                elseif (obj.L(i,1)>input && obj.L(i,2)>input)
                    obj.L = [obj.L(1:i-1,:); input, obj.L(i,2); input,input];
                    break;
                elseif (obj.L(i,1)<input && obj.L(i,2)<input)
                    obj.L = [obj.L(1:i-1,:); obj.L(i,1), input; input,input];
                    break;
                else
                    obj.L = [obj.L(1:i-1,:); input,input];
                    break;
                end
            end
            
            L = obj.L;
        end
    end
end
