classdef DataPlotter < handle
    properties
        inputPeriodFig;
        outputPeriodFig;
        loopPeriodFig;
        surfaceFig;
        
        inputFig;
        outputFig;
        loopFig;
    end
        
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function plotInputPeriod(obj, dataHandler)
            if(isempty(obj.inputPeriodFig) || ~ishghandle(obj.inputPeriodFig))
                obj.inputPeriodFig = figure; hold on; grid off;
                fig = obj.inputPeriodFig;
            else
                figure(obj.inputPeriodFig);
            end
            
            dataHandler.circShiftInputMinMax();

            T1=1;
            T2=max([dataHandler.maxInputPeakIdx(1),1]);
            if( ~isempty(dataHandler.minInputPeakIdx) )
                T3=dataHandler.minInputPeakIdx(1);
            else
                T3=dataHandler.sampleLength;
            end
            
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
            set(gca,'XTick',[T1,T2,T3],...
                'XTickLabel',{'T_1','T_2','T_1 + T'},'fontsize',10);
            set(gca,'YTick',[dataHandler.inputMin,dataHandler.inputMax],...
                'YTickLabel',{'u_{min}','u_{max}'},'fontsize',10);
 
            axis([T1-T3*0.2,...
                T3+T3*0.2,...
                dataHandler.inputMin-0.2*dataHandler.inputAmp,...
                dataHandler.inputMax+0.2*dataHandler.inputAmp]);
        end
        
        function plotOutputPeriod(obj, dataHandler)
            if(isempty(obj.outputPeriodFig) || ~ishghandle(obj.outputPeriodFig))
                obj.outputPeriodFig = figure; hold on; grid off;
                fig = obj.outputPeriodFig;
            else
                figure(obj.outputPeriodFig);
            end
            
            dataHandler.circShiftInputMinMax();

            T1=1;
            T2=max([dataHandler.maxInputPeakIdx(1),1]);
            if( ~isempty(dataHandler.minInputPeakIdx) )
                T3=dataHandler.minInputPeakIdx(1);
            else
                T3=dataHandler.sampleLength;
            end
            
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
            set(gca,'XTick',[T1,T2,T3],...
                'XTickLabel',{'T_1','T_2','T_1 + T'},'fontsize',10);
            set(gca,'YTick',[],'YTickLabel',{},'fontsize',10);
            
            axis([T1-T3*0.2,...
                T3+T3*0.2,...
                dataHandler.outputMin-0.2*dataHandler.outputAmp,...
                dataHandler.outputMax+0.2*dataHandler.outputAmp]);
        end
        
        function plotLoopPeriod(obj, dataHandler)
            if(isempty(obj.loopPeriodFig) || ~ishghandle(obj.loopPeriodFig))
                obj.loopPeriodFig = figure; hold on; grid off;
                fig = obj.loopPeriodFig;
            else
                figure(obj.loopPeriodFig);
            end
            
            dataHandler.circShiftInputMinMax();

            T1=1;
            T2=max([dataHandler.maxInputPeakIdx(1),1]);
            if( ~isempty(dataHandler.minInputPeakIdx) )
                T3=dataHandler.minInputPeakIdx(1);
            else
                T3=dataHandler.sampleLength;
            end
            
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
                [1.125*(dataHandler.inputMin-0.2*dataHandler.inputAmp) 0 0]);
            set(gca,'XTick',[dataHandler.inputMin,dataHandler.inputMax],...
                'XTickLabel',{'u_{min}','u_{max}'},'fontsize',10);
            set(gca,'YTick',[],'YTickLabel',{},'fontsize',10);
            
            axis([dataHandler.inputMin-0.2*dataHandler.inputAmp,...
                dataHandler.inputMax+0.2*dataHandler.inputAmp,...
                dataHandler.outputMin-0.2*dataHandler.outputAmp,...
                dataHandler.outputMax+0.2*dataHandler.outputAmp]);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function fig = plotWeightFunc(obj, weightFunc, xyGrid)  
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

            colorbar
            colormap jet
            shading interp
            view([0 90])
            
            axis square;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function plotInput(obj, dataHandler)
            if(isempty(obj.inputFig) || ~ishghandle(obj.inputFig))
                obj.inputFig = figure; hold on; grid off;
                fig = obj.inputFig;
            else
                figure(obj.inputFig);
            end

            T1=1;
            T2=dataHandler.sampleLength/2;
            T3=dataHandler.sampleLength;
            
            plotHandler=plot(dataHandler.indexesSeq,dataHandler.inputSeq,'b');

            lw=1.3;
            set(plotHandler,'linewidth',lw);
            set(plotHandler,'color',[0 0 0]);
            set(plotHandler,'linestyle','-');

            xlabel('t','fontsize',11);
            ylabel('u(t)','fontsize',11,'Rotation',0,'Position',...
                [-dataHandler.sampleLength*0.3 0 0]);
            set(gca,'XTick',[],'XTickLabel',{},'fontsize',10);
            set(gca,'YTick',[dataHandler.inputMin,dataHandler.inputMax],...
                'YTickLabel',{'u_{min}','u_{max}'},'fontsize',10);
 
            axis([-dataHandler.sampleLength*0.2,...
                dataHandler.sampleLength*1.2,...
                dataHandler.inputMin-0.2*dataHandler.inputAmp,...
                dataHandler.inputMax+0.2*dataHandler.inputAmp]);
        end
        
        function plotOutput(obj, dataHandler)
            if(isempty(obj.outputFig) || ~ishghandle(obj.outputFig))
                obj.outputFig = figure; hold on; grid off;
                fig = obj.outputFig;
            else
                figure(obj.outputFig);
            end
            
            plotHandler=plot(dataHandler.indexesSeq,dataHandler.outputSeq,'b');

            lw=1.3;
            set(plotHandler,'linewidth',lw);
            set(plotHandler,'color',[0 0 0]);
            set(plotHandler,'linestyle','-');

            xlabel('t','fontsize',11);
            ylabel('y(t)','fontsize',11,'Rotation',0,'Position',...
                [-dataHandler.sampleLength*0.3 0 0]);
            set(gca,'XTick',[],'XTickLabel',{},'fontsize',10);
            set(gca,'YTick',[],'YTickLabel',{},'fontsize',10);
            
            axis([-dataHandler.sampleLength*0.2,...
                dataHandler.sampleLength*1.2,...
                dataHandler.outputMin-0.2*dataHandler.outputAmp,...
                dataHandler.outputMax+0.2*dataHandler.outputAmp]);
        end
        
        function plotLoop(obj, dataHandler)
            if(isempty(obj.loopFig) || ~ishghandle(obj.loopFig))
                obj.loopFig = figure; hold on; grid off;
                fig = obj.loopFig;
            else
                figure(obj.loopFig);
            end
            
            plotHandler=plot(dataHandler.inputSeq, dataHandler.outputSeq,'b');

            lw=1.3;
            set(plotHandler,'linewidth',lw);
            set(plotHandler,'color',[0 0 0]);
            set(plotHandler,'linestyle','-');
            
            xlabel('u(t)','fontsize',11);
            ylabel('y(t)','fontsize',11,'Rotation',0,'Position',...
                [(dataHandler.inputMin-0.375*dataHandler.inputAmp) 0 0]);
            set(gca,'XTick',[dataHandler.inputMin,dataHandler.inputMax],...
                'XTickLabel',{'u_{min}','u_{max}'},'fontsize',10);
            set(gca,'YTick',[],'YTickLabel',{},'fontsize',10);
            
            axis([dataHandler.inputMin-0.2*dataHandler.inputAmp,...
                dataHandler.inputMax+0.2*dataHandler.inputAmp,...
                dataHandler.outputMin-0.2*dataHandler.outputAmp,...
                dataHandler.outputMax+0.2*dataHandler.outputAmp]);
        end
        
    end
    
end