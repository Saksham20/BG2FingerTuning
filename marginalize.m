
% this code will use the prebuilt functions in the dpca_demo to marginalize
% the complete data. It will then find out the percentages of each type of variance with the total of each of
% features individually 
%% data extraction: 
combinedParams = {{1, [1 3]}, {2, [2 3]}, {3}, {[1 2], [1 2 3]}};
margNames = {'Fingers', 'Flex/ext', 'Condition-independent', 'Fing/Dof Interaction'};
Xfull=nanmean(AllData_indi_blknorm_ses1,5);
sz=size(AllData_indi_blknorm_ses1);
X = Xfull(:,:);
X = bsxfun(@minus, X, mean(X,2));
XfullCen = reshape(X, size(Xfull));

totalVar_feat = sum(X.^2,2); % vector having total variance in each feature seperately. 
[~,var_indx]=sort(totalVar_feat,'descend');

totalVar_all=sum(totalVar_feat);

[Xmargs, margNums] = dpca_marginalize(XfullCen, 'combinedParams', combinedParams, ...
                    'ifFlat', 'no');
                
                
 marg_var_feat=zeros(sz(1),numel(Xmargs));
 for margs=1:numel(Xmargs)
     curr_marg=Xmargs{margs};
     curr_marg=curr_marg(:,:);
     marg_var_feat(:,margs)=sum(curr_marg.^2,2);
 end
 clearvars curr_marg
 
 %% plotting channels wise variance: 
figure(1);
 dataplot=([marg_var_feat (totalVar_feat-sum(marg_var_feat,2))]./totalVar_all);
 var_indx_new=var_indx(1:end);
 
 bar(dataplot(var_indx_new,:),'stacked');
 xticklabels(var_indx_new);
 legend(margNames);title('raw feature variance');
 figure(3);plot((cumsum(totalVar_feat(var_indx)))./totalVar_all,'-b');hold on;
 
 %% computing the pca and then plotting the same graph: 
disp('starting')
CovMat=X*X';
[U,S] = eig(CovMat);
[~,ind] = sort(abs(diag(S)), 'descend');
S = S(ind,ind);%sorted variances of each dimension 
S=diag(S);
U = U(:,ind);
SV = U'*X;

Xmargs_PCs=cellfun(@(x) reshape(U'*x(:,:),size(x)),Xmargs,'UniformOutput',false);
marg_var_feat_pc=zeros(sz(1),numel(Xmargs_PCs));
 for margs=1:numel(Xmargs_PCs)
     curr_marg=Xmargs_PCs{margs};
     curr_marg=curr_marg(:,:);
     marg_var_feat_pc(:,margs)=sum(curr_marg.^2,2);
 end
 clearvars curr_marg
 % plotting: ----------
figure(2);
 dataplot=([marg_var_feat_pc (S-sum(marg_var_feat_pc,2))]./totalVar_all);
 var_indx_new=1:length(S);
 
 bar(dataplot(var_indx_new,:),'stacked');
 xticklabels(var_indx_new);
 legend(margNames);title('variance of PCs');
figure(3);plot((cumsum(S))./totalVar_all,'-r');legend({'raw features','PCs of raw'});