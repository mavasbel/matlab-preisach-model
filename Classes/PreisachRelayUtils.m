classdef PreisachRelayUtils < handle
    properties
        preisachRelayModel
    end
    
    methods
        function obj = PreisachRelayUtils(preisachRelayModel)
            obj.preisachRelayModel = preisachRelayModel;
        end
        
        %Applies and input to the Preisach operator and returns the
        %corresponding output and relays sequence
        %The filtereing operation means that if the
        %exact same state of all relays in the Preisach plane is generated
        %more than once, the corresponding output are averaged
        function [filteredInputSeq, filteredOutputSeq, filteredRelaysSeq] = filterSequences(obj, inputSeq, outputSeq)
            inputSeq = inputSeq(:);
            outputSeq = outputSeq(:);
            
            sampleLength = length(inputSeq);
            filteredOutputSeq = zeros(sampleLength,1);
            filteredOutputCounters = ones(sampleLength,1);
            filteredInputSeq = zeros(sampleLength,1);
            filteredInputCounters = ones(sampleLength,1);
            filteredRelaysSeq = zeros(obj.preisachRelayModel.gridSize, obj.preisachRelayModel.gridSize, sampleLength);
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
                    filteredRelaysSeq(:,:,hashCounter) = relays;
                    hashCounter = hashCounter + 1;
                end
            end
            filteredRelaysSeq = filteredRelaysSeq(:,:,1:hashCounter-1);
            filteredInputCounters = filteredInputCounters(1:hashCounter-1);
            filteredOutputCounters = filteredOutputCounters(1:hashCounter-1);
            filteredInputSeq = filteredInputSeq(1:hashCounter-1)./filteredInputCounters;
            filteredOutputSeq = filteredOutputSeq(1:hashCounter-1)./filteredOutputCounters;
        end
        
        %Applies and input to the Preisach operator and returns the
        %corresponding output and relays sequence
        function [outputSeq, relaysSeq] = generateOutputSeq(obj, inputSeq)
            inputSeq = inputSeq(:);
            
            sampleLength = size(inputSeq, 1);
            outputSeq = zeros(sampleLength,1);
            relaysSeq = zeros(obj.preisachRelayModel.gridSize, obj.preisachRelayModel.gridSize, sampleLength);
            for i=1:sampleLength
                relaysSeq(:,:,i) = obj.preisachRelayModel.updateRelays(inputSeq(i));
                outputSeq(i) = obj.preisachRelayModel.getOutput();
            end
        end
        
        %Fits the weighting function to a given input and output
        function [filterTime, fittingTime, weightFuncTime] = fitModel(obj, inputSeq, outputSeq)
            inputSeq = inputSeq(:);
            outputSeq = outputSeq(:);
            
            % Generating filtered sequences
            filterTic = tic;
            obj.preisachRelayModel.resetRelaysOff();
            [filteredInputSeq, filteredOutputSeq, filteredRelaysSeq] = ...
                obj.filterSequences(inputSeq, outputSeq);
            P = [obj.buildRelaysMatrix(filteredRelaysSeq)*obj.preisachRelayModel.relayArea,...
                ones(size(filteredRelaysSeq,3),1)];
            filterTime = toc(filterTic);

            % Computing weights
            fittingTic = tic;
            weightVector = obj.fitWeights(P, filteredOutputSeq);
            fittingTime = toc(fittingTic);

            % Building weight plane
            weightPlaneTic = tic;
            obj.preisachRelayModel.weightFunc = obj.buildWeightPlane(weightVector);
            obj.preisachRelayModel.offset = weightVector(end);
            weightFuncTime = toc(weightPlaneTic);
        end
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    methods (Access = private)
        %Function to validate if a matrix is repeated using a list of the
        %hashes of the matrices to compare
        function [repeated, repeatedIndex, hash] = isRepeated(obj, matrix, matrixHashes, hashCounter)
            repeatedIndex = 0;
            repeated = false;
            hash = obj.generateHash(matrix);
            for i=[hashCounter, 1:hashCounter-1]
                if( strcmp(hash,matrixHashes(i)) )
                    repeatedIndex = i;
                    repeated = true;
                    break;
                end
            end
        end
        
        %Generate the binary hash of a matrix
        function hash = generateHash(obj, matrix)
            bytes = getByteStreamFromArray(matrix);
            md = java.security.MessageDigest.getInstance('SHA-1');
            md.update(bytes);
            hash = char(reshape(dec2hex(typecast(md.digest(),'uint8'))',1,[]));
        end
        
        %Reshape a sequence of matrices that represent the state of the
        %relays in the Preisach plane (the third dimension of the matrix is
        %the time instant) to a single matrix whose rows are each time
        %instant
        function relaysMatrix = buildRelaysMatrix(obj, relaysSeq)
            samplesLength = size(relaysSeq, 3);
            relayIdx = 1;
            relaysMatrix = zeros(samplesLength, obj.preisachRelayModel.totalRelays);
            for i=1:obj.preisachRelayModel.gridSize
                ii = obj.preisachRelayModel.gridSize-i+1; %index inversion for rows
                for j=1:i
                    relaysMatrix(:,relayIdx) = relaysSeq(ii,j,:);
                    relayIdx = relayIdx + 1;
                end
            end
        end
        
        %Reverses the operation of "buildRelaysMatrix" for a single row
        %(the parameter weightVector) acomodating each element in the row
        %to the corresponding position in the Preisach plane
        function weightFunc = buildWeightPlane(obj, weightVector)
            weightFunc = zeros(obj.preisachRelayModel.gridSize, obj.preisachRelayModel.gridSize);
            vecIdx = 1;
            for i=1:obj.preisachRelayModel.gridSize
                ii = obj.preisachRelayModel.gridSize-i+1; %index inversion for rows
                for j=1:i
                    weightFunc(ii,j) = weightVector(vecIdx);
                    vecIdx = vecIdx + 1;
                end
            end
        end
        
        %Approximante inversion based on svd
        function weightVector = svdApproxInverse(obj, P, filteredOutputSeq)
            [U,S,V] = svd(P'*P);
            weightVector = 0;
            for i = 1:obj.preisachRelayModel.totalRelays
                if S(i,i) > 10e-1
                    weightVector = weightVector + U(:,i)'*(P'*filteredOutputSeq)./S(i,i)*V(:,i);
                end
            end
        end
        
        %Computes the approximante inversion
        function weightVector = fitWeights(obj, P, filteredOutputSeq)
            gamma = 0.0;
            % weightVector = ( P'*P + gamma*eye(size(P,2)) ) \ P'*filteredOutputSeq;
            weightVector = P'*( (P*P' + gamma*eye(size(P,1)) ) \ filteredOutputSeq );
            % weightVector = svdApproxInverse(P, filteredOutputSeq, gridSize);
        end
        
    end
    
end