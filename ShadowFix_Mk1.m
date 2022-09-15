% A script for fixing the shadow issue due to large wire radius
% requires PrimitivesReader_Mk5_SE.m

clc
clear
% close all;

primitivesList = dir('**/*.primitives');
backup = 1;     % change to 0 if don't want to keep original primitives

for indFile = 1: size(primitivesList, 1)
    
    % get filename with complete path
    currentFileName = [primitivesList(indFile).folder, '\', primitivesList(indFile).name];
    
    % feed the file for processing
    [isModified, primCodeModified] = PrimitivesReader_Mk5_SE(currentFileName);
    
    % save the fixed version
    if isModified
        if backup
            copyfile(currentFileName, [currentFileName, 'bak']);
            currentFile = fopen(currentFileName, 'w');
            fwrite(currentFile, primCodeModified);
            fclose(currentFile);
            disp([currentFileName, ' is fixed and backed up']);
        else
            currentFile = fopen(currentFileName, 'w');
            fwrite(currentFile, primCodeModified);
            fclose(currentFile);
            disp([currentFileName, ' is fixed and overwritten']);
        end     
    end

end

% fclose all;
disp('Shadow fix process finished. Please proceed to primitives2geometry conversion.');