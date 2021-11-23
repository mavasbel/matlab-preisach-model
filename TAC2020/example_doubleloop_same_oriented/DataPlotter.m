classdef DataPlotter < handle
    
    properties (Constant)
        inputLabelTextSize = 18
        inputTickTextSize = 18
        
        outputLabelTextSize = 18
        outputTickTextSize = 18
        
        loopLabelTextSize = 14
        loopTickTextSize = 14
        loopLegendTextSize = 14
        loopAnnTextSize = 14
        
        muLabelTextSize = 14
        muTickTextSize = 14
    end
   
    methods(Static)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function fig = plotInputPeriod(dataHandler)
            fig = figure; 
            hold on; 
            grid off;
            
            dataHandler.circShiftInputMinMax();

            T1=1;
            T2=max([dataHandler.maxInputPeakIdx(1),1]);
            if( ~isempty(dataHandler.minInputPeakIdx) )
                T3=dataHandler.minInputPeakIdx(1);
            else
                T3=dataHandler.sampleLength;
            end
            
            plotHandler1=plot(T1:T2,dataHandler.inputSeq(T1:T2),'b');
            plotHandler2=plot(T2:T3,dataHandler.inputSeq(T2:T3),'g');

            lw=1.3;
            set(plotHandler1,'linewidth',lw);
            set(plotHandler2,'linewidth',lw);
            set(plotHandler1,'color',[0 0 0]);
            set(plotHandler2,'color',[0 0 0]);
            set(plotHandler1,'linestyle','-');
            set(plotHandler2,'linestyle','--');

%             legend({'$u(t)\ |\ t_1 \leq t < t_2$';...
%                     '$u(t)\ |\ t_2 \leq t < t_1+T$'},...
%                     'interpreter','latex');
            xlabel('$t$',...
                'interpreter','latex',...
                'fontsize',DataPlotter.outputLabelTextSize);
            ylabel('$u(t)$','interpreter','latex',...
                'fontsize',DataPlotter.outputLabelTextSize);
%                 'Rotation',0,'Position',[-T3*0.30 0 0]);
            set(gca,'XTick',[T1,T2,T3],...
                'XTickLabel',{'$t_1$','$t_2$','$t_1 + T$'},...
                'TickLabelInterpreter','latex',...
                'fontsize',DataPlotter.outputTickTextSize);
            set(gca,'YTick',[dataHandler.inputMin,dataHandler.inputMax],...
                'YTickLabel',{'$u_{min}$','$u_{max}$'},...
                'TickLabelInterpreter','latex',...
                'fontsize',DataPlotter.outputTickTextSize);
 
            axis([T1-T3*0.2,...
                T3+T3*0.2,...
                dataHandler.inputMin-0.2*dataHandler.inputAmp,...
                dataHandler.inputMax+0.2*dataHandler.inputAmp]);
            
            drawnow;
        end
        
        function fig = plotOutputPeriod(dataHandler)
            fig = figure;
            hold on; 
            grid off;
            
            dataHandler.circShiftInputMinMax();

            T1=1;
            T2=max([dataHandler.maxInputPeakIdx(1),1]);
            if( ~isempty(dataHandler.minInputPeakIdx) )
                T3=dataHandler.minInputPeakIdx(1);
            else
                T3=dataHandler.sampleLength;
            end
            
            plotHandler1=plot(T1:T2,dataHandler.outputSeq(T1:T2),'b');
            plotHandler2=plot(T2:T3,dataHandler.outputSeq(T2:T3),'g');

            lw=1.3;
            set(plotHandler1,'linewidth',lw);
            set(plotHandler2,'linewidth',lw);
            set(plotHandler1,'color',[0 0 0]);
            set(plotHandler2,'color',[0 0 0]);
            set(plotHandler1,'linestyle','-');
            set(plotHandler2,'linestyle','--');

%             legend({'$\mathcal{P}(u,L_0)(t)\ |\ t_1 \leq t < t_2$';...
%                     '$\mathcal{P}(u,L_0)(t)\ |\ t_2 \leq t < t_1+T$'},...
%                     'interpreter','latex');
            xlabel('$t$',...
                'interpreter','latex',...
                'fontsize',DataPlotter.outputLabelTextSize);
            ylabel('$\mathcal{P}(u,L_0)(t)$',...
                'interpreter','latex',...
                'fontsize',DataPlotter.outputLabelTextSize);
%                 'Rotation',0,'Position',[-T3*0.315 0 0]);
            set(gca,'XTick',[T1,T2,T3],...
                'XTickLabel',{'$t_1$','$t_2$','$t_1 + T$'},...
                'TickLabelInterpreter','latex',...
                'fontsize',DataPlotter.outputTickTextSize);
            set(gca,'YTick',[],'YTickLabel',{},...
                'TickLabelInterpreter','latex',...
                'fontsize',DataPlotter.outputTickTextSize);
            
            axis([T1-T3*0.2,...
                T3+T3*0.2,...
                dataHandler.outputMin-0.2*dataHandler.outputAmp,...
                dataHandler.outputMax+0.2*dataHandler.outputAmp]);
            
            drawnow;
        end
        
        function fig = plotLoopPeriod(dataHandler)
            fig = figure;
            hold on; 
            grid off;
            
            dataHandler.circShiftInputMinMax();

            T1=1;
            T2=max([dataHandler.maxInputPeakIdx(1),1]);
            if( ~isempty(dataHandler.minInputPeakIdx) )
                T3=dataHandler.minInputPeakIdx(1);
            else
                T3=dataHandler.sampleLength;
            end
            
            plotHandler1=plot(dataHandler.inputSeq(T1:T2),dataHandler.outputSeq(T1:T2),'b');
            plotHandler2=plot(dataHandler.inputSeq(T2:T3),dataHandler.outputSeq(T2:T3),'g');

            lw=1.3;
            set(plotHandler1,'linewidth',lw);
            set(plotHandler2,'linewidth',lw);
            set(plotHandler1,'color',[0 0 0]);
            set(plotHandler2,'color',[0 0 0]);
            set(plotHandler1,'linestyle','-');
            set(plotHandler2,'linestyle','--');

%             legend({'$\mathcal{P}(u,L_0)(t)\ |\ t_1 \leq t < t_2$';...
%                     '$\mathcal{P}(u,L_0)(t)\ |\ t_2 \leq t < t_1+T$'},'interpreter','latex',...
%                     'fontsize',DataPlotter.loopLegendTextSize);
            xlabel('$u(t)$',...
                'interpreter','latex',...
                'fontsize',DataPlotter.loopLabelTextSize);
            ylabel('$\mathcal{P}(u,L_0)(t)$',...
                'interpreter','latex',...
                'fontsize',DataPlotter.loopLabelTextSize);
%                 'Rotation',0,'Position',[1.125*(dataHandler.inputMin-0.245*dataHandler.inputAmp) 0 0]);
            set(gca,'XTick',[dataHandler.inputMin,dataHandler.inputMax],...
                'XTickLabel',{'$u_{min}$','$u_{max}$'},...
                'TickLabelInterpreter','latex',...
                'fontsize',DataPlotter.loopTickTextSize);
            set(gca,'YTick',[],'YTickLabel',{},...
                'TickLabelInterpreter','latex',...
                'fontsize',DataPlotter.loopTickTextSize);
            
            axis([dataHandler.inputMin-0.2*dataHandler.inputAmp,...
                dataHandler.inputMax+0.2*dataHandler.inputAmp,...
                dataHandler.outputMin-0.2*dataHandler.outputAmp,...
                dataHandler.outputMax+0.2*dataHandler.outputAmp]);
            
            drawnow;
            
            % Add annotation
            midIdx = find(plotHandler1.XData>=dataHandler.inputMin/2,1,'first');
            set(gcf,'Units','normalized');
            [h1xMFig,h1yMFig] = axescoord2figurecoord(plotHandler1.XData(midIdx), plotHandler1.YData(midIdx));
            annotation('textarrow',...
                [h1xMFig+0.20, h1xMFig+0.0025],...
                [h1yMFig-0.05, h1yMFig-0.0025],...
                'String','$t \in [t_1,t_2]$',...
                'interpreter','latex',...
                'fontsize',DataPlotter.loopAnnTextSize);
            drawnow;
            
            midIdx = find(plotHandler2.XData>=dataHandler.inputMax/2,1,'last');
            set(gcf,'Units','normalized');
            [h2xMFig,h2yMFig] = axescoord2figurecoord(plotHandler2.XData(midIdx), plotHandler2.YData(midIdx));
            annotation('textarrow',...
                [h2xMFig-0.20, h2xMFig-0.0025],...
                [h2yMFig+0.05, h2yMFig+0.0025],...
                'String','$t \in [t_2,t_1+T]$',...
                'interpreter','latex',...
                'fontsize',DataPlotter.loopAnnTextSize);
            drawnow;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function fig = plotWeightFunc(weightFunc, inputGrid)  
            fig = figure;
            hold on; 
            grid off;
            
            % Everything outside Preisach domain to NaN
            gridLength = length(inputGrid);
            for i=1:gridLength
                ii = gridLength-i+1; %index inversion for rows
                for j=1:gridLength
                    if( inputGrid(j)>inputGrid(ii) ) 
                        weightFunc(i,j) = NaN;
                    end
                end
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

            [xMesh, yMesh] = meshgrid(inputGrid, fliplr(inputGrid));
            surf(xMesh, yMesh, weightFunc, 'edgecolor', 'none');
            xlim([inputGrid(1) inputGrid(end)]);
            ylim([inputGrid(1) inputGrid(end)]);

            caxis([-stdDevColorFactor*maxStdDev, stdDevColorFactor*maxStdDev]);

            colorbar
            colormap jet
            shading interp
            view([0 90])
            
%             xlabel('$\beta$','fontsize',DataPlotter.labelTextSize,'interpreter','latex');
%             ylabel('$\alpha$','interpreter','latex',...
%                 'fontsize',DataPlotter.labelTextSize,'Rotation',0);
%             set(gca,'XTick',[inputGrid(1) inputGrid(end)],...
%                 'XTickLabel',{'$-\beta_1$','$\beta_1$'},...
%                 'fontsize',DataPlotter.tickTextSize,...
%                 'TickLabelInterpreter','latex');
%             set(gca,'YTick',[inputGrid(1) inputGrid(end)],...
%                 'YTickLabel',{'$-\beta_1$','$\beta_1$'},...
%                 'fontsize',DataPlotter.tickTextSize,...
%                 'TickLabelInterpreter','latex');
            
            xlabel('$\beta$',...
                'interpreter','latex',...
                'fontsize',DataPlotter.muLabelTextSize);
            ylabel('$\alpha$',...
                'interpreter','latex',...
                'fontsize',DataPlotter.muLabelTextSize,...
                'Rotation',0);
            set(gca,'XTick',[inputGrid(1) inputGrid(end)],...
                'XTickLabel',{'$-\beta_1$','$\beta_1$'},...
                'fontsize',DataPlotter.muTickTextSize,...
                'TickLabelInterpreter','latex');
            set(gca,'YTick',[inputGrid(1) inputGrid(end)],...
                'YTickLabel',{'$-\beta_1$','$\beta_1$'},...
                'fontsize',DataPlotter.muTickTextSize,...
                'TickLabelInterpreter','latex');
            set(get(gca,'YLabel'),...
                'Position',get(get(gca,'Ylabel'),'Position')+[-0.065 -0.05 0]);
            
            axis square;
            grid off;
            drawnow;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function fig = plotInput(dataHandler)
            fig = figure;
            hold on; 
            grid off;

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
        
        function fig = plotOutput(dataHandler)
            fig = figure;
            hold on; 
            grid off;
            
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
        
        function fig = plotLoop(dataHandler)
            fig = figure;
            hold on; 
            grid off;
            
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