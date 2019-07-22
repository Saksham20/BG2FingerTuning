% this code extracts all the refernce block data for each session and makes
% a 5d matrix similar to AllData. This will be used to normalize AllData
% and AllData_prereach. 

disp('starting datagen_refblk');
corrsessns=1:numel(sessnames);
trltime_max_refblk=0;

% calculating the max time of ref blk:
for sessns=corrsessns
    strtemp=sessnames{sessns};
    slc_sessn_refblk=LoadSLC(1,['G:\Active Projects\BG2 Data\t8\' strtemp '\Data\Extracted Data']);
    trltime_refblk=size(slc_sessn_refblk.ncTX.values,1);
        if trltime_refblk>trltime_max_refblk
            trltime_max_refblk=trltime_refblk;
        end
end
    
AllData_refblk=NaN*ones(384,trltime_max_refblk,numel(sessnames));
for sessns=corrsessns  
    fprintf('sessno.%d \n',sessns);tic;
    strtemp=sessnames{sessns}; 
    slc_sessn_refblk=LoadSLC(1,['G:\Active Projects\BG2 Data\t8\' strtemp '\Data\Extracted Data']);
    normalid=slc_sessn_refblk.spikePower.values(:,100)>0;normalid=normalid(:);
    allids=logical([normalid ;(zeros(trltime_max_refblk-length(normalid),1))]);
    AllData_refblk(:,allids,sessns)=[slc_sessn_refblk.ncTX.values(normalid,:) slc_sessn_refblk.spikePower.values(normalid,:)]';
end

clearvars slc_sessn_refblk strtemp allids normalid 