
%this loops over the sessions and blocks to get the SLC from NS5s
% should take like forever .

errorns5toslc=[];
tic;
for t=14
    fprintf('running session %s \n',sessionList{t,1}); 
    blkno=sessionList{t,2};
    %blkno=[1 blkno]; %adding the refblock
    blkno=1;
    for s=blkno
        fprintf('running blkno %d \n',s); 
        
        if s~=1
            try
            ExtractSLCdataFromNs5([sessionDir filesep sessionList{t,1}], s,...
                'featureList', {'ncTX', 'spikePower'}, 'savePath', ...
                [sessionDir filesep sessionList{t,1} filesep 'Data' filesep 'Extracted Data' filesep],...
                'showNS5Alignment', true);
            catch
                warning('could not run %s, block no %d, ns5 data missing',sessionList{t,1},s)
                errorns5toslc=[errorns5toslc;t s];
            end
        else
            try
            ExtractSLCdataFromNs5([sessionDir filesep sessionList{t,1}], s,...
                'featureList', {'ncTX', 'spikePower'}, 'savePath', ...
                [sessionDir filesep sessionList{t,1} filesep 'Data' filesep 'Extracted Data' filesep],...
                'showNS5Alignment', true,'isref',true);
            catch
                warning('could not run %s, block no %d, something wrong with ref block',sessionList{t,1},s)
                errorns5toslc=[errorns5toslc;t s];
            end    
        end
        close all;
    end
end
toc;
