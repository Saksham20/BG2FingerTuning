for c=1
            disp(['Channel ' num2str(c)]);
            data = zeros(1, arrayLen);
            ns5Breaks = [];
            breakIdx = 1;
            % SS:
            disp('extracting ref block');
            fileName_ref = getNS5FileName([sessionDir filesep sessionList{s,1}], arrayNames{a}, 1);% since 1st blk is ref 
            neuralData_ref = openNSx_v620(fileName_ref, 'read', ['c:' num2str(c)]);
            disp('done extn');
            
            for b=1:length(sessionList{s,2})
                fileName = getNS5FileName([sessionDir filesep sessionList{s,1}], arrayNames{a}, sessionList{s,2}(b));
                neuralData = openNSx_v620(fileName, 'read', ['c:' num2str(c)]);
                slcData = LoadSLC(sessionList{s,2}(b), [sessionDir filesep sessionList{s,1}]);
                
                if medToLatDelay_30ksps(b) == 0 %if automatic alignment occurred during session              
                    neuralData.Data = neuralData.Data{end};
                else %perform offline alignment
                    [neuralData.Data, lateralTimeStamp(b), medialTimeStamp(b)] = ...
                        alignNSPandSLCData(neuralData.Data, a, medToLatDelay_30ksps(b), lateralTimeStamp(b), medialTimeStamp(b), slcData);
                end  
                
                %Trim data so that it ends when SLC stops recording
                neuralData.Data = trimNSPtoSLCSize(neuralData.Data, slcData);
                %trimNSPtoSLCSize(neuralData.Data, medToLatDelay_30ksps(b), lateralTimeStamp(b), medialTimeStamp(b), slcData);
                data(breakIdx:(breakIdx+length(neuralData.Data)-1))=double(neuralData.Data);
                breakIdx = breakIdx + length(neuralData.Data);
                ns5Breaks = [ns5Breaks, breakIdx-1];
                toc
            end %blocks
                        
            try
                save('tmp','data');
                data_ref=double(neuralData_ref.Data{end});
                Get_spikes; % added an additional 'data_ref' ns5 file from 1st blk of every session
                Do_clustering;
                load('tmp_spikes.mat','index');
                save('times_tmp.mat','index','ns5Breaks','-append');
                % results dir: 'D:\Working Data Folder\BG2 T8 Results';
                newFileName = [resultsDirRoot filesep 'HighResFeatures' filesep sessionList{s,1} filesep 'chan' num2str(c+globalChanOffset) ' sorted spikes.mat'];
                copyfile('times_tmp.mat',newFileName);
                
                newFileName = [resultsDirRoot filesep 'HighResFeatures' filesep sessionList{s,1} filesep 'chan' num2str(c+globalChanOffset) ' sorted spikes.jpg'];
                copyfile('fig2print_tmp.jpg',newFileName);
                disp('done saving channel');
                toc
            catch
                disp('What''s going on here?');
            end
            close all;
end %channels

%% checking of all the ns5 data is alligned ( if the ns5file.data is a cell or not)

% first run the first section of the high res features code that  generates my sessList
check=cell(2,numel(sessnames));disp('running');tic
for a=1:numel(sessnames)
    for b=1:numel(arrayNames)
        temp=zeros(1,length(sessionList{a,2}));
        for c=1:length(sessionList{a,2})
        fileName = getNS5FileName([sessionDir filesep sessionList{a,1}], arrayNames{b}, sessionList{a,2}(c));
        neuralData = openNSx_v620(fileName, 'read', 'c:1');
        temp(1,c)=double(iscell(neuralData.Data));
        
        end
        check{b,a}=temp;
    end
end
disp('done');toc        

%% moving new slc files in a new folder so sthat its accessble by LoadSLC function

for i=2:14
    tempdir=dir([sessionDir filesep sessionList{i,1} filesep 'Data\Extracted Data\*.mat']);
    nams={tempdir.name};
    if ~exist([sessionDir filesep sessionList{i,1} filesep 'Data\Extracted Data\Data\SLC Data'],'dir')
        mkdir([sessionDir filesep sessionList{i,1} filesep 'Data\Extracted Data\Data\SLC Data']);
    end
    for j=1:numel(nams)
        movefile([sessionDir filesep sessionList{i,1} filesep 'Data\Extracted Data\' nams{j}],...
            [sessionDir filesep sessionList{i,1} filesep 'Data\Extracted Data\Data\SLC Data\' nams{j}]); 
    end
end

%% checkning the siae of all field values in slc files. 
%THis will be used to update the JoinSLC code to also join the nctx events which are default length *300
        

struct=slc_old_blk5;
disp('starting checksize');
Size=checksize(struct);
disp('done ');
testlength=cellfun(@(x) any(ismember(x,300*length(struct.clocks.nspClock))),Size,'UniformOutput',false);
testlength=cell2mat(testlength);
tottestlength=sum(testlength);


function Size=checksize(struct)
    flds=fieldnames(struct);
    Size=cell(0);
    for i=1:numel(flds)
        if ~isreal(i)
            pause;
        end
        eval(['sub_val = struct.' flds{i} ';']);
        if isstruct(sub_val)
            sizee=checksize(sub_val);
        else 
            sizee=size(sub_val);
            sizee={sizee};
        end
        Size=[Size,sizee];
    end
end



        
        