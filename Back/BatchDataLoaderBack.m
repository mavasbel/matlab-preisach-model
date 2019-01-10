% clear all
close all
clc

% Batch flag
isBatch = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Paths to look for files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lookupPaths = [
"G:\My Drive\MATLAB\Hysteresis\PNZT loops_dif_concentrations\PNZT loops_dif_concentrations\PNZT_x0.47_mix";
"G:\My Drive\MATLAB\Hysteresis\PNZT loops_dif_concentrations\PNZT loops_dif_concentrations\PNZT_x0.48_mix";
"G:\My Drive\MATLAB\Hysteresis\PNZT loops_dif_concentrations\PNZT loops_dif_concentrations\PNZT_x0.465_mix";
"G:\My Drive\MATLAB\Hysteresis\PNZT loops_dif_concentrations\PNZT loops_dif_concentrations\PNZT_x0.475_mix";
% "G:\My Drive\MATLAB\Hysteresis\Grain Multi-Size Fitting\PNZT_loops_difGrainSize\IX";
% "G:\My Drive\MATLAB\Hysteresis\Grain Multi-Size Fitting\PNZT_loops_difGrainSize\VI";
% "G:\My Drive\MATLAB\Hysteresis\Grain Multi-Size Fitting\PNZT_loops_difGrainSize\VIII";
% "G:\My Drive\MATLAB\Hysteresis\Grain Multi-Size Fitting\PNZT_loops_difGrainSize\XIII";
% "G:\My Drive\MATLAB\Hysteresis\Grain Multi-Size Fitting\PNZT_loops_difGrainSize\XIV";
];

% Regex to match files by name
% nameFilter = 'PNZT_x0.47_mix_S1_1Hz_1800V';
% nameFilter = 'PNZT_x0.47_difV_S3_1Hz_1800V';
% nameFilter = 'PNZT_x0.465_mix_S3_1Hz_1200V';
% nameFilter = 'PNZT_x0.465_difV_S3_1Hz_1600V';
% nameFilter = 'PNZT_x0.465_x3_S3_1Hz_1400V';
% nameFilter = 'PNZT_.*_difV_.*';
% nameFilter = '.*_x3_.*';

% nameFilter = 'PNZT_x0.48_mix_S3_1Hz_1700V';
% nameFilter = 'PNZT_x0.48_mix_S3_x3_1Hz_1600V';
% nameFilter = 'PNZT_x0.48_mix_S3_x3_1Hz_.*';
% nameFilter = 'PNZT_x0.48_mix_S3_difV_1Hz_*';

% nameFilter = 'PNZT_x0.47_x3_S3_1Hz_1400V';
% nameFilter = 'PNZT_x0.47_x3_S3_1Hz_.*';
% nameFilter = 'PNZT_x0.47_difV_S3_1Hz_*';

% nameFilter = 'PNZT_x0.465_mix_S3_1Hz_1600V';
nameFilter = 'PNZT_x0.465_x3_S3_1Hz_1400V';
% nameFilter = 'PNZT_x0.465_x3_S3_1Hz_.*';
% nameFilter = 'PNZT_x0.465_.*_S3_1Hz_.*';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Seqs generation and plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for folderCounter=1:length(lookupPaths)
    files = [
        dir(char(strcat(lookupPaths(folderCounter),'\*.csv')));
        dir(char(strcat(lookupPaths(folderCounter),'\*.dat')))
        ];
    for fileCounter=1:length(files)
        fullFilePath = strcat(files(fileCounter).folder, '\', files(fileCounter).name);
        [filePath, fileName, ext] = fileparts(fullFilePath);
        
        if(exist('nameFilter', 'var'))
            index = regexp(fileName, nameFilter);
            if( isempty(index) ) 
                continue
            end
        end
        
        disp('--Batch parameters--')
        disp(strcat('Folder: ', filePath))
        disp(strcat('File: ', fileName))
        disp(strcat('Counters: folderCounter=',num2str(folderCounter),', fileCounter=',num2str(fileCounter)))
        
        if(ext == '.csv')
            [header, matrix] = readCSV(fullFilePath);
        end
        if(ext == '.dat')
            [header, matrix] = readDat(fullFilePath);
        end
        
        [time, origInputSeq, origOutputSeq] = getInputOutput(header, matrix);
        
        %Run fitting
        run(".\PreisachRelayFit.m");
%         run(".\PreisachMinorLoop.m");

        %Save figures
        saveas(preisachPlots.loopPlaneFig  , strcat(cd, "\Fitting results\LoopPlane-"  , fileName, ".png") );
        saveas(preisachPlots.inputOutputFig, strcat(cd, "\Fitting results\InputOutput-", fileName, ".png") );
     end
end

% Batch flag
isBatch = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [header, matrix] = readCSV(fileFullPath)
    [~, ~, alldata] = xlsread(fileFullPath);

    header = string(strsplit(char(alldata(1,:)),','));
    
    columns = size(header,2);
    rows = size(alldata,1) - 1;
    
    matrix = zeros(rows,columns);
    for k=1:rows
        matrix(k,:) = str2double(strsplit(char(alldata(k+1)),','));
    end
end

function [header, matrix] = readDat(fileFullPath)
    data = importdata(fileFullPath);
    
    if isfield(data,'colheaders')
        %If data is already formatted
        header = string(data.colheaders);
        matrix = double(data.data(:,:));
    else
        %If data is not formatted
        %Determine first row with data
        offset = -1;
        k = 0;
        while(offset == -1)
            nanvec = isnan(str2double(strsplit(strrep(char(data(k+1)),',','.'),'\t')));
            if(nanvec(1) == 0)
                offset = k;
            else
                k = k+1;
            end
        end

        %Create zeros matrix
        rows = size(data,1) - offset;
        columns = size(strsplit(char(data(offset+1)),'\t'),2);
        matrix = zeros(rows,columns);
    
        %Data header
        header = string(strsplit(strrep(char(data(offset)),',','.'),'\t'));

        %Convert each row to doubles
        for k=1:rows
            matrix(k,:) = str2double(strsplit(strrep(char(data(k+offset)),',','.'),'\t'));
        end
    end
end

function [time, voltage, strain] = getInputOutput(header, matrix)
    time = getColumnMatchingHeader(header, matrix, '.*(Time).*');
    strain = getColumnMatchingHeader(header, matrix, '.*(D1).*');
    vp = getColumnMatchingHeader(header, matrix, '.*(V\+).*');
    vn = getColumnMatchingHeader(header, matrix, '.*(V\-).*');
    voltage = (vp + vn)/2 + (vp - vn)/2;
end

function [column] = getColumnMatchingHeader(header, matrix, toMatch)
    column = zeros(size(matrix,1), 1);
    for i=1:length(header)
        index = regexp(header(i), toMatch);
        if(index > 0)
            column = matrix(:,i);
            break;
        end
    end
end