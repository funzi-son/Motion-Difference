function gen_kth_data(dat_dir,dlm,act_dat_name,DIFF,ROW,COL,THRESHOLD )
% Process KTH data
if DIFF==0
    prefix = 'org';
else
    prefix = strcat('diff',num2str(DIFF));
end


trn_pers_num = [11, 12, 13, 14, 15, 16, 17, 18];
evl_pers_num = [19, 20, 21, 23, 24, 25, 01, 04];
tst_pers_num = [22, 02, 03, 05, 06, 07, 08, 09, 10];

dataset_ = {trn_pers_num evl_pers_num tst_pers_num};

dd_names  = {'trn' 'evl' 'tst'};

act_names = {'boxing','handclapping','handwaving','jogging','running','walking'};

scenario = [1 2 3 4]; %1: Static homogenous background 2: Scale variations 3: Different clothes    4: Lighting variations 

all_names = {};
%sve_name = strcat(dat_dir,prefix,'_kth_all_lowal_','thr',num2str(THRESHOLD),'_',num2str(ROW),'x',num2str(COL),'.mat');
sve_name = act_dat_name;
for sce = scenario
    trn_ftr  = [];
    evl_ftr  = [];
    tst_ftr  = [];

    trn_clp  = [];
    evl_clp  = [];
    tst_clp  = [];

    trn_lab  = [];
    evl_lab  = [];
    tst_lab  = [];
    fprintf('Scenario %d\n',sce);
    %strcat(dat_dir,prefix,'_kth_',num2str(sce),'_lowal_','thr',num2str(THRESHOLD),'_',num2str(ROW),'x',num2str(COL),'.mat');
    save_name = strrep(sve_name,'all',num2str(sce));    
    all_names = [all_names; save_name];
    if exist(save_name,'file'), delete(save_name); end
    clip_inx  = 0;
for dds = 1:3
    fprintf('Dataset: %s\n',dd_names{dds});
    for person_num = dataset_{dds}
    tic;
    fprintf('\nPerson %d\n',person_num);
    for act_inx = 1:6    
        act = act_names{act_inx};
        
        vid_pth = strcat(dat_dir,act,dlm,'person',sprintf('%02d',person_num),'_',act,'_d',num2str(sce),'_uncomp.avi');            
        f_s = dir(vid_pth);                  
        
        for i = 1:size(f_s,1)        
            fprintf('.');
            vid_pth = strcat(dat_dir,act,dlm,f_s(i).name);        
            [vid,~] = mmread(vid_pth,[],[],false,true); % Read all frame & disable the audio

            bbx_pth = strrep(vid_pth,'uncomp.avi','bbx_n.mat');            

            load(bbx_pth);                

            tmp_seq = [];           
            for seq_num = 1:size(seq,2)
                if isempty(seq(seq_num)), continue; end
                %% Using same-size boundingbox
                 %wmax = max(cellfun(@(x) x(4)-x(2),seq(seq_num).bbox));
                 %hmax = max(cellfun(@(x) x(3)-x(1),seq(seq_num).bbox));
                 %bboxes = cellfun(@(x) round([(x(1) + x(3) - hmax)/2,(x(2) + x(4) - wmax)/2 ...
                 %   (x(1)+x(3)+hmax)/2, (x(2) + x(4) + wmax)/2]),seq(seq_num).bbox,'UniformOutput',false);
               %% Using the infimas
    %             ymin = min(cellfun(@(x) x(1),seq(seq_num).bbox));
    %             xmin = min(cellfun(@(x) x(2),seq(seq_num).bbox));
    %             ymax = max(cellfun(@(x) x(3),seq(seq_num).bbox));
    %             xmax = max(cellfun(@(x) x(4),seq(seq_num).bbox));
    
               %% Using ratio
                rn = max(cellfun(@(x) (x(5)-x(1))/(x(7)-x(5)),seq(seq_num).bbox)); % north ratio
                rs = max(cellfun(@(x) (x(3)-x(7))/(x(7)-x(5)),seq(seq_num).bbox)); % south ratio
                re = max(cellfun(@(x) (x(4)-x(8))/(x(8)-x(6)),seq(seq_num).bbox)); % east ratio
                rw = max(cellfun(@(x) (x(6)-x(2))/(x(8)-x(6)),seq(seq_num).bbox)); % west ratio


                bboxes = seq(seq_num).bbox;
                count = 0;

                for f_inx = seq(seq_num).start:seq(seq_num).end           
                    count = count + 1;
                    bbox = bboxes{count};                
%                      if bbox(1)<=0, bbox(3) = bbox(3)- bbox(1)+1; bbox(1) = 1; end
%                      if bbox(2)<=0, bbox(4) = bbox(4)- bbox(2)+1; bbox(2) = 1; end
%                      if bbox(3)>120,bbox(1) = bbox(1) + 120 - bbox(3);bbox(3) = 120; end
%                      if bbox(4)>160,bbox(2) = bbox(2) + 160 - bbox(4);bbox(4) = 160; end                    


                    %%Using ratio
                    x_min = bbox(6) - round(rw*(bbox(8)-bbox(6)));
                    x_max = bbox(8) + round(re*(bbox(8)-bbox(6)));
                    y_min = bbox(5) - round(rn*(bbox(7)-bbox(5)));
                    y_max = bbox(7) + round(rs*(bbox(7)-bbox(5)));
                    if(x_min<=0), x_max = x_max - x_min+1; x_min = 1; end    
                    if(x_max>160), x_min = x_min + 160- x_max; x_max = 160; end    
                    if(y_min<=0), y_max = y_max - y_min+1; y_min = 1; end
                    if(y_max>120), y_min = y_min + 120 - y_max; y_max = 120; end

                    if(x_min<=0), x_min = 1; end
                    if(y_min<=0), y_min = 1; end
                    if(x_max>160),x_max = 160; end
                    if(y_max>120),y_max = 120; end
                    
                    img_t = double(imresize(vid.frames(f_inx).cdata(y_min:y_max,x_min:x_max,1),[ROW COL]))/255;
                    if DIFF==0                                            
                        tmp_seq = [tmp_seq; img_t(:)'];
                    else
                        if f_inx<=seq(seq_num).end-DIFF                                  
%                             if bbox_(1)<0, bbox_(3) = bbox_(3)- bbox_(1); bbox_(1) = 0; end
%                             if bbox_(2)<0, bbox_(4) = bbox_(4)- bbox_(2); bbox_(2) = 0; end
%                             if bbox_(3)>120,bbox_(1) = bbox_(1) + 120 - bbox_(3);bbox_(3) = 120; end
%                             if bbox_(4)>160,bbox_(2) = bbox_(2) + 160 - bbox_(4);bbox_(4) = 160; end                    
                                
                                
                                bbox = bboxes{count+DIFF};    
                                x_min = bbox(6) - round(rw*(bbox(8)-bbox(6)));
                                x_max = bbox(8) + round(re*(bbox(8)-bbox(6)));
                                y_min = bbox(5) - round(rn*(bbox(7)-bbox(5)));
                                y_max = bbox(7) + round(rs*(bbox(7)-bbox(5)));
                                if(x_min<=0), x_max = x_max - x_min+1; x_min = 1; end            
                                if(x_max>160), x_min = x_min + 160- x_max; x_max = 160; end    
                                if(y_min<=0), y_max = y_max - y_min+1; y_min = 1; end
                                if(y_max>120), y_min = y_min + 120 - y_max; y_max = 120; end

                                if(x_min<=0), x_min = 1; end
                                if(y_min<=0), y_min = 1; end
                                if(x_max>160),x_max = 160; end
                                if(y_max>120),y_max = 120; end

                                 img_tt = double(imresize(vid.frames(f_inx+DIFF).cdata(y_min:y_max,x_min:x_max,1),[ROW COL]))/255;
                                 i_diff = img_tt-img_t;
                                 inx = intersect(find(i_diff<THRESHOLD),find(i_diff>-1*THRESHOLD));
                                 i_diff(inx) = 0;
                                 i_diff(i_diff>0) = 1;
                                 i_diff(i_diff<0) = -1;
%                                  subplot(1,2,1); imshow(img_t);
%                                  subplot(1,2,2); imshow(((i_diff)+1)/2);
%                                  pause(0.05);         
                             tmp_seq = [tmp_seq;i_diff(:)'];                             
                        end
                    end
                end
                %waitforbuttonpress;
            end

            if dds == 1
                trn_clp = [trn_clp;[size(trn_ftr,1)+1 0]];
                trn_ftr = [trn_ftr;tmp_seq];
                trn_clp(end,2) = trn_clp(end,1) + size(tmp_seq,1) - 1;                
                trn_lab = [trn_lab;act_inx];
            elseif  dds == 2
                evl_clp = [evl_clp;[size(evl_ftr,1)+1 0]];
                evl_ftr = [evl_ftr;tmp_seq];  
                evl_clp(end,2) = evl_clp(end,1) + size(tmp_seq,1) - 1;                
                evl_lab = [evl_lab;act_inx];
            else
                tst_clp = [tst_clp;[size(tst_ftr,1)+1 0]];
                tst_ftr = [tst_ftr;tmp_seq];
                tst_clp(end,2) = tst_clp(end,1) + size(tmp_seq,1) - 1;                
                tst_lab = [tst_lab;act_inx];
            end                
        end          
    end
    toc;  
    end    
    if exist(save_name,'file')
        save(save_name,strcat(dd_names{dds},'_ftr'),strcat(dd_names{dds},'_clp'),strcat(dd_names{dds},'_lab'),'-append');
    else
        save(save_name,strcat(dd_names{dds},'_ftr'),strcat(dd_names{dds},'_clp'),strcat(dd_names{dds},'_lab'));
    end
    clear(strcat(dd_names{dds},'_ftr'),strcat(dd_names{dds},'_clp'),strcat(dd_names{dds},'_lab'));
end
end
clearvars -except sve_name all_names;
%% Get all in one
a_trn_ftr = [];
a_trn_clp = [];
a_trn_lab = [];

a_evl_ftr = [];
a_evl_clp = [];
a_evl_lab = [];

a_tst_ftr = [];
a_tst_clp = [];
a_tst_lab = [];

for i=1:size(all_names,1)
    load(all_names{i},'trn_ftr','trn_lab','trn_clp');
    a_trn_clp = [a_trn_clp; trn_clp + size(a_trn_ftr,1)];
    a_trn_ftr = [a_trn_ftr; trn_ftr];
    a_trn_lab = [a_trn_lab; trn_lab];    
end
trn_ftr = a_trn_ftr;
trn_lab = a_trn_lab;
trn_clp = a_trn_clp;
save(sve_name,'trn_ftr','trn_lab','trn_clp');
clear a_trn_ftr a_trn_lab a_trn_clp trn_ftr trn_lab trn_clp;

for i=1:size(all_names,1)
    load(all_names{i},'evl_ftr','evl_lab','evl_clp');
    a_evl_clp = [a_evl_clp; evl_clp + size(a_evl_ftr,1)];
    a_evl_ftr = [a_evl_ftr; evl_ftr];
    a_evl_lab = [a_evl_lab; evl_lab];    
end
evl_ftr = a_evl_ftr;
evl_lab = a_evl_lab;
evl_clp = a_evl_clp;
save(sve_name,'evl_ftr','evl_lab','evl_clp','-append');
clear a_evl_ftr a_evl_lab a_evl_clp evl_ftr evl_lab evl_clp;

for i=1:size(all_names,1)
load(all_names{i},'tst_ftr','tst_lab','tst_clp');
a_tst_clp = [a_tst_clp; tst_clp + size(a_tst_ftr,1)];
a_tst_ftr = [a_tst_ftr; tst_ftr];
a_tst_lab = [a_tst_lab; tst_lab];
end
tst_ftr = a_tst_ftr;
tst_lab = a_tst_lab;
tst_clp = a_tst_clp;
save(sve_name,'tst_ftr','tst_lab','tst_clp','-append');
clear all;
end

