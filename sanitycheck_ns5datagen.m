
% this code smooths the newly generated slc data after running the extractSLCfromNS5
% plots them together for comparison. try for various channels. 

channel=71;smthwindow=10;
figure();plot(smoothdata(slc_new_ref.ncTX.values(:,channel),'gaussian',smthwindow));
hold on;
plot(smoothdata(slc_old.ncTX.values(:,channel),'gaussian',smthwindow));
plot(smoothdata(((sum(reshape((slc_new_ref.ncTX.events(1:(floor(size(slc_new_ref.ncTX.events,1)/300)*300),channel)),300,[]),1)).*50),'gaussian',smthwindow))

legend('newncTX','oldncTX','ncTX from events');

%% checking how the spiking varies for each task: checking for oscillatory activity to justify jPCA. 

ses=1;
blk=1; 
epoc=100;

% plotting spiking activity vs the specific reaching trial: 
currdata=AllData(190,:,epoc,blk,ses);
currdata=currdata(~isnan(currdata));
figure();plot(smoothdata(currdata,'gaussian',10));
currang=FingerAngData(:,:,epoc,blk,ses);
currang=currang(~isnan(currang));
currang=reshape(currang,4,[]);
hold on;
for i=1:4 
    plot(currang(i,:))
    hold on;  
end;
legend({'firingRate','index','RP','T Flex/ext','T ab/ad'});

%plotting pre reach spiking activity vs the specific reach trial:
currdata=AllData_prereach(100,:,epoc,blk,ses);
currdata=currdata(~isnan(currdata));
figure();plot(smoothdata(currdata,'gaussian',1));
currang=FingerAngData(:,:,epoc,blk,ses);
currang=currang(~isnan(currang));
currang=reshape(currang,4,[]);
hold on;
for i=1:4 
    plot(currang(i,:))
    hold on;  
end;
legend({'firingRate','index','RP','T Flex/ext','T ab/ad'});

% picked up from sanitycheck previous: 
testfingerangle=reshape(FingerAngData(:,:,:,blk,ses),4,trltime_max*notrials_max);
testfingerangle(isnan(testfingerangle))=[];
testfingerangle=reshape(testfingerangle,4,[]);
figure()
for i=1:4 
    plot(testfingerangle(i,:))
    hold on;
    
end;
legend({'index','RP','T Flex/ext','T ab/ad'});
%% plotting the moving aveerage for the nctx events : 
