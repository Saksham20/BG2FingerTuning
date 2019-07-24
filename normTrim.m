function [transfdata] = normTrim(data,dim,trmamt, trimsype)
%this transforms the data to make it normal .. or least attempting !
% trimtype: 'remove'  OR 'winsorize' 
sz=size(data);
nodims=1:length(sz);
nontransdims=setdiff(nodims,dim);

data=permute(data,[dim, nontransdims]);

data=reshape(data,sz(dim),[]);
data=sort(data,1);
datasize_id=sum(~isnan(data),1);
databorder_id=[ceil(datasize_id*(trmamt/2)/100); floor(datasize_id*(100-(trmamt/2))/100)];
switch trimsype
    case 'remove'
        for i=1:size(data,2)
            data(1:(databorder_id(1,i))-1,i)=NaN; 
            data(((databorder_id(2,i))+1):datasize_id,i)=NaN;
        end
    case 'winsorize' 
        for i=1:size(data,2)
            data(1:(databorder_id(1,i))-1,i)=data(databorder_id(1,i),i); 
            data(((databorder_id(2,i))+1):datasize_id,i)=data(databorder_id(2,i),i);
        end
end
recomdims([dim, nontransdims])=nodims;
transfdata=reshape(data,sz(recomdims));
end

