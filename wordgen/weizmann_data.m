%function weizmann_data(setting_file)
%% Script which resize weizmann data to NxN video frames
if ~exist('dir','var')
    sys_str = computer();
    if ~isempty(findstr('WIN',sys_str))
        DAT_DIR = 'C:\Pros\Data\VIDEOS\WEIZMANN\Classifcation.Dataset\';
    elseif ~isempty(findstr('GLN',sys_str))
        DAT_DIR = '/home/funzi/My.Academic/My.Codes/DATA/ACTION.REG/WEIZMANN/Classification.Dataset/';   
    else
        fprintf('Cannot find paths\n');
        return;
    end
end
DIFF = 7;
prefix = 'org';
ROW = 54;
COL = 54;
load classification_masks;
actions = {'bend','jack','jump','pjump','run','side','skip','walk','wave1','wave2'};
features = zeros(0,0);
labels = zeros(0,0);
clips = zeros(0,0);

names = fieldnames(aligned_masks); % Remember to change the below when swith the data
%% resize
for i=1:size(names,1)
    video = getfield(aligned_masks,names{i}); % Change here to swith data
    if DIFF >0
    %% GET DIFF
        video = get_vid_diff(video,DIFF);
        prefix = strcat('diff',num2str(DIFF));
    end
    frame_num = size(video,3);
    v_r   = zeros(ROW,COL,frame_num);
    for j=1:frame_num
        v_r(:,:,j) = imresize(video(:,:,j),[ROW COL]);
    end
    clips = [clips;(size(features,1)+1) (size(features,1)+frame_num)];
    features =  [features;reshape(v_r ,[ROW*COL frame_num])'];   
    labels   = [labels; find(~cellfun(@isempty,cellfun(@(x) strfind(char(names(i)),strcat('_',x)),actions,'Uniformoutput',false)))];
%     view_clip((video+1)/2,2);
%     view_clip((v_r+1)/2,2);
%     waitforbuttonpress;
end
save(strcat(DAT_DIR,prefix,'_weizmann_',num2str(ROW),'x',num2str(COL),'_aligned.mat'),'features','clips','labels','actions');
%% save features
%end