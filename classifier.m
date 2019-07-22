%% Classification of the time series for all conditions: 4dof X 2(flex/ext)

% Generation of condufion matrix for various implementations: 
%1) Fulldimentional with 384 features and all time series with 8 labels.

%2)Reduced dim using PCA using with 384 feat as input and each time point in
% the psth series as a observation. No labelling. Choosing top dimentions
% and inputing them into classifier. 

% 3) Reduced dime using PCA with (384 X no. of time points/trial) as number
% of features and choosing top PCs to be input into classification.

% Using Naive_Bayes classifier with cross validation and forward feature
% selection to improve.
% Also, using Decision trees. 

%% 1) Data generation: 
disp('starting data gen');
[anova_data,anova_labels,anova_trial_labels] = data_unentangling(AllData_indi_blknorm);
top_feat=20;
labels=1:8;
saveloc='G:\Personal Folders\Sharda, Saksham\codes2.0\figures\';

%% 2.1) Full dim, no dim reduction: 



%% 2.2) PCA timepoint observation 
% time vs window size
mkdir([saveloc 'PCA Time indi']);
pcadata=anova_data(:,ismember(anova_labels,labels));
pcadata=(pcadata-repmat(nanmean(pcadata,2),1,size(pcadata,2)))./...
    repmat(nanstd(pcadata,[],2),1,size(pcadata,2));% normalizing
Y=anova_labels(ismember(anova_labels,labels));
trl_labels=anova_trial_labels(ismember(anova_labels,labels));
%removing Nans: 
trl_labels=trl_labels(any(~isnan(pcadata)));
Y=Y(any(~isnan(pcadata)));
pcadata=pcadata(~isnan(pcadata));
pcadata=reshape(pcadata,384,[]);

pcadata=nanmean(AllData_indi_blknorm_combined(:,1,1,:,:),5);
pcadata=pcadata(:,:);% 384 X trl_time; 
pcadata=(pcadata-repmat(mean(pcadata,2),1,size(pcadata,2)))./repmat(std(pcadata,[],2),1,size(pcadata,2));
Y=1*ones(1,size(pcadata,2));



[W,~,~] = svd(pcadata, 'econ');
W = W(:,1:20);
X=W' * pcadata;
X=X';Y=Y';

% CV object: 
c = cvpartition(Y,'holdout',.2);
X_Train = X(training(c,1),:);
Y_Train = Y(training(c,1));
%triain classifier: 
Bayes_Model = fitcnb(X_Train, Y_Train, 'DistributionNames','kernel');
Bayes_Predicted = predict(Bayes_Model,X(test(c,1),:)); 
[conf, classorder] = confusionmat(Y(test(c,1)),Bayes_Predicted);
Bayes_success = trace(conf)/sum(conf(:));
figure(1);
imagesc(conf*100./repmat(sum(conf,2),1,8));colorbar;
title(sprintf('PCA Timepoint indi method, success %d',Bayes_success));
print([saveloc 'PCA Time indi\confuMat'],'-djpeg','-r300');
        close Figure 1;

%% 2.3) PCA high dim implementation 
% incremental time inclusing along the trial time: 
disp('starting PCA high dim implementation');
trl_len=sum(anova_trial_labels(ismember(anova_labels,1))==1);
no_trials_percond=length(unique(anova_trial_labels((anova_labels==1))));

mkdir([saveloc 'PCA high dim']);
Bayes_success=zeros(1,trl_len);
for time_scan=1:trl_len
X=reshape(anova_data(:,ismember(anova_labels,labels)),384,trl_len,no_trials_percond*labels(end));
X=X(:,1:time_scan,:);
X=reshape(X,384*time_scan,no_trials_percond*labels(end));
Y=reshape(repmat([1:labels(end)],no_trials_percond,1),1,[]);
% removing nans: 
non_nantrials=~isnan(X(1,:));
Y=Y(non_nantrials);% since X will only be nans in a few trials per condition. 
X=X(:,non_nantrials);% It was interpolated along the trial time dimention!
% PCA: 
X_norm=(X-repmat(mean(X,2),1,size(X,2)))./repmat(std(X,[],2),1,size(X,2));
[W,~,~] = svd(X_norm, 'econ');
W = W(:,1:top_feat);
X=W' * X_norm;
X=X';Y=Y';

% CV object: 
c = cvpartition(Y,'holdout',.2);
% c = cvpartition(Y,'KFold',10);
X_Train = X(training(c,1),:);
Y_Train = Y(training(c,1));
%triain classifier: 
Bayes_Model = fitcnb(X_Train, Y_Train, 'DistributionNames','kernel');
Bayes_Predicted = predict(Bayes_Model,X(test(c,1),:)); 
[conf, classorder] = confusionmat(Y(test(c,1)),Bayes_Predicted);
Bayes_success(time_scan) = trace(conf)/sum(conf(:));
figure(1);
imagesc(conf*100./repmat(sum(conf,2),1,8));colorbar;
title(sprintf('PCA combined Time/Feat method, success %d \n time window = %dms',Bayes_success(time_scan),time_scan*20));
print([saveloc sprintf('PCA high dim\\timewindow%d',time_scan)],'-djpeg','-r300');
        close Figure 1;
end

figure(2); plot(([1:trl_len]*20),Bayes_success);xlabel('time window in ms'); ylabel('% success');
print([saveloc 'PCA high dim\BayesSuccessRate'],'-djpeg','-r300');
        close Figure 2;

%% 3) Naive Bayes: 

%% 4) Decision Tree: 