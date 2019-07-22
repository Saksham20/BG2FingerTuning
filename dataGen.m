
% max finding script.  
load('OL_blocks_new.mat','OL_blocks_new');
global sessnos noblks_max notrials_max trltime_max pretrltime_max OL_blocks_new sessionList sessnames 
[~,sessnames]=xlsread(...
    'G:\Personal Folders\Sharda, Saksham\codes\Auxiliary Header Variable Mapping (packets saved to slc).xlsx',3,'B2:Q2');
sessnames([1,3])=[];

sessnames=cellfun(@(x) (x([2:end-1])), sessnames,'UniformOutput',false);
load('G:\Personal Folders\Sharda, Saksham\codes2.0\MATfiles\OL_blocks_new.mat');
sessnos=unique(OL_blocks_new(2,:));

sessionList=cell(numel(sessnames),3);
for p=1:numel(sessnames)
    sessionList{p,1}=sessnames{p};
    sessionList{p,2}=OL_blocks_new(1,OL_blocks_new(2,:)==sessnos(p));
    sessionList{p,3}='t8';
end

%% finding the max for each of trials times, number of trials, no blocks across each sessions 
trltime_max=0;notrials_max=0;noblks_max=0;pretrltime_max=0;
for sessns=1:numel(sessnames)
    sessnum=sessnos(sessns);
    blkssnos=OL_blocks_new(1,(OL_blocks_new(2,:)==sessnum));
    if numel(blkssnos)>noblks_max
       noblks_max=numel(blkssnos);
    end
    
    strtemp=sessnames{sessns}; 
    slc_sessn=LoadSLC(blkssnos,['G:\Active Projects\BG2 Data\t8\' strtemp]);
    P_sessn=slcDataToPFile(slc_sessn);
    
    temp=0;
    for u=1:numel(blkssnos)
        blkbrk=slc_sessn.blockBreakInds(u+1);
        mxtrl=find((P_sessn.trl.reaches(:,2)<blkbrk),1,'last');
        mxtrl1=mxtrl-temp;
        if mxtrl1>notrials_max
           notrials_max=mxtrl1;
        end
        temp=mxtrl;
    end
      
    trltime=(max(diff(P_sessn.trl.reaches,1,2)))+1;
    if trltime>trltime_max
        trltime_max=trltime;
    end
    
    trltime=(max(diff(P_sessn.trl.delayPeriods,1,2)))+1;
    if trltime>pretrltime_max
        pretrltime_max=trltime;
    end
    
    
end
   
clearvars -except sessnos noblks_max notrials_max trltime_max pretrltime_max OL_blocks_new sessionList sessnames

load('ALLDatanew.mat', 'AllData')
load('ALLDatanew.mat', 'AllData_prereach')
load('ALLDatanew.mat', 'TaskType')
load('ALLDatanew.mat', 'ReachType')
load('ALLDatanew.mat', 'FingerAngData')
load('ALLDatanew.mat', 'ReachType')
load('ALLDatanew.mat', 'PosVecInverted')
load('ALLDatanew2.mat' ,'AllData_refblk') 