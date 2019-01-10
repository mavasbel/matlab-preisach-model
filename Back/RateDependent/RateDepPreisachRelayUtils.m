classdef RateDepPreisachRelayUtils < PreisachRelayUtils
    properties
    end
    
    methods
        function obj = RateDepPreisachRelayUtils(preisachRelayModel)
            obj@PreisachRelayUtils(preisachRelayModel);
        end
        
        function [filteredInputSeq, filteredOutputSeq,...
                filteredInputRateSeq, filteredRelaysSeq, filteredCounter]...
                = filterSequences(obj, inputSeq, outputSeq)
            sampleLength = length(inputSeq);
            filteredOutputSeq = zeros(sampleLength,1);
            filteredOutputCounters = ones(sampleLength,1);
            filteredInputSeq = zeros(sampleLength,1);
            filteredInputRateSeq = zeros(sampleLength,1);
            filteredInputCounters = ones(sampleLength,1);
            filteredRelaysSeq = zeros(obj.preisachRelayModel.gridDen, obj.preisachRelayModel.gridDen, sampleLength);
            matrixHashes = string(zeros(sampleLength,1));
            hashCounter = 1;
            
            for i=1:sampleLength
                relays = obj.preisachRelayModel.updateRelays(inputSeq(i));
                [repeated, repeatedIndex, hash] = obj.isRepeated(relays, matrixHashes, hashCounter);
                if( repeated == true )
                    filteredOutputSeq(repeatedIndex) = filteredOutputSeq(repeatedIndex) + outputSeq(i);
                    filteredOutputCounters(repeatedIndex) = filteredOutputCounters(repeatedIndex) + 1;
                    filteredInputSeq(repeatedIndex) = filteredInputSeq(repeatedIndex) + inputSeq(i);
                    filteredInputCounters(repeatedIndex) = filteredInputCounters(repeatedIndex) + 1;
                else
                    matrixHashes(hashCounter) = hash;
                    filteredOutputSeq(hashCounter) = outputSeq(i);
                    filteredInputSeq(hashCounter) = inputSeq(i);
                    filteredInputRateSeq(hashCounter) = diff(obj.preisachRelayModel.lastInputPair);
                    filteredRelaysSeq(:,:,hashCounter) = relays;
                    hashCounter = hashCounter + 1;
                end
            end
            
            filteredRelaysSeq = filteredRelaysSeq(:,:,1:hashCounter-1);
            filteredInputCounters = filteredInputCounters(1:hashCounter-1);
            filteredOutputCounters = filteredOutputCounters(1:hashCounter-1);
            filteredInputSeq = filteredInputSeq(1:hashCounter-1)./filteredInputCounters;
            filteredInputRateSeq = filteredInputRateSeq(1:hashCounter-1);
            filteredOutputSeq = filteredOutputSeq(1:hashCounter-1)./filteredOutputCounters;
            filteredCounter = hashCounter-1;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function relaysSeq = generateRelaysSeq(obj, inputSeq)
            sampleLength = length(inputSeq);
            relaysSeq = zeros(obj.preisachRelayModel.gridDen, obj.preisachRelayModel.gridDen, sampleLength);
            for i=1:sampleLength
                relaysSeq(:,:,i) = obj.preisachRelayModel.updateRelays(inputSeq(i));
            end
        end
        
        function [outputSeq, relaysSeq] = generateOutputSeq(obj, inputSeq)
            sampleLength = size(inputSeq, 1);
            outputSeq = zeros(sampleLength,1);
            relaysSeq = zeros(obj.preisachRelayModel.gridDen, obj.preisachRelayModel.gridDen, sampleLength);
            for i=1:sampleLength
                relaysSeq(:,:,i) = obj.preisachRelayModel.updateRelays(inputSeq(i));
                outputSeq(i) = obj.preisachRelayModel.getOutput();
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function weightVector = svdApproxInverse(obj, P, filteredOutputSeq)
            [U,S,V] = svd(P'*P);
            weightVector = 0;
            for i = 1:obj.preisachRelayModel.totalRelays
                if S(i,i) > 10e-1
                    weightVector = weightVector + U(:,i)'*(P'*filteredOutputSeq)./S(i,i)*V(:,i);
                end
            end
        end
        
        function weightVector = fitWeights(obj, P, filteredOutputSeq)
            gamma = 0.0;
            % weightVector = ( P'*P + gamma*eye(size(P,2)) ) \ P'*filteredOutputSeq;
            weightVector = P'*( (P*P' + gamma*eye(size(P,1)) ) \ filteredOutputSeq );
            % weightVector = svdApproxInverse(P, filteredOutputSeq, gridDen);
        end
        
        function [filterTime, fittingTime, weightFuncTime] = fitModel(obj, inputSeq, outputSeq)
            % Generating filtered sequences
            filterTic = tic;
            
            obj.preisachRelayModel.resetRelaysOff();
            [filteredInputSeq, filteredOutputSeq, filteredInputRateSeq,...
                filteredRelaysSeq, filteredCounter] = ...
                obj.filterSequences(inputSeq, outputSeq);
            
            relaysSeqRows = obj.buildRelaysMatrix(filteredRelaysSeq);
            P = [obj.preisachRelayModel.gridArea*(relaysSeqRows.*filteredInputRateSeq(:)),...
                obj.preisachRelayModel.gridArea*relaysSeqRows,...
                ones(size(filteredRelaysSeq,3),1)];
            
            filterTime = toc(filterTic);

            % Computing weights
            fittingTic = tic;
            weightVector = obj.fitWeights(P, filteredOutputSeq);
            fittingTime = toc(fittingTic);
            
%             weightVector = min(weightVector,0);
%             weightVector = max(weightVector,0);

            % Building weight plane
            weightPlaneTic = tic;
            obj.preisachRelayModel.rateWeightFunc = obj.buildWeightPlane(weightVector(1:obj.preisachRelayModel.totalRelays));
            obj.preisachRelayModel.weightFunc = obj.buildWeightPlane(weightVector(obj.preisachRelayModel.totalRelays+1:end));
            weightFuncTime = toc(weightPlaneTic);
        end
    end
    
end