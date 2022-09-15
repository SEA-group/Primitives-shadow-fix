% version 2022.09.12.a

function [isModified, primCodeModified] = PrimitivesReader_Mk5_SE(fileName)
       
    %% open file and read in bytes

    primFile = fopen(fileName, 'r');
    primCode = fread(primFile);
    primCodeLength = length(primCode);

    fclose(primFile);
    clear primFile;
    
    %% prepare output
    
    primCodeModified = primCode;
    isModified = 0;

    %% read sectionName part

    sectionNamesSectionLength = primCode(primCodeLength) * 256^3 + primCode(primCodeLength - 1) * 256^2 + primCode(primCodeLength - 2) * 256 + primCode(primCodeLength - 3);
    sectionNamesSectionStart = primCodeLength - 4 - sectionNamesSectionLength + 1;
    sectionNamesSectionEnd = primCodeLength - 4;

    cursor = sectionNamesSectionStart;
    sectionCount = 0;

    while cursor < sectionNamesSectionEnd

        sectionCount=sectionCount+1;

        % get the length of the coresponding section
        sectionSize(sectionCount) = primCode(cursor + 3) * 256^3 + primCode(cursor + 2) * 256^2 + primCode(cursor +1) * 256 + primCode(cursor);

        % get the length of the section's name
        cursor = cursor + 4 + 16;
        currentSectionNameLength = primCode(cursor + 3) * 256^3 + primCode(cursor + 2) * 256^2 + primCode(cursor +1) * 256 + primCode(cursor);
        currentSectionNameLength = 4 * ceil(currentSectionNameLength/4);

        % get the section's name
        cursor = cursor + 4;
        sectionName{sectionCount} = native2unicode(primCode(cursor: cursor+currentSectionNameLength-1)');

        % get the section type
        sectionClass{sectionCount} = sectionName{sectionCount}((strfind(sectionName{sectionCount}, '.')+1): end);

        cursor = cursor + currentSectionNameLength;

    end

    % the following lines are not necessary, but I prefer vertical arrays :)
    sectionSize = sectionSize';
    sectionClass = sectionClass';

    clear cursor sectionCount currentSectionNameLength sectionName;

    %% read sections

    cursor = 5;

    for indSect = 1: length(sectionSize)

        if length(sectionClass{indSect}) >7 && strcmp(sectionClass{indSect}(1: 8), 'vertices')

            data_type = primCode(cursor: cursor+63);
            data_count = primCode(cursor + 67) * 256^3 + primCode(cursor + 66) * 256^2 + primCode(cursor + 65) * 256 + primCode(cursor + 64);

            data_vertices_r = [];

            if isequal(data_type(1: 7), [120 121 122 110 117 118 114]')   % if the type is xyznuvr (wire model)
                
                for indVert=1: data_count
                    % radius
                    data_vertices_r(indVert) = typecast(uint8([primCode(cursor+68+(indVert-1)*36+32), primCode(cursor+68+(indVert-1)*36+33), primCode(cursor+68+(indVert-1)*36+34), primCode(cursor+68+(indVert-1)*36+35)]), 'single');
                end
                
                if abs(max(data_vertices_r)-0.9991)<0.001 && abs(min(data_vertices_r)-0.9991)<0.001
                    isModified = 1;
                    for indVert = 1: data_count
                        primCodeModified( cursor+68+(indVert-1)*36+32 : cursor+68+(indVert-1)*36+35 ) = typecast(single(0.002), 'uint8');
                    end
                end
      
            end

            clear indVert...
                data_vertices_r...
                data_type...
                data_count;

        end

        cursor = cursor + 4 * ceil(sectionSize(indSect)/4);

    end

end

