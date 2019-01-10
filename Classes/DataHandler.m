classdef DataHandler < matlab.mixin.SetGet %handle
    properties
        origSampleLength
        origInputSeq
        origOutputSeq
        origTimeSeq

        sampleLength
        inputSeq
        outputSeq
        indexesSeq
        timeSeq
        inputMin
        inputMax
        outputMin
        outputMax
        initialInput
        maxInputPeakIdx
        minInputPeakIdx
        maxOutputPeakIdx
        minOutputPeakIdx
        zeroCrossInputIdx
        zeroCrossOutputIdx
    end
    
    methods
        function obj = DataHandler(origInputSeq, origOutputSeq, origTimeSeq)
            obj.origInputSeq = origInputSeq(:);
            obj.origOutputSeq = origOutputSeq(:);
            obj.origSampleLength = length(origInputSeq);
            
            obj.inputSeq = origInputSeq(:);
            obj.outputSeq = origOutputSeq(:);
            obj.indexesSeq = (1:obj.origSampleLength)';
            
            if(nargin>2 && exist('origTimeSeq', 'var'))
                obj.origTimeSeq = origTimeSeq(:);
                obj.timeSeq = obj.origTimeSeq(:);
            end
            
            obj.findSequenceParams();
        end
        
        function printInfo(obj)
            disp(['--Data parameters--']);
            disp(['Original data length: ', num2str(obj.origSampleLength)]);
            disp(['Adjusted data length: ', num2str(obj.sampleLength)]);
            if( ~isempty(obj.origTimeSeq) )
                disp(['Original total time: ', num2str(obj.origTimeSeq(end) - obj.origTimeSeq(1))]);
%                 disp(['Original initial time: ', num2str(obj.origTimeSeq(1))]);
%                 disp(['Original final time: ', num2str(obj.origTimeSeq(end))]);
            end
            if( ~isempty(obj.timeSeq) )
                disp(['Adjusted time interval: ', num2str(obj.timeSeq(end) - obj.timeSeq(1))]);
%                 disp(['Adjusted initial time: ', num2str(obj.timeSeq(1))]);
%                 disp(['Adjusted final time: ', num2str(obj.timeSeq(end))]);
            end
            disp(['Min input: ', num2str(obj.inputMin)]);
            disp(['Max input: ', num2str(obj.inputMax)]);
            disp(['Min output: ', num2str(obj.outputMin)]);
            disp(['Max output: ', num2str(obj.outputMax)]);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function [inputSeq, outputSeq, indexesSeq] = findSequenceParams(obj)
            obj.sampleLength = length(obj.inputSeq);
            
            obj.inputMin = min(obj.inputSeq);
            obj.inputMax = max(obj.inputSeq);
            obj.outputMin = min(obj.outputSeq);
            obj.outputMax = max(obj.outputSeq);
            obj.initialInput = obj.inputSeq(1);
            
            [~,obj.maxInputPeakIdx] = findpeaks(obj.inputSeq);
            [~,obj.minInputPeakIdx] = findpeaks(-obj.inputSeq);
            [~,obj.maxOutputPeakIdx] = findpeaks(obj.outputSeq);
            [~,obj.minOutputPeakIdx] = findpeaks(-obj.outputSeq);
            obj.zeroCrossInputIdx = cell2mat(cellfun(@(v){find(v(:).*circshift(v(:), [-1 0]) <= 0)},{obj.inputSeq}));
            obj.zeroCrossOutputIdx = cell2mat(cellfun(@(v){find(v(:).*circshift(v(:), [-1 0]) <= 0)},{obj.outputSeq}));
            
            obj.maxInputPeakIdx(cellfun('isempty',{obj.maxInputPeakIdx})) = 0;
            obj.minInputPeakIdx(cellfun('isempty',{obj.minInputPeakIdx})) = 0;
            obj.maxOutputPeakIdx(cellfun('isempty',{obj.maxOutputPeakIdx})) = 0;
            obj.minOutputPeakIdx(cellfun('isempty',{obj.minOutputPeakIdx})) = 0;
            
            inputSeq = obj.inputSeq;
            outputSeq = obj.outputSeq;
            indexesSeq = obj.indexesSeq;
        end
        
        function resetOrigSequences(obj)
            obj.inputSeq = obj.origInputSeq;
            obj.outputSeq = obj.origOutputSeq;
            obj.indexesSeq = (1:obj.origSampleLength)';
            
            clear obj.timeSeq;
            if( ~isempty(obj.origTimeSeq) )
                obj.timeSeq = obj.origTimeSeq(:);
            end
            
            obj.findSequenceParams();
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function [inputSeq, outputSeq, indexesSeq] = circShiftInputMinMax(obj)
            obj.inputSeq = circshift(obj.inputSeq, obj.minInputPeakIdx(1));
            obj.outputSeq = circshift(obj.outputSeq, obj.minInputPeakIdx(1));
            
            [inputSeq, outputSeq, indexesSeq] = obj.findSequenceParams();
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function [inputSeq, outputSeq, indexesSeq] = trimFirstSecondMaxInput(obj)
            if(length(obj.maxInputPeakIdx)==3)
                startTrimIdx = obj.maxInputPeakIdx(1); 
                endTrimIdx = obj.maxInputPeakIdx(2); 
                
                obj.indexesSeq = (startTrimIdx:endTrimIdx)';
                obj.inputSeq = obj.origInputSeq(obj.indexesSeq);
                obj.outputSeq = obj.origOutputSeq(obj.indexesSeq);
                
                if( ~isempty(obj.timeSeq) )
                    obj.timeSeq = obj.timeSeq(obj.indexesSeq);
                end
                
            end
    
            [inputSeq, outputSeq, indexesSeq] = obj.findSequenceParams();
        end
        
        function [inputSeq, outputSeq, indexesSeq] = trimSecondThirdMaxInput(obj)
            if(length(obj.maxInputPeakIdx)==3)
                startTrimIdx = obj.maxInputPeakIdx(2); 
                endTrimIdx = obj.maxInputPeakIdx(3); 
                
                obj.indexesSeq = (startTrimIdx:endTrimIdx)';
                obj.inputSeq = obj.origInputSeq(obj.indexesSeq);
                obj.outputSeq = obj.origOutputSeq(obj.indexesSeq);
                
                if( ~isempty(obj.timeSeq) )
                    obj.timeSeq = obj.timeSeq(obj.indexesSeq);
                end
                
            end
    
            [inputSeq, outputSeq, indexesSeq] = obj.findSequenceParams();
        end
        
        function [inputSeq, outputSeq, indexesSeq] = trimFirstMaxLastMinInput(obj)
            if(length(obj.minInputPeakIdx)==3)
                startTrimIdx = obj.maxInputPeakIdx(1); 
                endTrimIdx = obj.minInputPeakIdx(3);
                
                obj.indexesSeq = (startTrimIdx:endTrimIdx)';
                obj.inputSeq = obj.origInputSeq(obj.indexesSeq);
                obj.outputSeq = obj.origOutputSeq(obj.indexesSeq);
                
                if( ~isempty(obj.timeSeq) )
                    obj.timeSeq = obj.timeSeq(obj.indexesSeq);
                end
            
            end
            % startTrimIndex = cellfun(@(v)v(1),{find(interpInputSeq >= 650)});
    
            [inputSeq, outputSeq, indexesSeq] = obj.findSequenceParams();
        end

        function [inputSeq, outputSeq, indexesSeq] = trimSecondMaxLastMinInput(obj)
            if(length(obj.minInputPeakIdx)==3)
                startTrimIdx = obj.maxInputPeakIdx(2); 
                endTrimIdx = obj.minInputPeakIdx(3);
                
                obj.indexesSeq = (startTrimIdx:endTrimIdx)';
                obj.inputSeq = obj.origInputSeq(obj.indexesSeq);
                obj.outputSeq = obj.origOutputSeq(obj.indexesSeq);
                
                if( ~isempty(obj.timeSeq) )
                    obj.timeSeq = obj.timeSeq(obj.indexesSeq);
                end
                
            end
    
            [inputSeq, outputSeq, indexesSeq] = obj.findSequenceParams();
        end
        
        function [inputSeq, outputSeq, indexesSeq] = trimFirstZeroCrossInput(obj)
            if(length(obj.maxInputPeakIdx)==3)
                startTrimIdx = obj.zeroCrossInputIdx(2)+1; 
                endTrimIdx = obj.sampleLength; 
                
                obj.indexesSeq = (startTrimIdx:endTrimIdx)';
                obj.inputSeq = obj.origInputSeq(obj.indexesSeq);
                obj.outputSeq = obj.origOutputSeq(obj.indexesSeq);
                
                if( ~isempty(obj.timeSeq) )
                    obj.timeSeq = obj.timeSeq(obj.indexesSeq);
                end
            end
    
            [inputSeq, outputSeq, indexesSeq] = obj.findSequenceParams();
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function [inputSeq, outputSeq, indexesSeq] = normalizeInput(obj)
            obj.inputSeq = obj.inputSeq/max([abs(obj.inputMin),abs(obj.inputMax)]);
            
            [inputSeq, outputSeq, indexesSeq] = obj.findSequenceParams();
        end
        
        function [inputSeq, outputSeq, indexesSeq] = normalizeOutput(obj)
            obj.outputSeq = obj.outputSeq/max([abs(obj.outputMax),abs(obj.outputMin)]);
            
            [inputSeq, outputSeq, indexesSeq] = obj.findSequenceParams();
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function [inputSeq, outputSeq, indexesSeq] = interpSequence(obj, interpLength)
            interpIdx = linspace(1, obj.sampleLength, interpLength)';
            
            obj.indexesSeq = interp1(obj.indexesSeq, interpIdx, 'linear');
            obj.inputSeq = interp1(obj.inputSeq, interpIdx, 'linear');
            obj.outputSeq = interp1(obj.outputSeq, interpIdx, 'pchip');
            
            if( ~isempty(obj.timeSeq) )
                obj.timeSeq = interp1(obj.timeSeq, interpIdx, 'linear');
            end
            
            [inputSeq, outputSeq, indexesSeq] = obj.findSequenceParams();
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function [inputSeq, outputSeq, indexesSeq] = repeatNotPeriodic(obj)
            if(length(obj.maxInputPeakIdx)<=1 || length(obj.minInputPeakIdx)<=1)
                obj.inputSeq = repmat(obj.inputSeq,3,1);
                obj.outputSeq = repmat(obj.outputSeq,3,1);
                obj.indexesSeq = [obj.indexesSeq;...
                    obj.indexesSeq + 1*obj.indexesSeq(end);...
                    obj.indexesSeq + 2*obj.indexesSeq(end);];
                
                if( ~isempty(obj.timeSeq) )
                    obj.timeSeq = [obj.timeSeq;...
                        obj.timeSeq + 1*obj.timeSeq(end);...
                        obj.timeSeq + 2*obj.timeSeq(end);];
                end
            end
    
            [inputSeq, outputSeq, indexesSeq] = obj.findSequenceParams();
        end
        
    end
end