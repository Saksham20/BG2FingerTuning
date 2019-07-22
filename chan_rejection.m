function [best_chans,top_SNR_chans,sig_chans] = chan_rejection(AllData_indi_blknorm,top_num)
%This function does feature pruning (selecting the good channels for further analysis) 2 step process:
% 1) Compute the SNR and select only the top features (number specified by input arg) 
%2) Compute whether the feature is significantly tuned using one way ANOVA for the FR across all conditions
% The input data will be varied based on a sub window in a trial. That will be selected which produces the max
%no of significantanly tuned channels. 

% input arguments: 
% Alldata_indi, top number of channels to select (top_num)


%% data unentangling: 
[anova_data,anova_labels,~] = data_unentangling(AllData_indi_blknorm);

%% SNR implementation: 
snr=(nanmean(abs(anova_data),2))./nanstd(anova_data,[],2);
[~,top_SNR_chans]=sort(snr,'descend');
top_SNR_chans=top_SNR_chans(1:top_num);


%% performing anova for each channel
p=ones(384,1);
nonnan=~isnan(anova_data(1,:));
fprintf('\n')


disp('performing anova');
for chano=1:384
    p(chano,1)=anova1(anova_data(chano,nonnan),anova_labels(1,nonnan),'off');
    if rem(chano,10)==0
        fprintf('.');
    end
end
fprintf('done \n');
sig_chans=find(p<0.05);% significant channels from ANOVA

best_chans=top_SNR_chans(ismember(top_SNR_chans,sig_chans));%common channels in both lists

%% performing some analysis on the untangled data: 
%Correcoef: 

% finding corrcoef
fprintf('performing corref\n');
covmat = corrcoef((double(anova_data(best_chans,nonnan)))');
figure
x = length(best_chans);
imagesc(covmat);
set(gca,'XTick',1:x);
set(gca,'YTick',1:x);
% set(gca,'XTickLabel',White_Wine.Properties.VarNames);
% set(gca,'YTickLabel',White_Wine.Properties.VarNames);
axis([0 x+1 0 x+1]);
grid;
colorbar;


end
