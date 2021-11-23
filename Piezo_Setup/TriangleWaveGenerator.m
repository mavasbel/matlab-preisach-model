classdef TriangleWaveGenerator
    
    methods(Static)
        
        function yvector = periodic(amplitude, period, phase, ascTime, xvector)
            amplitude = abs(amplitude);
            period = abs(period);
            phase = abs(phase);
            ascTime = abs(ascTime);
            
            if(phase>period || phase<-period) 
                error('phase must in the interval [-pediod, +period]'); 
            end
            if(ascTime>period || ascTime<0) 
                error(strcat(['ascTime must be greater than 0 '...
                    'and less or equal to period'])); 
            end
            xmod = mod(xvector + ascTime/2 + phase, period);
            yvector = 2*amplitude*...
                        (triangularPulse(0, ascTime, period, xmod) - 0.5);
        end

        function yvector = periodicWithSlopes(amplitude, ascSlope, descSlope, xvector)
            ascSlope = abs(ascSlope);
            descSlope = abs(descSlope);
            amplitude = abs(amplitude);

            ascTime = 2*amplitude/ascSlope;
            period = 2*amplitude*(1/ascSlope + 1/descSlope); 
            yvector = TriangleWaveGenerator. ...
                    periodic(amplitude, period, 0, ascTime, xvector);
        end

        function yvector = fading(initialAmplitude, period,...
                ascTime, fadingRate, xvector)
            yvector = TriangleWaveGenerator. ...
                    periodic(initialAmplitude, period, 0, ascTime, xvector).*...
                        max((1-fadingRate*floor(xvector/period)),0);
        end

        function yvector = fadingWithSlopes(initialAmplitude,...
                ascSlope, descSlope,...
                fadeRate, xvector)
            ascSlope = abs(ascSlope);
            descSlope = abs(descSlope);
            initialAmplitude = abs(initialAmplitude);
            fadeRate = abs(fadeRate);

            if(fadeRate==0)
                error('Fade rate must be different from 0');
            end

            i = 0;
            periods = [];
            amplitudes = [];
            while (1-fadeRate*i)>0
                amp = (1-fadeRate*i)*initialAmplitude;
                amplitudes = [amplitudes, amp];
                periods = [periods, 2*amp*(1/ascSlope + 1/descSlope)];
                i = i+1;
            end

            yvector = zeros(size(xvector));
            times = [0, cumsum(periods)];
            for i = 1:length(periods)
                indexes = find(xvector>=times(i) & xvector<=times(i+1));
                yvector(indexes) = TriangleWaveGenerator. ...
                                periodicWithSlopes(amplitudes(i),...
                                        ascSlope, descSlope,...
                                        xvector(indexes)-times(i));
            end
        end
        
        function yvector = fadingWithSlopesAndRelax(initialAmplitude,...
                ascSlope, descSlope,...
                fadeRate, xvector)
            ascSlope = abs(ascSlope);
            descSlope = abs(descSlope);
            initialAmplitude = abs(initialAmplitude);
            fadeRate = abs(fadeRate);

            if(fadeRate==0)
                error('Fade rate must be different from 0');
            end

            i = 0;
            periods = [];
            amplitudes = [];
            while (1-fadeRate*i)>0
                amp = (1-fadeRate*i)*initialAmplitude;
                amplitudes = [amplitudes, amp];
                periods = [periods, 2*amp*(1/ascSlope + 1/descSlope)];
                i = i+1;
            end

            yvector = zeros(size(xvector));
            times = [0, cumsum(periods)];
            for i = 1:length(periods)
                indexes = find(xvector>=times(i) & xvector<=times(i+1));
                yvector(indexes) = TriangleWaveGenerator. ...
                                periodicWithSlopes(amplitudes(i),...
                                        ascSlope, descSlope,...
                                        xvector(indexes)-times(i));
            end
        end
        
    end
    
end