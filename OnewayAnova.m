function [chlist,chlist_welch,chlist_wilcox,normality_result,levine_out] = OnewayAnova(AllData_indi_blknorm,AllData_indi_blknorm_prereach, avg_window)
% this function computes the one way anova for each feature to check for
% significant differences between baseline(pre reach) and movement window. 
% it will mean each trial for the specified window(only valid for non
% prereach) and that will be a data point for the ANOVA. 
% THIS IMPLEMENTS BOTH WELCH F AND STANDARD F FOR THE ANOVA. 
% ALSO TESTS FOR ANOVA ASSUMPTIONS OF NORMALITY, ETC. 

% Avg_window= time window in msa

%% data rearrangment: 
sz_post=size(AllData_indi_blknorm);
sz_pre=size(AllData_indi_blknorm_prereach);
chlist=zeros(sz_post(1),1);
chlist_welch=zeros(sz_post(1),1);
chlist_wilcox=zeros(sz_post(1),1);

postdata=permute(AllData_indi_blknorm,[1,4,2,3,5]);
postdata=reshape(postdata,sz_post(1),sz_post(4),[]);
postdata=reshape(postdata(~isnan(postdata)),sz_post(1),sz_post(4),[]);
X1=mean(postdata(:,[1:avg_window/20],:),2);
X1=X1(:,:); % chans X no_trials 

predata=permute(AllData_indi_blknorm_prereach,[1,4,2,3,5]);
predata=reshape(predata,sz_pre(1),sz_pre(4),[]);
predata=reshape(predata(~isnan(predata)),sz_pre(1),sz_pre(4),[]);
X2=mean(predata,2);
X2=X2(:,:);
normality_result=zeros(2,sz_post(1));% since there are two groups here: X1 and X2
levine_out=zeros(1,sz_post(1));


for chano=1:sz_post(1)
    data=[(X1(chano,:))',(X2(chano,:))'];
    chlist(chano,:)=anova1(data,{'1' ,'2'},'off');
    %WELCH F : 
    labels=[ones(size(X1,2),1);2*ones(size(X2,2),1)];
    chlist_welch(chano,:)=wanova(data(:),labels);
    [normality_result(:,chano),~,levine_out(1,chano)] = AnovaAssumptionTester(data(:),labels);
    %WILCOXON SIGN RANK TEST: 
    chlist_wilcox(chano,1)=signrank(data(:,1),data(:,2));
end

end

