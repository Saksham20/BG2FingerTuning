
%% Code to normalize AllData per block basis: 
 %!!  RUn this code after dataGen, dataGen2, dataGen_refblk 
 function [AllData_blknorm,AllData_prereach_blknorm]=dataGen_normalize( AllData,AllData_prereach,AllData_refblk)
    global sessnos noblks_max notrials_max trltime_max pretrltime_max OL_blocks_new sessionList sessnames 
    disp('starting normzlization');
    sz=size(AllData);AllData_blknorm=NaN*ones(sz);prenan=[];
    AllData_prereach_blknorm=NaN*ones(sz);
    ses_flag=true;
    if ses_flag
        se=1;
    else
        se=1:sz(5);
    end
    for j=se
        fprintf('\n sess %d',j);
        baseline=AllData_refblk(:,:,j);baseline=baseline(:,:);
        baseline_mean=nanmean(baseline,2);
        baseline_mean=repmat(baseline_mean,1,prod(sz(2:3)));
        baseline_std=nanstd(baseline,[],2);
        baseline_std=repmat(baseline_std,1,prod(sz(2:3)));

        for i=1:sz(4)
            fprintf('.');
    %         baseline=AllData(:,:,:,i,j);baseline=reshape(baseline,sz(1),prod(sz(2:3)));
    %         baseline=nanmean(baseline,2);
            currdata=AllData(:,:,:,i,j);
            currdata1=AllData_prereach(:,:,:,i,j);
            currdata=reshape(currdata,sz(1),prod(sz(2:3)));
            currdata1=reshape(currdata1,sz(1),prod(sz(2:3)));


            AllData_blknorm(:,:,:,i,j)=reshape(((currdata-baseline_mean)),sz(1),sz(2),sz(3));
            AllData_prereach_blknorm(:,:,:,i,j)=reshape(((currdata1-baseline_mean)),sz(1),sz(2),sz(3));
    %         if isempty(isnan(baseline)) && isempty(isnan(currdata(:,1))) % there are some blocks where pre reach is all nans !!
    %             if any(isnan(baseline))
    %                 prenan=[prenan;i,j];
    %             end
    %             baseline=repmat(baseline,1,prod(sz(2:3)));
    %             
    %             AllData_blknorm(:,:,:,i,j)=reshape((currdata./baseline),sz(1),sz(2),sz(3));
    %             AllData_prereach_blknorm(:,:,:,i,j)=reshape((currdata1./baseline),sz(1),sz(2),sz(3));
    %         elseif all(isnan(baseline)) && ~all(isnan(currdata(:,1)))       
    %             baselinemod=nanmean(currdata,2);baselinemod=repmat(baselinemod,1,prod(sz(2:3)));
    %             AllData_blknorm(:,:,:,i,j)=reshape((currdata./baselinemod),sz(1),sz(2),sz(3));
    %             prenan=[prenan;i,j];
    %         end
        end
    end

    disp('done');
 end