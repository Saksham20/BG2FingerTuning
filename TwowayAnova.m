function [sig_out,chan_stats,normality_result,levine_out] = TwowayAnova(AllData_indi_blknorm,avg_window)



%% Compatible data format creation: 
% from size of AllDAta, to no_trials X dim(2)(fingers) X dim(3)(flext) X no_chans
sz=size(AllData_indi_blknorm);
data=nanmean(AllData_indi_blknorm(:,:,:,[1:avg_window/20],:),4); 
data=permute(data,[5 3 2 1 4]);
sz_data=size(data);

%generating grouping variables------------
group_labels1=1:sz_data(2);
group_labels1=repmat(group_labels1,sz_data(1),1,sz_data(3));
group_labels1(isnan(data(:,:,:,1,1)))=NaN;
group_labels1=group_labels1(~isnan(group_labels1));

group_labels2=reshape([1:sz_data(3)],1,1,sz_data(3));
group_labels2=repmat(group_labels2,sz_data(1),sz_data(2),1);
group_labels2(isnan(data(:,:,:,1,1)))=NaN;
group_labels2=group_labels2(~isnan(group_labels2));

group_labelAll=1:prod(sz_data(2:3));
group_labelAll=reshape(group_labelAll,1,sz_data(2),sz_data(3));
group_labelAll=repmat(group_labelAll,sz_data(1),1,1);
group_labelAll(isnan(data(:,:,:,1,1)))=NaN;
group_labelAll=group_labelAll(~isnan(group_labelAll));
%---------------------------
data=reshape(data(~isnan(data)),[],sz_data(4),1);
%% performing 2 way unbalanced design ANOVA:    
anova_pvals=zeros(3,sz(1));
chan_stats=cell(sz(1),1);

normality_result=zeros(length(unique(group_labelAll)),sz(1));% since there are two groups here: X1 and X2
levine_out=zeros(1,sz(1));

for chanos=1:sz(1)
    [anova_pvals(:,chanos),~,chan_stats{chanos,1}]=anovan(data(:,chanos),{group_labels1,group_labels2},...
        'model',[1 0;0 1;1 1],'display','off','varnames',{'flext','fingers'});
    [normality_result(:,chanos),~,levine_out(1,chanos)] = AnovaAssumptionTester(data(:,chanos),group_labelAll);
end
chanlist=1:sz(1);
sig_flext=chanlist(anova_pvals(1,:)<0.05);
sig_fingers=chanlist(anova_pvals(2,:)<0.05);
sig_interaction=chanlist(anova_pvals(3,:)<0.05);
sig_out={sig_flext,sig_fingers,sig_interaction};

end

