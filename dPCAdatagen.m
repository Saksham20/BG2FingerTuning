
% firingRates: N x S x D x T x maxTrialNum
%N: number of channels. 
% here S: is the first stimulus (flex/ext): 
%D: second stimulus: finger/dof movement.  
%T: time, third 'stimulus parameter'

%% Picking individual movement trials for each block and session
function [AllData_indi1,trialNum]=dPCAdatagen(AllData_blknorm,TaskType,sesnumbers_tot,pre_flag)
global noblks_max notrials_max trltime_max pretrltime_max 
nctx_flag=false; 
if numel(sesnumbers_tot)==1
    max_trialsno=80;% change to 400 if taking all sessions for the tasks into account
else
    max_trialsno=400;
end

disp('starting');
if ~nctx_flag
    PosVec_indi1=NaN*ones(1,4,2,trltime_max,max_trialsno);
    %PosVec1=PosVecInverted; %FingerAngData OR PosVecInverted
    ReachType_indi1=NaN*ones(1,4,2,trltime_max,max_trialsno);
    %ReachType1=ReachType;
    if pre_flag % !!IMP: in this case, comment out the assignments for PosVec and ReachType 
       AllData_indi1=NaN*ones(384,4,2,pretrltime_max,max_trialsno);FingerAngData_indi=[];indi_ids1=[];
       AllData_lag1=AllData_blknorm; %updated: the argument input will reflect pre or not_blknorm
       trltime_max1=pretrltime_max;
    else
        AllData_indi1=NaN*ones(384,4,2,trltime_max,max_trialsno);FingerAngData_indi=[];indi_ids1=[];
        AllData_lag1=AllData_blknorm; indi_ids1=[];% AllData_lag  OR AllData_blknorm 
        trltime_max1=trltime_max;
    end
        
else 
    AllData_indi_ncTX=cell(4,2,max_trialsno);AllData_indi_ncTX_prereach=cell(4,2,max_trialsno);indi_ids1=[];
    AllData_events1=AllData_events; %  AllData_events OR AllData_events_prereach 
end
trialNum=zeros(2,4);
sessnow=1:numel(sesnumbers_tot);
    for l=sessnow
        fprintf('\n starting sess %d \n',l);
        for k=1:noblks_max
            fprintf('.');
            for j=1:notrials_max 
                task=sum(abs(TaskType(:,j,k,l)),1);
                
                if task==1
                    task1=TaskType(:,j,k,l);                
                    [place,~,val]=find(task1);
                    val=0.5*val+1.5;% to map val from -1 as 1 and 1 as 2. 
                        
                    if ~nctx_flag
                        maxtimenow=find(isnan(AllData_lag1(1,:,j,k,l)));
                        if isempty(maxtimenow)
                           maxtimenow=trltime_max1+1;
                        end
                        data1=zeros(384,trltime_max1);
                        data2=zeros(1,trltime_max1);                        
                        querypoints=linspace(1,(maxtimenow(1)-1),trltime_max1);
                        for u=1:384
                            data1(u,:)=interp1([1:(maxtimenow(1)-1)],...
                                AllData_lag1(u,[1:(maxtimenow(1)-1)],j,k,l),querypoints);
                        end 
%                         data2=interp1([1:(maxtimenow(1)-1)],...
%                                 abs(PosVec1(place,[1:(maxtimenow(1)-1)],j,k,l)),querypoints);
%                         data3=interp1([1:(maxtimenow(1)-1)],...
%                                 (ReachType1(1,[1:(maxtimenow(1)-1)],j,k,l)),querypoints);
                        m=1;
                        while ~(all(isnan(AllData_indi1(:,place,val,:,m))))
                            m=m+1;
                        end    
                        trialNum(val,place)=m;
%                         PosVec_indi1(:,place,val,:,m)=reshape(data2,size(data2,1),1,1,size(data2,2),1);
%                         ReachType_indi1(:,place,val,:,m)=reshape(data3,size(data3,1),1,1,size(data3,2),1);
                        AllData_indi1(:,place,val,:,m)=reshape(data1,size(data1,1),1,1,size(data1,2),1);
                        indi_ids1=[indi_ids1;[j,k,l]];
           
                    else
                        data1=zeros(300*trltime_max,192);
                        maxtimenow=size(AllData_events1{j,k,l},1);
                        querypoints=linspace(1,maxtimenow(1)-1,300*trltime_max);
                        for u=1:192
                            data1(:,u)=interp1([1:(maxtimenow(1)-1)],...
                                full(AllData_events1{j,k,l}([1:(maxtimenow(1)-1)],u)),querypoints,'nearest');
                        end
                        m=1;
                        while ~isempty(AllData_indi_ncTX{place,val,m})
                            m=m+1;
                        end    
                        
                        trialNum(val,place)=m;
                        AllData_indi_ncTX{place,val,m}=sparse(data1);
                        indi_ids1=[indi_ids1;[j,k,l]];            
                    end                       
                end     
            end
        end
    end
disp('done');
 
trialNum=reshape(trialNum',1,4,2);
trialNum=repmat(trialNum, 384,1,1);
  
end



            
            
            
            
            
                    