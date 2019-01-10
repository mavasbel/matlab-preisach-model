classdef RateDepPreisachRelayModel < PreisachRelayModel %handle
    properties
        rateWeightFunc;
    end

    methods (Access = public)
        function obj = RateDepPreisachRelayModel(inputLims, gridDen)
            obj@PreisachRelayModel(inputLims, gridDen);
        end
        
        function printInfo(obj)
            disp(['--Preisach parameters--']);
            disp(['Plane discretization: ', num2str(obj.gridDen)]);
            disp(['Plane discretization area: ', num2str(obj.gridArea)]);
            disp(['Total relays: ', num2str(obj.totalRelays)]);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function output = getOutput(obj)
            output = sum(sum(obj.relays(:,:).*obj.weightFunc))*obj.gridArea... 
                + diff(obj.lastInputPair)*sum(sum(obj.relays(:,:).*obj.rateWeightFunc))*obj.gridArea;
        end

    end
end