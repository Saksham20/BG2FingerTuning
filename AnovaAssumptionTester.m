function [normality_result,sample_sizes,levine_out] = AnovaAssumptionTester(Data,group_labels)
warning off stats:adtest:OutOfRangePLow
warning off stats:adtest:OutOfRangePHigh
% this code will test for the validity of the standard assumptions for every group made in
% ANOVA: 
%1) Normality (anderson-darling test)
%2) Same sample size
%3) Same variance (Levine's test)
%4) Independence of the samples in groups 
% argument assumptions: Data and group labels are like those input to a one
% way anova. But this takes group_labels as a numeric vector rather than a
% character cell as in anova1.m 

no_groups=numel(unique(group_labels));
%% testing for normality: 
normality_result=zeros(no_groups,1);
for grpno=1:no_groups
    %normality_result(grpno,1)=adtest(Data(group_labels==grpno));
    normality_result(grpno,1)=swtest(Data(group_labels==grpno));%shapiro-wilk test
end

%% sample size: 
sample_sizes=zeros(no_groups,1);
for grpno=1:no_groups
    sample_sizes(grpno,1)=sum(group_labels==grpno);
end


%% Levines test: 
 
levine_out=vartestn(Data,group_labels,'Display','off','TestType','LeveneAbsolute');


end
