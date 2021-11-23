close all
clc

totalModels = 6;
baseModel = preisachRelayModel;
inputMin = preisachRelayModel.inputGrid(1);
inputMax = preisachRelayModel.inputGrid(end);
gridSize = preisachRelayModel.gridSize;

preisachArray = [];
for i=1:totalModels
    preisachModel = PreisachRelayModel([inputMin, inputMax], gridSize);
    preisachModel.resetRelaysOff();
    preisachModel.weightFunc = baseModel.weightFunc;
    preisachModel.offset = baseModel.offset;
    preisachArray = [preisachArray; preisachModel];
end
