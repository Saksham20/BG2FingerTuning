function [] = plotBOX(data,labels,loc,type,goodchans,lagtime,windowsize)
%will plot channel wise blox plots of data based on the groups in labels.
%TO visualize the symmetry of each feature and group data. 
if ~mkdir(loc)
    mkdir(loc)
end
labelslist=unique(labels);
col={'r','b'};
chans=(unique(cell2mat(goodchans)));
if size(chans,1)>1
    chans=chans';
end
factors={'-fingers-','-flext-','-interaction-'};
    if type=='sem'
        for ch=chans
            pltdat=zeros(1,length(labelslist));errdat=zeros(1,length(labelslist));
            for i=1:length(labelslist)
                id=(labels==labelslist(i));
                mn=mean(data(id,ch));
                se=std(data(id,ch))/sqrt(sum(id));
                pltdat(1,i)=mn;errdat(1,i)=se;
            end
            figure(2); 
            dat1=[pltdat(1:2:end);errdat(1:2:end)];dat1(:,[2,1,3,4])=dat1;
            dat2=[pltdat(2:2:end);errdat(2:2:end)];dat2(:,[2,1,3,4])=dat2;
            errorbar([1:length(labelslist)/2],dat1(1,:),dat1(2,:),'Color',col{1});hold on;
            errorbar([1:length(labelslist)/2],dat2(1,:),dat2(2,:),'Color',col{2});hold off;
            nameidx=zeros(1,size(goodchans,2));
            for u=1:size(goodchans,2)
                nameidx(1,u)=ismember(ch,goodchans{1,u});
            end
            legend({'flex','ext'});title({sprintf('channel%d(winsorized), lagtime=%dms, window=%dms',ch,lagtime*20,windowsize),...
                [factors{logical(nameidx)}] });
            ax=gca; ax.XLim=[0 5]; ax.XTick=[0 1 2 3 4 5];
            ax.XTickLabels={'','TRP','Index','ThumbF/E','ThumbAb/Ad',''};
            ylabel(' Change from baseline Avg. Firing Rate');
            print([loc filesep sprintf('chano%d',ch)], '-djpeg','-r300');
            close all; 
        end
        
        
%     for ch=1:size(data,2)
%         figure(2)
%         col=hsv(2);
%         for i=(unique(labels(:,2)))' 
%             pltdat=[];errdat=[];
%             for j=(unique(labels(:,1)))'
%                 goodid=((labels(:,1)==j) & (labels(:,2)==i));
%                 mn=mean(data(goodid,ch));
%                 se=(std(data(goodid,ch)))/sqrt(sum(goodid));
%                 pltdat=[pltdat,mn];
%                 errdat=[errdat,1.96*se];
%             end
%             figure(2);
%             errorbar([1:length(unique(labels(:,i)))],pltdat,errdat,'Color',col(i,:));
%             hold on;
%         end
%         figure(2);
%         legend({'flext','finger'});title(sprintf('channel%d',ch));
%         %ax=gca; ax.xTickLabel    
%     end
    
    elseif type =='box' && box
        for i=1:size(data,2)
            figure(1)
            boxplot(data(:,i),labels)
            print([loc filesep sprintf('chano%d',i)], '-djpeg','-r300');
            close figure 1; 
        end
    end
    
end

