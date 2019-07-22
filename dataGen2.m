%% Generating the mega Data Matrix: 
%generating all data from all sessions into a 5d matrix: 
% chans X time X no.trials X blocks X sessions




% -------------------

% AllData=NaN*ones(384,trltime_max,notrials_max,noblks_max,numel(sessnames));  %+1 for the baseline signals  
% AllData_prereach=NaN*ones(384,trltime_max,notrials_max,noblks_max,numel(sessnames));

% AllData_events=cell(notrials_max,noblks_max,numel(sessnames)); % for the 15khz events data gathering 
% AllData_events_prereach=cell(notrials_max,noblks_max,numel(sessnames));

% TaskType= NaN*ones(4,notrials_max,noblks_max,numel(sessnames));
% ReachType= NaN*ones(1,trltime_max,notrials_max,noblks_max,numel(sessnames));% check for middle-reaching trls to discard
% FingerAngData=NaN*ones(4,trltime_max,notrials_max,noblks_max,numel(sessnames));
ControlVec=NaN*ones(4,trltime_max,notrials_max,noblks_max,numel(sessnames));
PosVec=ControlVec; 
PosVecInverted=ControlVec;


disp('starting datagen2');
corrsessns=1:numel(sessnames);

for sessns=corrsessns  
    fprintf('sessno. %d',sessns);tic;
    sessnum=sessnos(sessns);
    blkssnos=OL_blocks_new(1,(OL_blocks_new(2,:)==sessnum));
    strtemp=sessnames{sessns}; 
    slc_sessn=LoadSLC(blkssnos,['G:\Active Projects\BG2 Data\t8\' strtemp '\Data\Extracted Data']);
    P_sessn=slcDataToPFile(slc_sessn);
%     ncTX_all_events=ncTX_events_join(['G:\Active Projects\BG2 Data\t8\' strtemp],blkssnos);

    % loop over blocks and trials
    firstid=0;
    for noblks=1:(length(slc_sessn.blockBreakInds)-1)
        blkbrk=slc_sessn.blockBreakInds(noblks+1);
        lastid=find((P_sessn.trl.reaches(:,2)<blkbrk),1,'last');
        reachesdata=P_sessn.trl.reaches((firstid+1):(lastid),:);
%         pre_reachesdata=P_sessn.trl.delayPeriods((firstid+1):(lastid),:);
        
        for notrials=1:(size(reachesdata,1))
            trltimenow=(reachesdata(notrials,2)-reachesdata(notrials,1))+1;     
            rchstart=reachesdata(notrials,1);
            rchend=reachesdata(notrials,2);
%             pre_trltimenow=(pre_reachesdata(notrials,2)-pre_reachesdata(notrials,1))+1;     
%             pre_rchstart=pre_reachesdata(notrials,1);
%             pre_rchend=pre_reachesdata(notrials,2);
            
%             % 1.1) normal SLC data assignment---
%             AllData(:,1:trltimenow,notrials,noblks,sessns)=...
%                 double(([slc_sessn.ncTX.values(rchstart:rchend,:) ...
%                     slc_sessn.spikePower.values(rchstart:rchend,:)])');

            %1.1.1) ncTX events data assignment--- 
%             AllData_events{notrials,noblks,sessns}=ncTX_all_events(((300*(rchstart-1)+1):(300*rchend)),:);
            
            
%             %1.2.1) pre-reach data assignment---
%             AllData_prereach(:,1:trltimenow_prereach,notrials,noblks,sessns)=...
%                 double(([slc_sessn.ncTX.values(pre_rchstart:pre_rchend,:) ...
%                     slc_sessn.spikePower.values(pre_rchstart:pre_rchend,:)])');
            
            %1.2.2) ncTX events pre-reach data assignment---
%             AllData_events_prereach{notrials,noblks,sessns}=ncTX_all_events(((300*(pre_rchend-1)+1):(300*pre_rchend)),:);   
                
                
                
%             % 2) Angular Data assignment---
%             FingerAngData(:,1:trltimenow,notrials,noblks,sessns)=...
%                 double((slc_sessn.task.auxiliary.values(rchstart:rchend,2:5))');
%             % 3) TaskType Assignment---
%             TaskType(:,notrials,noblks,sessns)=...
%                 sign(sum(diff(FingerAngData(:,1:trltimenow,notrials,noblks,sessns),1,2),2));
            % 4) Control Vector Assignment---
            targetangles=double((slc_sessn.task.auxiliary.values(rchstart:rchend,36:39))');
            TargetAngles=double([40 60 85;40 67.9700 100;-50 -15 25;40 80 110]);
            TargetAnglesdiff=diff(TargetAngles,1,2);
            currangdata=FingerAngData(:,1:trltimenow,notrials,noblks,sessns);
            curtasktyp=logical(abs(TaskType(:,notrials,noblks,sessns)));
            activedofs=find(curtasktyp);
            
            baseangles=TargetAngles(:,2); 
            basenorm=zeros(4,1);
            reachtype=ones(4,1);
            for l=activedofs'             
                if ((targetangles(l,floor(end/2))==TargetAngles(l,1)))                  
                    basenorm(l,1)=TargetAnglesdiff(l,1); % going towards the lower end target 
                    reachtype(l,1)=1;
                elseif ((targetangles(l,floor(end/2))==TargetAngles(l,3)))
                    basenorm(l,1)=TargetAnglesdiff(l,2);% going towards the uppper end target 
                    reachtype(l,1)=1;
                elseif (round(targetangles(l,floor(end/2)))==round(TargetAngles(l,2)))...
                        && ((sum(diff(currangdata(l,:),1,2)))<0)% coming towards center target from high
                    basenorm(l,1)=TargetAnglesdiff(l,2);
                    reachtype(l,1)=0;
                elseif (round(targetangles(l,floor(end/2)))==round(TargetAngles(l,2)))...
                        && ((sum(diff(currangdata(l,:),1,2)))>0)% coming towards center target from low
                    basenorm(l,1)=TargetAnglesdiff(l,1);
                    reachtype(l,1)=0;
                end
            end    
            % ReachType is to 0 if moving towards center, 1 if moving away from center towards the ends            
            ReachType(:,1:trltimenow,notrials,noblks,sessns)=ones(1,trltimenow)*(double(all(reachtype)));
            
            if (all(basenorm'==[0 0 0 0]))
                [notrials noblks sessns]
            end
            currangdatanorm=zeros(size(currangdata));
            currangdatanorm(activedofs,:)=((currangdata(activedofs,:)-baseangles(activedofs,:)))...
                ./( basenorm(activedofs,1));
            targetanglenorm=zeros(size(currangdata));
            targetanglenorm(activedofs,:)=((targetangles(activedofs,:)-baseangles(activedofs,:)))...
                ./( basenorm(activedofs,1));
            
            tempcontvec=(-currangdatanorm+targetanglenorm)... 
                ./sqrt(sum((currangdatanorm-targetanglenorm).^2));
            tempcontvec(isnan(tempcontvec))=0; % there will be NaNs where the target is reached 
            ControlVec(:,1:trltimenow,notrials,noblks,sessns)=tempcontvec;
            PosVec(:,1:trltimenow,notrials,noblks,sessns)=currangdatanorm; 
            PosVecInverted(:,1:trltimenow,notrials,noblks,sessns)=targetanglenorm-currangdatanorm; 
            
        end
        firstid=lastid;
    end
    toc
end
clearvars slc_sessn P_sessn ncTX_all_events tempcontvec targetanglenorm currangdatanorm basenorm reachtype currangdata curtasktyp
disp('done datagen2');

    
    
    
    

