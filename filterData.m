function [filteredData] = filterData(AllData_indi,windowsize)
%% this function smooths data. 

%implementation of a gaussian smoothning filter: 
% if strcmp(type,'gaussian')
%     wght=normpdf(linspace(-2,2,windowsize*2));wght=wght(windowsize:end);
%     normalize=(1/sum(wght));
% elseif strcmp(type,'boxcar')
%     wght=ones(1,windowsize);
%     normalize=1/windowsize;
% end
% b=normalize*wght;
% a=1;
sz=size(AllData_indi);
filteredData=NaN*ones(sz);

for chano=1:sz(1)
    for finger=1:sz(2)
        for movt=1:sz(3)
            for trl=1:sz(5)
                currdata=AllData_indi(chano,finger,movt,:,trl);
                currdata=reshape(currdata,sz(4),[]);
                currdata=currdata(~isnan(currdata));
                %filtereddat=filter(b,a,currdata);
                filtereddat=smooth(currdata,windowsize,'lowess');
                filtereddat=reshape(filtereddat,1,1,1,length(filtereddat),1);
                filteredData(chano,finger,movt,1:length(filtereddat),trl)=filtereddat;
            end
        end
    end
end
        
       
end

