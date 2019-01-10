classdef DataLoader
    methods(Static)
        function fileHandlers = getFileHandlers(lookupPaths, nameInclude, nameExclude)
            fileHandlers = [];
            for folderCounter=1:length(lookupPaths)
                files = [
                    dir(char(strcat(lookupPaths(folderCounter),'\*.csv')));
                    dir(char(strcat(lookupPaths(folderCounter),'\*.dat')))
                    ];
                for fileCounter=1:length(files)
                    fullFilePath = strcat(files(fileCounter).folder, '\', files(fileCounter).name);
                    [filePath, fileName, ext] = fileparts(fullFilePath);

                    if(nargin>=2 && exist('nameInclude', 'var') && ~isempty(nameInclude))
                        index = regexp(fullFilePath, nameInclude, 'once');
                        if( isempty(index) ) 
                            continue
                        end
                    end

                    if(nargin>=3 && exist('nameExclude', 'var') && ~isempty(nameExclude))
                        index = regexp(fullFilePath, nameExclude, 'once');
                        if( ~isempty(index) ) 
                            continue
                        end
                    end

                    fileHandlers = [fileHandlers; FileHandler(fullFilePath)];
                 end
            end
        end
    end
end