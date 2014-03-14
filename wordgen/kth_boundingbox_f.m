%This script convert KTH boundingbox txt file to mat file
sys_str = computer();
if ~exist('dat_dir','var')
    if ~isempty(findstr('WIN',sys_str))   
        dat_dir = 'C:\Pros\Data\VIDEOS\KTH\'
        dlm = '\'; 
    elseif ~isempty(findstr('GLN',sys_str))    
        dat_dir = '/home/funzi/My.Academic/My.Codes/DATA/ACTION.REG/KTH/';
        dlm = '/';
    else
        fprintf('Cannot find paths\n');
        return;
    end
end
act_names = {'boxing','handclapping','handwaving','jogging','running','walking'};

for act_name = act_names
    f_name = strcat(dat_dir,act_name,dlm,'*.mat');
    delete(f_name{1});
end

bbox_fid = fopen(strcat(dat_dir,'KTHBoundingBoxInfo.txt'),'r');

line = fgets(bbox_fid);
line = fgets(bbox_fid);
line = fgets(bbox_fid);
line = fgets(bbox_fid);
line = fgets(bbox_fid);

while ischar(line)    
    nums = regexp(line,'\s','split');    
    person_num = nums{1}
    if length(nums{1})==1, person_num = strcat('0',nums{1}); end
    scenar_num = nums{2};
    action_num = str2num(nums{3}); act_name = act_names(action_num);
    sequen_num = str2num(nums{4});
    
    file_name  = strcat(dat_dir,act_name,dlm,'person',person_num,'_',act_name,'_d',scenar_num,'_bbox.mat');
    file_name  = file_name{1};
        
    if exist(file_name,'file')
        load(file_name); 
    else
        seq = repmat(struct('bbox',{},'start',0,'end',0),1,4);
    end
    seq(sequen_num).start  = str2num(nums{5});
    seq(sequen_num).end    = str2num(nums{6});
    count = 7;
    bbox_tmp = {};
    for fr_inx = seq(sequen_num).start:seq(sequen_num).end
        bb = [str2num(nums{count}) str2num(nums{count+1}) str2num(nums{count+2}) str2num(nums{count+3})];        
        bbox_tmp = [bbox_tmp bb];        
        count = count + 4;
    end    
    seq(sequen_num).bbox  = bbox_tmp;
    
    save(file_name,'seq');
    line = fgets(bbox_fid);
end
fclose(bbox_fid);