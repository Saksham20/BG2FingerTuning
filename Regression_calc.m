
%% Regression/Coeff for the above generated data: 
% checking the relation between the FR for each channel with each of the condition's posvector_inverted: 
saveloc='G:\Personal Folders\Sharda, Saksham\codes2.0\figures\';
mkdir([saveloc 'histograms']);
b=zeros(384,2,4,2);
stat=zeros(384,4,4,2);
disp('starting');
for i=1:4
    for j=1:2
        good_id=ReachType_indi1(1,i,j,:,:);
        good_id(isnan(good_id))=[];
        good_id=logical(reshape(good_id,1,[]));
        
        X=PosVec_indi1(1,i,j,:,:);
        X(isnan(X))=[];
        X=reshape(X,1,[]);
        X=X(good_id);
        
        for chano=1:384
            Y=AllData_indi(chano,i,j,:,:);
            Y(isnan(Y))=[];
            Y=reshape(Y,1,[]);
            Y=Y(good_id);
            
            [b(chano,:,i,j),~,~,~,stat(chano,:,i,j)] = regress((Y'),[ones(size(X,2),1) X']);
            % below code is the plot the trial vise FR for each channel. Overlaying all those traces by looping. 
%             figure();bval=reshape(b(chano,:,i,j),1,[]);
%             
%             Y_mean=zeros(1,size(AllData_indi,4));count=0;
%             for t=1:size(AllData_indi,5)
%                 if ~all(isnan(AllData_indi(chano,i,j,:,t))); % picking only those trails where there is mvoement 
%                     Y1=AllData_indi(chano,i,j,:,t);X1=PosVec_indi1(1,i,j,:,t);
%                     Y1=reshape(Y1,1,[]);X1=reshape(X1,1,[]);
%                     figure(3);plot(X1,Y1,'-r');hold on; 
%                     plot(X1',[ones(size(X1,2),1) X1']*bval','-b','LineWidth',2);hold off;  
%                     figure(4);plot(Y1,'*');hold on;
%                     close Figure 3;
%                     Y_mean=Y_mean+Y1;
%                     count=count+1;
%                 end
%             end
%             figure(4);plot(Y_mean./count); % PSTH for each channel. 
%             %plot(X,Y,'*');hold on;plot(X',[ones(size(X,2),1) X']*bval','-b');
%             close all;
        end
        r2vals=stat((stat(:,3,i,j)<0.05),1,i,j);
        figure();histogram(r2vals);title(sprintf('PosVecInverted, NORMED finger %d, state %d',i,j),'Interpreter', 'none');
        print([saveloc 'histograms\' sprintf('finger %d, state %d PosVecInverted NORMED',i,j)],'-djpeg','-r300');
        close all;
        fprintf('done for finger %d, state %d \n',i,j);
    end
end
disp('done');