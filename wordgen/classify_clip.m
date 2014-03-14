function classify_clip(vid_pth,mod_pth)

DIFF = 5;
ROW = 72;
COL = 36;
THRESHOLD = 0.1;                           

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
                         tmp_seq = [tmp_seq;i_diff(:)'];                             
                    end
                end
        end
                %waitforbuttonpress;
end

load(strrep(mod_pth,'_NB',''),'C');

vwords = assign_words(tmp_seq,C);
dat = zeros(1,size(C,1));
occ = accumarray(vwords',1)';
dat(1:size(occ,2)) = occ;

if exist(mod_pth,'file')
    fprintf('Found the model, loading ...\n');
    load(mod_pth,'model');
    
else
    fprintf('Model is not found, training ...\n');
    load(strrep(mod_pth,'_NB',''),'trn_dat','trn_lab');
    conf.prior = 0;
    conf.laplace_smooth = 1;
    model = nb_train(conf,trn_dat,trn_lab);
    save(mod_pth,'model');
    clear trn_dat trn_lab;
end
    
    probs = nb_classify(model,dat);
    disp(probs)
    [~, output] = max(probs,[],2);
    fprintf('Ac id = %d',output)
end