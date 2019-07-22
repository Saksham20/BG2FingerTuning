
% this  code will plots the average spike rate for differetnt conditions
% but first the computations of the spike rate  from threshold crossings 

%% spike rate calc: 
window=300; % the window of averaging using a moving average. 
freq=1000; % value in hz: time resolution for spike rate function.
sz=size(AllData_indi_ncTX);
AllData_indi_SpikeRate=cell(sz);
a=1;b=(ones(1,window))./(window/15000);% intialize filter
disp('start');tic
for i=1:1%sz(1)
    for j=1:1%sz(2)
        for k=1:sz(3)
            if ~isempty(AllData_indi_ncTX{i,j,k})
                temp=AllData_indi_ncTX{i,j,k};
                AllData_indi_SpikeRate{i,j,k}=sparse(filter(b,a,full(temp)));
            end
        end
    end
end
disp('end');toc
%% averaging across trials for every condition: 
AllData_indi_SpikeRate_avgTrl=cell(sz(1),sz(2));
disp('start');tic
for i=1%:1:sz(1) % going across all trials 
    for j=1%:1:sz(2)
        data=zeros(size(AllData_indi_SpikeRate{i,j,1}));
        count=0;
        for k=1:sz(3)
            if ~isempty(AllData_indi_SpikeRate{i,j,k})
                count=count+1;
                data=data+(AllData_indi_SpikeRate{i,j,k});
                
            end
        end
        AllData_indi_SpikeRate_avgTrl{i,j}=data./count;
    end
end
disp('end');toc

%% plotting : 

%% 1) condition wise: 
topnos_chans=120;
finglist={'index','TRP','Thumb(F-E)','Thumb(Ab-Ad)'};movementlist={'flex','ext'};
saveloc='G:\Personal Folders\Sharda, Saksham\codes2.0\figures\';
mkdir([saveloc 'condition_wise']);
for finger=1:4
    for movmt=1:2
        close all;
        figure(); 
        asdf1=nanmean(AllData_indi(:,finger,movmt,:,:),5);
        asdf1=(asdf1(:,:));
        % calculating SNR: 
        snr=(nanmean(abs(asdf1),2))./std(asdf1,[],2);
        [~,snr_id]=sort(snr,'descend');
        snr_id=snr_id(1:topnos_chans);

        asdf2=nanmean(AllData_indi_blknorm_prereach(:,finger,movmt,:,:),5);
        asdf2=(asdf2(:,:));
        data=[asdf2 asdf1];
        data=(data-repmat(mean(data,2),1,size(data,2)))./repmat(std(asdf2,[],2),1,size(data,2));
        imagesc(data(snr_id,:));colorbar;title([finglist{finger} movementlist{movmt}],'Interpreter', 'none');
        print([saveloc 'condition_wise\spectrogram for_' finglist{finger} '_' movementlist{movmt}],'-djpeg','-r300');
        
        figure();
        for i=1:length(snr_id)
            plot(data(snr_id(i),:));title([ ...
                sprintf('no. of chans. %d',i)],'Interpreter', 'none');hold on;
            ax=gca; 
            line([size(asdf2,2) size(asdf2,2)],[ax.YLim],'Color','k','LineStyle','--');
        end
        legend({[finglist{finger} ' ' movementlist{movmt}],'movement start'});
        print([saveloc 'condition_wise\top_chans_' finglist{finger} '_' movementlist{movmt}],'-djpeg','-r300');
        
        figure();
        plot(mean(data(snr_id,:),1));title([finglist{finger} '_' movementlist{movmt} ...
            sprintf('top %d chan avg',topnos_chans)],'Interpreter', 'none');
        hold on;
        ax=gca; line([size(asdf2,2) size(asdf2,2)],[ax.YLim],'Color','k','LineStyle','--');
        legend({[finglist{finger} ' ' movementlist{movmt}],'movement start'})
        print([saveloc 'condition_wise\avg_chans_' finglist{finger} '_' movementlist{movmt}],'-djpeg','-r300');
        close all;
    end
end


%% 2) Channel wise : 
finglist={'index','TRP','Thumb(F-E)','Thumb(Ab-Ad)'};movementlist={'flex','ext'};
saveloc='G:\Personal Folders\Sharda, Saksham\codes2.0\figures\';
leg_entry1=cell(1,8);leg_entry1(1,1:2:8)=finglist;leg_entry1(1,2:2:8)=finglist;
leg_entry2=[movementlist movementlist movementlist movementlist];
leg_entry=cell(1,8);
savedir=[saveloc 'channel_wise\'];disp('starting channel wise')
mkdir(savedir);
for t=1:8
    leg_entry{t}=[leg_entry1{t} '-' leg_entry2{t}];
end
leg_entry_all=cell(1,16); leg_entry_all(1:2:end)=leg_entry;
close all;
col=[0 0 0;1 0 0;0 1 0;0 0 1];col_movmt=[1 0 0;0 0 1];
lnstyl={'-','--'};
m1=[1 2 4 5];ct=0;
median=false;
for chano=best_chans'%1:384
   figure();count=0;count2=0;count3=0;ct=ct+1;
    for finger=1:4
        for movmt=1:2
            count=count+1;
            asdf1=nanmean(AllData_indi_blknorm(chano,finger,movmt,:,:),5); % avg across all trials for the given condition 
            asdf1=(asdf1(:,:));
            asdf1_std=nanstd(AllData_indi_blknorm(chano,finger,movmt,:,:),[],5);
            asdf1_std=asdf1_std(:,:);
            
            asdf2=nanmean(AllData_indi_blknorm_prereach(chano,finger,movmt,:,:),5);
            asdf2=(asdf2(:,:)); 
            asdf2_std=nanstd(AllData_indi_blknorm_prereach(chano,finger,movmt,:,:),[],5);
            asdf2_std=asdf2_std(:,:);
            
            data_std=[asdf2_std asdf1_std];
            data=[asdf2 asdf1]; % this the the completed FR for the whole period averaged. 
            data=(data-repmat(mean(asdf2,2),1,size(data,2)))./repmat(std(asdf2,[],2),1,size(data,2));% normaliaing wrt the pre-reach(baseline) period 
            figure(1);
            subplot(2,3,m1(finger));      
            plot([1:size(data,2)].*20,data,'Color',col(finger,:),'LineStyle',lnstyl{movmt},'DisplayName',movementlist{movmt});grid on;
            hold on;
            lower=[data - 1.645.*(data_std)];
            higher=[data + 1.645.*(data_std)];       
            patch([(1:length(data))*20 (length(data):-1:1)*20],[higher lower(end:-1:1)],col(finger,:)...
                ,'LineStyle','none');alpha(0.3)
            
            % flex vs ext only:--------------- 
            if finger==1 % since we want it to loop only once for every flex and ext: 
                asdf3_lpp=[];asdf3_pre_lpp=[];count2=count2+1;
                for lpp=1:4
                    asdf3=AllData_indi_blknorm(chano,lpp,movmt,:,:); asdf3_pre=AllData_indi_blknorm_prereach(chano,lpp,movmt,:,:);
                    asdf3=reshape(asdf3,size(asdf3,4),size(asdf3,5)); asdf3_pre=reshape(asdf3_pre,size(asdf3_pre,4),size(asdf3_pre,5));
                    asdf3_lpp=[asdf3_lpp asdf3]; asdf3_pre_lpp=[asdf3_pre_lpp asdf3_pre];
                end
                if ~median
                    asdf3_lpp_mean=(nanmean(asdf3_lpp,2))';  asdf3_pre_lpp_mean=(nanmean(asdf3_pre_lpp,2))'; %1 X Time 
                    asdf3_lpp_std=(nanstd(asdf3_lpp,[],2))';  asdf3_pre_lpp_std=(nanstd(asdf3_pre_lpp,[],2))'; %1 X Time 
                    data3=[asdf3_pre_lpp_mean asdf3_lpp_mean]; data3_std=[asdf3_pre_lpp_std asdf3_lpp_std]; %joining and then normalizing 
                    data3=(data3-repmat(mean(asdf3_pre_lpp_mean,2),1,size(data3,2)))./repmat(std(asdf3_pre_lpp_mean,[],2),1,size(data3,2));
                end
                %median and percentile implementation: 
                if median
                    asdf3_lpp_median=(nanmedian(asdf3_lpp,2))';  asdf3_pre_lpp_median=(nanmedian(asdf3_pre_lpp,2))'; %1 X Time 
                    asdf3_lpp_prctile=(prctile(asdf3_lpp,[10 90],2))';  asdf3_pre_lpp_prctile=(prctile(asdf3_pre_lpp,[10 90],2))'; %1 X Time    
                    data3=[asdf3_pre_lpp_median asdf3_lpp_median]; data3_std=[asdf3_pre_lpp_prctile asdf3_lpp_prctile]; %joining and then normalizing 
                    data3=(data3-repmat(mean(asdf3_pre_lpp_median,2),1,size(data3,2)))./repmat(std(asdf3_pre_lpp_median,[],2),1,size(data3,2));
                end
                
                figure(1);
                subplot(2,3,3);      
                plot([1:size(data3,2)].*20,data3,'Color',col_movmt(movmt,:),'LineStyle',lnstyl{movmt},'DisplayName',movementlist{movmt});grid on;
                hold on;
                if ~median
                    lower3=[data3 - 1.645.*(data3_std)];
                    higher3=[data3 + 1.645.*(data3_std)];     
                else
                    lower3=data3_std(1,:);
                    higher3=data3_std(2,:);
                end
                    
                patch([(1:length(data3))*20 (length(data3):-1:1)*20],[higher3 lower3(end:-1:1)],col_movmt(movmt,:)...
                    ,'LineStyle','none');alpha(0.3)
                
                if count2==2
                    ax=gca; 
                    line([size(asdf3_pre_lpp_mean,2)*20 size(asdf3_pre_lpp_mean,2)*20],ax.YLim); 
                    xlabel('ms');ylabel('baseline z scored firing rate');title('Flex/ext');
                end
            end
            
            % finger comparison only:------------------ 
            if movmt==1 % since we want it to loop only once for every flex and ext: 
                asdf4_lpp=[];asdf4_pre_lpp=[];count3=count3+1;
                for lpp=1:2
                    asdf4=AllData_indi_blknorm(chano,finger,lpp,:,:); asdf4_pre=AllData_indi_blknorm_prereach(chano,finger,lpp,:,:);
                    asdf4=reshape(asdf4,size(asdf4,4),size(asdf4,5)); asdf4_pre=reshape(asdf4_pre,size(asdf4_pre,4),size(asdf4_pre,5));
                    asdf4_lpp=[asdf4_lpp asdf4]; asdf4_pre_lpp=[asdf4_pre_lpp asdf4_pre];
                end
                if ~median
                    asdf4_lpp_mean=(nanmean(asdf4_lpp,2))';  asdf4_pre_lpp_mean=(nanmean(asdf4_pre_lpp,2))'; %1 X Time 
                    asdf4_lpp_std=(nanstd(asdf4_lpp,[],2))';  asdf4_pre_lpp_std=(nanstd(asdf4_pre_lpp,[],2))'; %1 X Time    
                    data4=[asdf4_pre_lpp_mean asdf4_lpp_mean]; data4_std=[asdf4_pre_lpp_std asdf4_lpp_std]; %joining and then normalizing 
                    data4=(data4-repmat(mean(asdf4_pre_lpp_mean,2),1,size(data4,2)))./repmat(std(asdf4_pre_lpp_mean,[],2),1,size(data4,2));
                end
                %median and percentile implementation: 
                if median
                    asdf4_lpp_median=(nanmedian(asdf4_lpp,2))';  asdf4_pre_lpp_median=(nanmedian(asdf4_pre_lpp,2))'; %1 X Time 
                    asdf4_lpp_prctile=(prctile(asdf4_lpp,[10 90],2))';  asdf4_pre_lpp_prctile=(prctile(asdf4_pre_lpp,[10 90],2))'; %1 X Time    
                    data4=[asdf4_pre_lpp_median asdf4_lpp_median]; data4_std=[asdf4_pre_lpp_prctile asdf4_lpp_prctile]; %joining and then normalizing 
                    data4=(data4-repmat(mean(asdf4_pre_lpp_median,2),1,size(data4,2)))./repmat(std(asdf4_pre_lpp_median,[],2),1,size(data4,2));
                end
                
                figure(1);
                subplot(2,3,6);      
                plot([1:size(data4,2)].*20,data4,'Color',col(finger,:),'DisplayName',movementlist{movmt});grid on;
                hold on;
                if ~median
                    lower3=[data4 - 1.645.*(data4_std)];
                    higher3=[data4 + 1.645.*(data4_std)];     
                else
                    lower3=data4_std(1,:);
                    higher3=data4_std(2,:);
                end
                patch([(1:length(data4))*20 (length(data4):-1:1)*20],[higher3 lower3(end:-1:1)],col(finger,:)...
                    ,'LineStyle','none');alpha(0.3)
                
                if count3==4
                    ax=gca; 
                    line([size(asdf4_pre_lpp_mean,2)*20 size(asdf4_pre_lpp_mean,2)*20],ax.YLim); 
                    xlabel('ms');ylabel('refblock z scored firing rate');title('Indi Finger movement responses');
                end
            end
        end
        subplot(2,3,m1(finger));
        ax=gca; 
        line([size(asdf2,2)*20 size(asdf2,2)*20],ax.YLim); 
        xlabel('ms');ylabel('baseline z scored firing rate');title([finglist{finger}, 'Flex/ext']);
    end

    suptitle(sprintf('channel %d rank%d/%d ' ,chano,ct,length(best_chans)));
    figu=gcf;
    haxes = findobj(figu, 'Type', 'Axes');
    ylims=[min([haxes(2:end).YLim]) max([haxes(2:end).YLim])];
    for ug=2:length(haxes)  
        haxes(ug).YLim=ylims;
        haxes(ug).Children(1).YData=ylims;
    end
    set(gcf, 'Position', get(0, 'Screensize'));
    
    
    print([savedir sprintf('chan %d_median',chano)],'-djpeg','-r300');
    close all;
end
        
        
        
        
        
        
        
        
    