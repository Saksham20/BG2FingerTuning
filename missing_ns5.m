
% SCRIPT TO FIND THE MISSING NS5 FILES: 
arrayNames = {'_Lateral','_Medial'};
sessnos=unique(OL_blocks_new(2,:));
errNsp=[];
sessionDir='G:\Active Projects\BG2 Data\t8';
for i=1:14
    for a=1:2
        sessnum=sessnos(i);
        blknos=OL_blocks_new(1,(OL_blocks_new(2,:)==sessnum));
        blknos=[1 blknos];
        for j=1:numel(blknos)
            
            nsps=dir([sessionDir filesep sessnames{1,i} filesep 'Data\' arrayNames{a} filesep 'NSP Data\' '*(' num2str(blknos(j)) ')*']);
            if ~(numel({nsps.name})==4)
                errNsp=[errNsp;sessnum a blknos(j)];
            end
        end
    end
end
