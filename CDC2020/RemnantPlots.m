close all
clc

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

baseModel = preisachRelayModel;

idxLeft = cellfun(@(v)v(1),{find(baseModel.inputGrid >= -850)});
idxRight = cellfun(@(v)v(1),{find(baseModel.inputGrid >= 0)});
idxLowerInv = baseModel.gridSize-cellfun(@(v)v(1),{find(baseModel.inputGrid >= 0)})+1;

Gamma2=[];
Gamma1=[];
for i=4:size(baseModel.weightFunc,1)-3
%     Gamma2 = max([Gamma2, sum(baseModel.weightFunc(i,idxLeft:idxRight))*baseModel.relayArea]);
%     Gamma1 = max([Gamma1, sum(baseModel.weightFunc(1:idxLowerInv,i))*baseModel.relayArea]);
    Gamma2 = [Gamma2; sum(mean(baseModel.weightFunc(i-3:i+3,idxLeft:idxRight),1))*baseModel.relayArea];
    Gamma1 = [Gamma1; sum(mean(baseModel.weightFunc(1:idxLowerInv,i-3:i+3),2))*baseModel.relayArea];
end
lambdaMax = 2/max([max(Gamma2),max(Gamma1)]);

baseModel.resetRelaysOff();
baseModel.updateRelays(inputMax);
baseModel.updateRelays(0);
gammaMax = baseModel.getOutput();

baseModel.resetRelaysOn();
baseModel.updateRelays(-800);
baseModel.updateRelays(0);
gammaMin = baseModel.getOutput();

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lineWidth = 1.2;
inputMaxMinFactor = 0.0075;
markerSize = 8;
QLineWidth = 7;
QLinePoints = 200;
iter = 20;

figure
plotHandler = plot(dataHandler.inputSeq, dataHandler.outputSeq,...
    '-b','linewidth',lineWidth); hold on;
xlim([-1500 1500])
ylim([-300 1100])
xticks([-1400 -700 0 700 1400])
yticks([-600 -300 0 300 600 900 1200])
xlabel('$V$','Interpreter','latex')
ylabel('$nm$','Interpreter','latex')

% Plot initial and final points in phase plot
plot(0,baseModel.getOutput(),'or',...
    'LineWidth',lineWidth,...
    'markerSize',markerSize-2)
plot(0,ref,'xr',...
    'LineWidth',lineWidth,...
    'markerSize',markerSize)

for i=1:iter
    plot(inputs(:,i),outputs(:,i),'--b',...
        'LineWidth',lineWidth*0.85);
end

DataPlotter.plotWeightFunc(baseModel.weightFunc, baseModel.inputGrid);
xlabel('$\beta$','Interpreter','latex')
ylabel('$\alpha$','Interpreter','latex')
maxZ = max(max(baseModel.weightFunc));
plotRectangle([0,0;
    -850,0;
    -850,1350;
    0,1350;
    0,0], maxZ, QLinePoints, QLineWidth);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure
subplot(3,1,1)
stem(linspace(0,iter,iter+1), inputAmps(1:iter+1), ...
    '-b', 'LineWidth', lineWidth); hold on;
% xlabel('$k$', 'Interpreter', 'Latex');
ylabel('$w_k$', 'Interpreter', 'Latex');
xlim([0,iter]);
ylim([min(inputAmps)-100, max(inputAmps)+100]);

subplot(3,1,2)
stem(linspace(0,iter,iter+1), remnants(1:iter+1), ...
    '-b', 'LineWidth', lineWidth); hold on;
plot(linspace(0,iter,1000), linspace(ref,ref,1000), ...
    '--k', 'LineWidth', lineWidth);
% xlabel('$k$', 'Interpreter', 'Latex');
ylabel('$\gamma(w_k,I_k)$', 'Interpreter', 'Latex');
xlim([0,iter]);
ylim([min(remnants)-75, max(remnants)+75]);

subplot(3,1,3)
stem(linspace(0,iter,iter+1), errors(1:iter+1), ...
    '-b', 'LineWidth', lineWidth); hold on;
xlabel('$k$', 'Interpreter', 'Latex');
ylabel('$e_k$', 'Interpreter', 'Latex');
xlim([0,iter]);
ylim([min(errors)-75, max(errors)+75]);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

extraIter = 2;
timeVals = [linspace(0,(iter+extraIter),(iter+extraIter)*inputSamples)]';
inputVals = [reshape(inputs(:,1:iter),iter*inputSamples,1);...
    zeros(inputSamples*extraIter,1)];
outputsVals = [reshape(outputs(:,1:iter),iter*inputSamples,1);...
    outputs(end,iter)*ones(inputSamples*extraIter,1)];

figure
subplot(3,1,1)
plot(timeVals, inputVals, '-b', 'LineWidth', lineWidth); hold on;
plot(linspace(0,iter-1,iter)+0.5, inputAmps(1:iter),'or',...
    'LineWidth', lineWidth,...
    'MarkerSize', markerSize-3);
xlabel('$t$', 'Interpreter', 'Latex');
ylabel('$u_\gamma$', 'Interpreter', 'Latex');
xlim([0,iter+extraIter]);
ylim([0, max(inputAmps)+100]);

subplot(3,1,2)
plot(timeVals, outputsVals, '-b', 'LineWidth', lineWidth); hold on;
plot(linspace(0,iter+1,1000), linspace(ref,ref,1000), '--k', ...
    'LineWidth', lineWidth);
plot(linspace(0,iter,iter+1), remnants(1:iter+1),'or',...
    'LineWidth', lineWidth,...
    'MarkerSize', markerSize-3);
xlabel('$t$', 'Interpreter', 'Latex');
ylabel('$\mathcal{P}(u_\gamma,L_0)$', 'Interpreter', 'Latex');
xlim([0,iter+extraIter]);
ylim([min(outputsVals)-75, max(outputsVals)+75]);

% subplot(3,1,3)
% errorConcat = outputsVals-ref;
% plot(linspace(0,iter+1,(iter+1)*inputSamples), errorConcat, ...
%     '-b', 'LineWidth', lineWidth); hold on;
% plot(linspace(0,iter,iter+1), errors(1:iter+1),'or',...
%     'LineWidth', lineWidth,...
%     'MarkerSize', markerSize-3);
% xlabel('$t$', 'Interpreter', 'Latex');
% ylabel('$e$', 'Interpreter', 'Latex');
% xlim([0,iter]);
% ylim([min(errorConcat)-75, max(errorConcat)+75]);

subplot(3,1,3)
stem(linspace(0,iter,iter+1), errors(1:iter+1), 'ob',...
    'MarkerEdgeColor', 'r',...
    'MarkerSize', markerSize-3,...
    'LineWidth', lineWidth); hold on;
xlabel('$k$', 'Interpreter', 'Latex');
ylabel('$e_k$', 'Interpreter', 'Latex');
xlim([0,iter+extraIter]);
ylim([min(errors)-75, max(errors)+75]);