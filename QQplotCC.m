function [Sig,CC,Sig_CC] = QQplotCC(group,alpha)
% this function generates the qq plot values and computes the correlation
% coeff between the z values and group values. Uses the table from "Applied
% Multivariate Analysis" - Johnson, Wichern , to get the significance based
% on the specified alpha. 

if size(group,2)>size(group,1)
    group=group';
end

sorted_group=sort(group);
segments=length(group);
prctiles=linspace(0,1,segments+2);
z_vals=norminv(prctiles(2:end-1),nanmean(group),nanstd(group));
z_vals=(z_vals.*nanstd(group))+nanmean(group);

CC=corrcoef([sorted_group, z_vals']); 

gdalpha=ismember([0.01 0.05 0.1], alpha);
label={'alpha01','alpha05','alpha1'};
if ~gdalpha
    error('enter value of alpha as 0.05,0.01,0.1');
end 

%% table value from Johnson, Wichern: 
alpha01=[8299 8801 9126 9269 9410 9479 9538 9599 9632 9671 9695 9720 9771 9822 9879 9905 9935]'.*1e-4; 
alpha05=[8788 9198 9389 9508 9591 9652 9682 9726 9749 9768 9787 9801 9838 9873 9913 9931 9953]'.*1e-4;
alpha1=[9032 9351 9503 9604 9665 9715 9740 9771 9792 9809 9822 9836 9866 9895 9928 9942 9960]'.*1e-4;
samplesize=[5:5:60, 75 100 450 200 300]';

eval(sprintf('label=%s;',label{find(gdalpha)}));
Sig_CC=interp1(samplesize,label,(segments));
Sig=Sig_CC<=CC(2,1); 
CC=CC(2,1);
end

