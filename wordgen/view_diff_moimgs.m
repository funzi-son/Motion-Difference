DAT_FILE = '/home/funzi/My.Academic/My.Codes/DATA/ACTION.REG/KTH/diff5_kth_2_lowal_thr0.1_72x36.mat';
%'boxing','handclapping','handwaving','jogging','running','walking';
% trn_pers_num = [11, 12, 13, 14, 15, 16, 17, 18];
% evl_pers_num = [19, 20, 21, 23, 24, 25, 01, 04];
% tst_pers_num = [22, 02, 03, 05, 06, 07, 08, 09, 10];

%/home/funzi/My.Academic/My.Codes/DATA/ACTION.REG/KTH/jogging/person07_jogging_d1_uncomp.avi
person_id = 6;
action_id = 3;
vid_id = (person_id-1)*6 + action_id;
dat_tp = 3; % 1: training, 2: evalulation 3: testing
switch dat_tp
    case 1
        features = load(DAT_FILE, 'trn_ftr','trn_clp');
        inx = features.trn_clp(vid_id,:);
        imgs = features.trn_ftr(inx(1):inx(2),:);
    case 2
        features = load(DAT_FILE, 'evl_ftr','evl_clp');
        inx = features.evl_clp(vid_id,:);
        imgs = features.evl_ftr(inx(1):inx(2),:);
    case 3
        features = load(DAT_FILE, 'tst_ftr','tst_clp');
        inx = features.tst_clp(vid_id,:);
        imgs = features.tst_ftr(inx(1):inx(2),:);
end
clear features;

for i=1:size(imgs,1)
    img = reshape(imgs(i,:),[72 36]);
    imshow((img+1)/2);
    waitforbuttonpress;
    %pause(0.05);
end



