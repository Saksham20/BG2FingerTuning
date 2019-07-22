function [events_out] = ncTX_events_join(slcdir,blknos)


events_out=[];

for k=blknos
    tempslc=dir([slcdir filesep 'Data\Extracted Data\Data\SLC Data\*(' num2str(k) ').mat']);
    load([slcdir filesep 'Data\Extracted Data\Data\SLC Data\' tempslc.name],'ncTX');

    events_out=[events_out;sparse(ncTX.events)];
end

end

