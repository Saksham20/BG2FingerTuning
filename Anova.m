%% This code incorporates lag in the data and then computes regression to check for significant regress: 

%% changing the All DAta to incorporate lag time :  
disp('running lag comp');
AllData1=AllData_blknorm;
for lagtime=0 %ms
    
samples=lagtime/20;
sz_data_lagged=size(AllData1);
sz_data_lagged(2)=sz_data_lagged(2) - samples; 

if samples>0;
    AllData_lag=NaN*ones(sz_data_lagged);
    PosVec_lag=NaN*ones([4 sz_data_lagged(2:end)]);
    ControlVec_lag=PosVec_lag;
for a=1:sz_data_lagged(5)
    for b=1:sz_data_lagged(4)
        for c=1:sz_data_lagged(3)
            if ~all(isnan(AllData1(1,:,c,b,a)))
                temp=find(isnan(AllData1(1,:,c,b,a)));
                if isempty(temp)
                    temp=(size(AllData1(1,:,c,b,a),2))+1;
                end
                temp1=AllData1(:,:,c,b,a);
                temp1(:,(temp(1)-samples):(temp(1)-1))=[];
                AllData_lag(:,:,c,b,a)=temp1;

                temp1=PosVec(:,:,c,b,a);
                temp1(:,1:samples)=[];
                PosVec_lag(:,:,c,b,a)=temp1;
                
                temp1=ControlVec(:,:,c,b,a);
                temp1(:,1:samples)=[];
                ControlVec_lag(:,:,c,b,a)=temp1;
            end
        end
    end
end
else 
    AllData_lag=AllData1;
    PosVec_lag=PosVec;
    ControlVec_lag=ControlVec;
end            
            

% computing velocity------: 
VelVec_lag=zeros(size(PosVec_lag));
sz=size(PosVec_lag);
for a=1:sz(5)
    for b=1:sz(4)
        for c=1:sz(3)
            
            VelVec_lag(:,2:end,c,b,a)=[diff(PosVec_lag(:,:,c,b,a),1,2)];
            VelVec_lag(:,1,c,b,a)= VelVec_lag(:,2,c,b,a);
            tempest=sum(sum(int8(isnan(VelVec_lag(:,1,c,b,a)))));
            if rem(tempest,4)>0
                [c,b,a]
            end
        end
    end
end            
disp('done');   

%% computing regression of each channel to the control  vector variable: 
disp('running regression');
X_id=(reshape(ReachType(:,:,:,:,:),1,[]));
X_id(isnan(X_id))=[];
X_id=reshape(X_id,1,[]);

X=(reshape(ControlVec_lag(:,:,:,:,:),4,[]));
X(isnan(X))=[];
X=reshape(X,4,[]);
X=X(:,logical(X_id));% to pick only the non middle target reaching trials. 

stat=zeros(384,4);
b=zeros(5,384);b_glm=zeros(5,384); rsq_glm=zeros(384,1);
for chano=1:384
    Y=(reshape(AllData_lag(chano,:,:,:,:),1,[]));
    Y(isnan(Y))=[];
    Y=Y(:,logical(X_id));
    
    [b(:,chano),bint,r,rint,stat(chano,:)] = regress((Y'),[ones(size(X,2),1) X']);
    bglm=fitglm(X',Y','linear','Link','log','Distribution','poisson');
    b_glm(:,chano)=bglm.Coefficients.Estimate;
    rsq_glm(chano)=bglm.Rsquared.Ordinary;
end
disp('done');  

r2vals=stat((stat(:,3)<0.05),1);
figure();histogram(r2vals);title('ControlVec_lag sessn1','Interpreter', 'none');
figure();histogram(rsq_glm);title('GLM rsq, ControlVec','Interpreter', 'none');
% print(['G:\Personal Folders\Sharda, Saksham\codes2.0\figures\' sprintf('lagtime_%d ms',lagtime)],'-djpeg');
% close all;

end


