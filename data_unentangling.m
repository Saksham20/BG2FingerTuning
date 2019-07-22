function [anova_data,anova_labels,anova_trial_labels] = data_unentangling(AllData_indi_blknorm)


%UNTITLED unentangle all data to make a (384 X all-time) matrix. Also output a
%trial label and tasktype label matrix of size (1 X all-time) 


%% Data untangling: 
sz=size(AllData_indi_blknorm);
anova_data=zeros(sz(1),prod(sz(2:end)));count=0;group=0;
anova_labels=NaN*ones(1,prod(sz(2:end)));
anova_trial_labels=NaN*ones(1,prod(sz(2:end)));
disp('unentangling data')
for i=1:sz(2)
    for j=1:sz(3)
        fprintf('.')
        group=group+1;
        for k=1:sz(5)
        anova_data(:,(count+1):(count+sz(4)))=(reshape(AllData_indi_blknorm(:,i,j,:,k),sz(4),sz(1)))';
        anova_labels(:,(count+1):(count+sz(4)))=group*ones(1,sz(4));
        anova_trial_labels(:,(count+1):(count+sz(4)))=k*ones(1,sz(4));
        count=count+sz(4);
        end
    end
end
disp('done');
end

