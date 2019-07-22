
% this is a sanity check code for dataGEn : 

ses=1;
blk=4; 

testfingerangle=reshape(FingerAngData(:,:,:,blk,ses),4,trltime_max*notrials_max);
testfingerangle(isnan(testfingerangle))=[];
testfingerangle=reshape(testfingerangle,4,[]);

% idx=(reshape(ReachType(:,:,:,blk,ses),1,trltime_max*notrials_max));
% idx(isnan(idx))=[];
% testfingerangle=testfingerangle(:,logical(idx));

testtasktype=reshape(TaskType(:,:,blk,ses),4,notrials_max);
testtasktype(isnan(testtasktype))=[];
testtasktype=reshape(testtasktype,4,[]);
bsang= TargetAngles(:,2);
figure()
for i=1:4 
    plot(testfingerangle(i,:))
    hold on;
    
end;
legend({'index','RP','T Flex/ext','T ab/ad'});


% for i=1:4; 
%     plot(((10*testtasktype(i,:))+bsang(i,1)),'*')
%     hold on;    
% end;
