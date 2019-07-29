function [allsigchans,sig_out,chan_stats,normality_resultsw,normality_resultqq,CCchan,levine_out] = TwowayAnova(AllData_indi_blknorm,AllData_indi_blknorm_prereach, avg_window)



%% Compatible data format creation: 
%AllData size = nochans X dim(2)(fingers) X dim(3)(flext) X trl_time X noTrials 
% from size of AllDAta, to no_trials X dim(3)(flext) X dim(2)(fingers) X
% no_chans 

transform=true; 
sz=size(AllData_indi_blknorm);
avg_window_id=avg_window/20;
allsigchans=cell(1,length(0:(sz(4)-avg_window_id)));
for lagtime=9%0:sz(4)-avg_window_id
    tic;
    fprintf(sprintf('starting lagtime=%d of %d \n',lagtime,(sz(4)-avg_window_id)))
    data=nanmean(AllData_indi_blknorm(:,:,:,[(lagtime+1):(lagtime+avg_window_id)],:),4); 
    predata=nanmean(AllData_indi_blknorm_prereach,4);
    data=(data-predata);%*100./predata;% to find the percentage deviation from the prereach baseline activity.. 
    data=permute(data,[5 3 2 1 4]);
    sz_data=size(data);

    %transform data to make it more normal:-----------------
    if transform
        for i=1:1% no of times the transformation is run 
            data=data+abs(min(data(:)))+1;% making all data positive for the transformation. 
            data=log(data);
        end % inverse / log / sqrt
        % trimming data:------------------
        data_winsorize=normTrim(data,1,20, 'winsorize');
    end

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
    data_winsorize=reshape(data_winsorize(~isnan(data_winsorize)),[],sz_data(4),1);
    % writing data to csv for R analysis:--------------- 
    try 
        csvwrite('G:\Personal Folders\Sharda, Saksham\codes2.0\data.csv',data);
    catch 
    end
    try
        csvwrite('G:\Personal Folders\Sharda, Saksham\codes2.0\flextlabels.csv',mat2cell(group_labels1));
    catch 
    end
    try 
        csvwrite('G:\Personal Folders\Sharda, Saksham\codes2.0\fingerlabels.csv',group_labels2);
    catch 
    end



    %% performing 2 way unbalanced design ANOVA: -----------------------------

    %% running R script: 

    Rcmd='"C:\Program Files\R\R-3.6.1\bin\Rscript.exe" --vanilla --slave "G:\Personal Folders\Sharda, Saksham\codes2.0\RobustAnova.R"';
    status=system(Rcmd);
    if status==0
        AnovaResult = csvread('G:\Personal Folders\Sharda, Saksham\codes2.0\adjusted_p_values_no_trim.csv',1,1);
        Sigchans.fingers=AnovaResult((AnovaResult(:,2)==1) & (AnovaResult(:,3)<=0.05) ,1);
        Sigchans.flext=AnovaResult((AnovaResult(:,2)==2) & (AnovaResult(:,3)<=0.05) ,1);
        Sigchans.interaction=AnovaResult((AnovaResult(:,2)==3) & (AnovaResult(:,3)<=0.05) ,1);
        Sigchans.fingflext=intersect(Sigchans.fingers,Sigchans.flext);
        Sigchans.fingflextinteract=intersect(intersect(Sigchans.fingers,Sigchans.flext),Sigchans.interaction);
    else 
        error('could not run R script')
    end
    allsigchans{1,lagtime+1}=Sigchans;
    %% plotting the box plots: 
    plotloc=sprintf('G:\\Personal Folders\\Sharda, Saksham\\codes2.0\\figures\\session1_channel_wise\\SEMplots\\windowsize%d\\lagtime%dms',avg_window,lagtime*20);
    goodchans={Sigchans.fingers',Sigchans.flext',Sigchans.interaction'}; 
    plotBOX(data_winsorize,group_labelAll,plotloc,'sem',goodchans,lagtime,avg_window)



    %% Matlab Implementation of anova: 
    normality_resultsw=zeros(length(unique(group_labelAll)),sz(1));% since there are two groups here: X1 and X2
    normality_resultqq=zeros(length(unique(group_labelAll)),sz(1));
    CCchan=zeros(length(unique(group_labelAll)),sz(1));
    levine_out=zeros(1,sz(1));

    for chanos=1:sz(1)
        [anova_pvals(:,chanos),~,chan_stats{chanos,1}]=anovan(data(:,chanos),{group_labels1,group_labels2},...
            'model',[1 0;0 1;1 1],'display','off','varnames',{'flext','fingers'});
        [normality_resultsw(:,chanos),normality_resultqq(:,chanos),CCchan(:,chanos),~,levine_out(1,chanos)] = AnovaAssumptionTester(data(:,chanos),group_labelAll);
    end
    chanlist=1:sz(1);
    sig_flext=chanlist(anova_pvals(1,:)<0.05);
    sig_fingers=chanlist(anova_pvals(2,:)<0.05);
    sig_interaction=chanlist(anova_pvals(3,:)<0.05);
    sig_out={sig_flext,sig_fingers,sig_interaction};
    toc
end
end

