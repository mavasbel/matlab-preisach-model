classdef PreisachPlots < handle
    properties
        inputOutputFig
        inputSubFig
        inputSubFigLeg = string([])
        outputSubFig
        outputSubFigLeg = string([])
        
        loopPlaneFig
        loopSubFig
        loopSubFigLeg = string([]);
        planeSubFig
        
        loopFig
        loopFigLeg = string([]);
        
        surfaceFig;
        
        inputPaperFig;
        outputPaperFig;
        phasePaperFig;
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function fig = getOrCreateInputOutputFig(obj)
            if(isempty(obj.inputOutputFig) || ~ishghandle(obj.inputOutputFig))
                obj.inputOutputFig = figure;
                currentPos = get(obj.inputOutputFig, 'Position');
                set(obj.inputOutputFig, 'Position', currentPos.*[1 1 2 1] + [-currentPos(3)/2 0 0 0] );
                fig = obj.inputOutputFig;
            else
                fig = figure(obj.inputOutputFig);
            end
        end
        
        function fig = plotInputSubFig(obj, xData, yData, dataLegend, dataColor)
            obj.getOrCreateInputOutputFig();
            
            if(isempty(obj.inputSubFig))
                obj.inputSubFig = subplot(1,2,1); hold on; grid on;
                currentPos = get(obj.inputSubFig, 'Position');
                set(obj.inputSubFig, 'Position', currentPos.*[0.9 1 1 1] + [0 0 0 0] );
            else
                set(obj.inputSubFig, 'nextplot', 'add');
                axes(obj.inputSubFig);
            end
            fig = obj.inputSubFig;
            
            if(nargin>=4 && exist('dataColor', 'var') && ~isempty(dataColor))
                plot(xData, yData, dataColor);
            else
                plot(xData, yData);
            end
            
            obj.inputSubFigLeg = [obj.inputSubFigLeg, string(dataLegend)];
            leg = legend(obj.inputSubFigLeg);
            set(leg, 'Interpreter', 'none');
        end
        
        function fig = plotOutputSubFig(obj, xData, yData, dataLegend, dataColor)
            obj.getOrCreateInputOutputFig();
            
            if(isempty(obj.outputSubFig))
                obj.outputSubFig = subplot(1,2,2); hold on; grid on;
                currentPos = get(obj.outputSubFig, 'Position');
                set(obj.outputSubFig, 'Position', currentPos.*[1.0 1 1 1] + [0 0 0 0] );
            else
                set(obj.outputSubFig, 'nextplot', 'add');
                axes(obj.outputSubFig);
            end
            fig = obj.outputSubFig;
            
            if(nargin>=4 && exist('dataColor', 'var') && ~isempty(dataColor))
                plot(xData, yData, dataColor);
            else
                plot(xData, yData);
            end
            
            obj.outputSubFigLeg = [obj.outputSubFigLeg, string(dataLegend)];
            leg = legend(obj.outputSubFigLeg);
            set(leg, 'Interpreter', 'none');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function fig = getOrCreateLoopPlaneFig(obj)
            if(isempty(obj.loopPlaneFig) || ~ishghandle(obj.loopPlaneFig))
                obj.loopPlaneFig = figure;
                currentPos = get(obj.loopPlaneFig, 'Position');
                set(obj.loopPlaneFig, 'Position', currentPos.*[1 1 2 1] + [-currentPos(3)/2 0 0 0] );
                fig = obj.loopPlaneFig;
            else
                fig = figure(obj.loopPlaneFig);
            end
        end
        
        function fig = plotLoopSubFig(obj, xData, yData, dataLegend, dataColor)
            obj.getOrCreateLoopPlaneFig();
            
            if(isempty(obj.loopSubFig))
                obj.loopSubFig = subplot(1,2,1); hold on; grid on;
                currentPos = get(obj.loopSubFig, 'Position');
                set(obj.loopSubFig, 'Position', currentPos.*[0.85 1 1 1] + [0 0 0 0] );
            else
                set(obj.loopSubFig, 'nextplot', 'add');
                axes(obj.loopSubFig);
            end
            fig = obj.loopSubFig;
            
            if(exist('dataColor', 'var'))
                plot(xData, yData, dataColor);
            else
                plot(xData, yData);
            end
            
            obj.loopSubFigLeg = [obj.loopSubFigLeg, string(dataLegend)];
            leg = legend(obj.loopSubFigLeg);
            set(leg, 'Interpreter', 'none');
        end
        
        function fig = plotSurfaceSubFig(obj, weightFunc, xyGrid)  
            obj.getOrCreateLoopPlaneFig();
            
            if(isempty(obj.planeSubFig))
                obj.planeSubFig = subplot(1,2,2); hold on; grid on;
                currentPos = get(obj.planeSubFig, 'Position');
                set(obj.planeSubFig, 'Position', currentPos.*[0.95 1 1 1] + [0 0 0 0] );
                fig = obj.planeSubFig;
            else
                obj.planeSubFig = subplot(1,2,2); hold on; grid on;
                fig = obj.planeSubFig;
            end
            
            stdDevColorFactor = 2.2;    
            avgColorFactor = 3.5;

            posMu = max(weightFunc,0);
            posNnz = nnz(posMu);
            posAvg = sum(sum(posMu))/posNnz;
            posOnes = spones(posMu);
            posStdDev = sqrt(sum(sum( (posMu - posAvg.*posOnes).^2 ))/posNnz);  
            negMu = min(weightFunc,0);
            negNnz = nnz(negMu);
            negAvg = sum(sum(negMu))/negNnz;
            negOnes = spones(negMu);
            negStdDev = sqrt(sum(sum( (negMu - negAvg.*negOnes).^2 ))/negNnz);

            maxStdDev = nanmax([posStdDev, negStdDev]);
            maxAvg = nanmax([abs(posAvg), abs(negAvg)]);

            [xMesh, yMesh] = meshgrid(xyGrid, fliplr(xyGrid));
            surf(xMesh, yMesh, weightFunc, 'edgecolor', 'none')

            caxis([-stdDevColorFactor*maxStdDev, stdDevColorFactor*maxStdDev]);
        %     zlim([-stdDevColorFactor*maxStdDev, stdDevColorFactor*maxStdDev]);
        %     caxis([-avgColorFactor*maxAvg, avgColorFactor*maxAvg]);
        %     zlim([-avgColorFactor*maxAvg, avgColorFactor*maxAvg]);

            colorbar
            colormap jet
            shading interp
            view([0 90])
            
            axis square;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function fig = plotLoopFig(obj, xData, yData, dataLegend, dataColor)            
            if(isempty(obj.loopFig) || ~ishghandle(obj.loopFig))
                obj.loopFig = figure; hold on; grid on;
                fig = obj.loopFig;
            else
                figure(obj.loopFig);
            end
            if(nargin>=4 && exist('dataColor', 'var') && ~isempty(dataColor))
                plot(xData, yData, dataColor);
            else
                plot(xData, yData);
            end
            
            obj.loopFigLeg = [obj.loopFigLeg, string(dataLegend)];
            leg = legend(obj.loopFigLeg);
            set(leg, 'Interpreter', 'none');
        end
        
        function fig = plotSurfaceFig(obj, weightFunc, xyGrid)  
            if(isempty(obj.surfaceFig) || ~ishghandle(obj.surfaceFig))
                obj.surfaceFig = figure; hold on; grid on;
                fig = obj.surfaceFig;
            else
                figure(obj.surfaceFig);
            end
            
            stdDevColorFactor = 2.2;    
            avgColorFactor = 3.5;

            posMu = max(weightFunc,0);
            posNnz = nnz(posMu);
            posAvg = sum(sum(posMu))/posNnz;
            posOnes = spones(posMu);
            posStdDev = sqrt(sum(sum( (posMu - posAvg.*posOnes).^2 ))/posNnz);  
            negMu = min(weightFunc,0);
            negNnz = nnz(negMu);
            negAvg = sum(sum(negMu))/negNnz;
            negOnes = spones(negMu);
            negStdDev = sqrt(sum(sum( (negMu - negAvg.*negOnes).^2 ))/negNnz);

            maxStdDev = nanmax([posStdDev, negStdDev]);
            maxAvg = nanmax([abs(posAvg), abs(negAvg)]);

            [xMesh, yMesh] = meshgrid(xyGrid, fliplr(xyGrid));
            surf(xMesh, yMesh, weightFunc, 'edgecolor', 'none');
            xlim([xyGrid(1) xyGrid(end)]);
            ylim([xyGrid(1) xyGrid(end)]);

            caxis([-stdDevColorFactor*maxStdDev, stdDevColorFactor*maxStdDev]);
        %     zlim([-stdDevColorFactor*maxStdDev, stdDevColorFactor*maxStdDev]);
        %     caxis([-avgColorFactor*maxAvg, avgColorFactor*maxAvg]);
        %     zlim([-avgColorFactor*maxAvg, avgColorFactor*maxAvg]);

            colorbar
            colormap jet
            shading interp
            view([0 90])
            
            axis square;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function plotInputPaper(obj, dataHandler)
            if(isempty(obj.inputPaperFig) || ~ishghandle(obj.inputPaperFig))
                obj.inputPaperFig = figure; hold on; grid off;
                fig = obj.inputPaperFig;
            else
                figure(obj.inputPaperFig);
            end
            
            dataHandler.circShiftInputMinMax();
            inputRange = dataHandler.inputMax - dataHandler.inputMin;
            outputRange = dataHandler.outputMax - dataHandler.outputMin;

            T1=1;
            T2=dataHandler.maxInputPeakIdx(1);
            T3=dataHandler.sampleLength;
            
            p1=plot(T1:T2,dataHandler.inputSeq(T1:T2),'b');
            p2=plot(T2:T3,dataHandler.inputSeq(T2:T3),'g');

            lw=1.3;
            set(p1,'linewidth',lw);
            set(p2,'linewidth',lw);
            set(p1,'color',[0 0 0]);
            set(p2,'color',[0 0 0]);
            set(p1,'linestyle','-');
            set(p2,'linestyle','--');

            legend('u(t) | T_1 \leq t < T_2','u(t) | T_2 \leq t < T_3');
            xlabel('t','fontsize',11);
            ylabel('u(t)','fontsize',11,'Rotation',0,'Position',[-T3*0.30 0 0]);
            set(gca,'XTick',[T1,T2,T3],'XTickLabel',{'T_1','T_2','T_1 + T'},'fontsize',10);
            set(gca,'YTick',[dataHandler.inputMin,dataHandler.inputMax],...
                'YTickLabel',{'u_{min}','u_{max}'},'fontsize',10);
 
            axis([T1-T3*0.2,T3+T3*0.2,...
                dataHandler.inputMin-0*inputRange,dataHandler.inputMax+0.1*inputRange]);
        end
        
        function plotOutputPaper(obj, dataHandler)
            if(isempty(obj.outputPaperFig) || ~ishghandle(obj.outputPaperFig))
                obj.outputPaperFig = figure; hold on; grid off;
                fig = obj.outputPaperFig;
            else
                figure(obj.outputPaperFig);
            end
            
            dataHandler.circShiftInputMinMax();
            inputRange = dataHandler.inputMax - dataHandler.inputMin;
            outputRange = dataHandler.outputMax - dataHandler.outputMin;

            T1=1;
            T2=dataHandler.maxInputPeakIdx(1);
            T3=dataHandler.sampleLength;
            
            p1=plot(T1:T2,dataHandler.outputSeq(T1:T2),'b');
            p2=plot(T2:T3,dataHandler.outputSeq(T2:T3),'g');

            lw=1.3;
            set(p1,'linewidth',lw);
            set(p2,'linewidth',lw);
            set(p1,'color',[0 0 0]);
            set(p2,'color',[0 0 0]);
            set(p1,'linestyle','-');
            set(p2,'linestyle','--');

            legend('\Phi(t) | T_1 \leq t < T_2','\Phi(t) | T_2 \leq t < T_3');
            xlabel('t','fontsize',11);
            ylabel('\Phi(t)','fontsize',11,'Rotation',0,'Position',[-T3*0.30 0 0]);
            set(gca,'XTick',[T1,T2,T3],'XTickLabel',{'T_1','T_2','T_1 + T'},'fontsize',10);
            set(gca,'YTick',[],'YTickLabel',{},'fontsize',10);
            
            axis([T1-T3*0.2,T3+T3*0.2,...
                dataHandler.outputMin-0.1*outputRange,dataHandler.outputMax+0.1*outputRange]);
        end
        
        function plotPhasePaper(obj, dataHandler)
            if(isempty(obj.phasePaperFig) || ~ishghandle(obj.phasePaperFig))
                obj.phasePaperFig = figure; hold on; grid off;
                fig = obj.phasePaperFig;
            else
                figure(obj.phasePaperFig);
            end
            
            dataHandler.circShiftInputMinMax();
            inputRange = dataHandler.inputMax - dataHandler.inputMin;
            outputRange = dataHandler.outputMax - dataHandler.outputMin;

            T1=1;
            T2=dataHandler.maxInputPeakIdx(1);
            T3=dataHandler.sampleLength;
            
            p1=plot(dataHandler.inputSeq(T1:T2),dataHandler.outputSeq(T1:T2),'b');
            p2=plot(dataHandler.inputSeq(T2:T3),dataHandler.outputSeq(T2:T3),'g');

            lw=1.3;
            set(p1,'linewidth',lw);
            set(p2,'linewidth',lw);
            set(p1,'color',[0 0 0]);
            set(p2,'color',[0 0 0]);
            set(p1,'linestyle','-');
            set(p2,'linestyle','--');

            
            legend('\Phi(t) | T_1 \leq t < T_2','\Phi(t) | T_2 \leq t < T_3');
            xlabel('u(t)','fontsize',11);
            ylabel('\Phi(t)','fontsize',11,'Rotation',0,'Position',...
                [1.125*(dataHandler.inputMin-0.1*inputRange) 0 0]);
            set(gca,'XTick',[dataHandler.inputMin,dataHandler.inputMax],...
                'XTickLabel',{'u_{min}','u_{max}'},'fontsize',10);
            set(gca,'YTick',[],'YTickLabel',{},'fontsize',10);
            
            axis([dataHandler.inputMin-0.1*inputRange,dataHandler.inputMax+0.1*inputRange,...
                dataHandler.outputMin-0.1*outputRange,dataHandler.outputMax+0.1*outputRange]);
        end
        
    end
end