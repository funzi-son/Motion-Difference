% Process KTH data
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
load kth_bbx_setting;
seq_fid = fopen(strcat(dat_dir,'00sequences_.txt'),'r');
line = fgets(seq_fid);
while ischar(line)
    if findstr(line,'person')==1
        fprintf('.');
        inx = findstr(line,'frames');
        prx_fname = strtrim(line(1:inx-1))        
        iix = findstr(prx_fname,'_');
        if isempty(iix), line = fgets(seq_fid); continue; end
        act = prx_fname(iix(1)+1:iix(2)-1);
             
        line = strtrim(line(inx+length('frames'):end));
        seq_ind = strtrim(regexp(line,',','split')); 
        
        vid_pth = strcat(dat_dir,act,dlm,prx_fname,'_uncomp.avi');
        bbx_pth = strrep(vid_pth,'uncomp.avi','bbx_n.mat');                
        [vid,~] = mmread(vid_pth,[],[],false,true); % Read all frame & disable the audio                                    
        seq = repmat(struct('bbox',{},'start',0,'end',0),1,4);
        
        stg_i = max(strmatch(prx_fname,clp_names,'exact'))        
        stg = bbx_settg(stg_i,:);
        for s_inx = 1:size(seq_ind,2)
            s_inx_ = seq_ind{s_inx};
            spl = findstr(s_inx_,'-');
            st_fr = str2num(s_inx_(1:spl-1));
            ed_fr = str2num(s_inx_(spl+1:end));
            
            bbox_tmp = {};
            s_f = 0;
            e_f = 0;
            for f_inx = st_fr:ed_fr
                img = double(vid.frames(f_inx).cdata(:,:,1))/255;
                [bbx stg] = find_boundingbox(img,stg);
                if ~isempty(bbx)
                    if s_f==0, s_f = f_inx; end
                    e_f = f_inx;
                    bbox_tmp = [bbox_tmp bbx];
                else
                    if s_f >0 
                        if (f_inx-s_f)>10 || (f_inx-st_fr)/(ed_fr-st_fr)>2/3
                            break; 
                        else
                            s_f = 0;
                            e_f = 0;
                            bbox_tmp = {};
                        end                        
                    end
                    fprintf('%d\n%s\n',f_inx,vid_pth); 
                end                
            end
            seq(s_inx).bbox  = bbox_tmp;            
            seq(s_inx).start = s_f;
            seq(s_inx).end   = e_f;
            %disp([s_f e_f]);                   
            %pause();
            view_bounded_vid(vid.frames(s_f:e_f),seq(s_inx));               
        end
        %fprintf('Saving to %s\n',bbx_pth);
        if isempty(stg_i)
            clp_names = [clp_names;prx_fname]; 
            bbx_settg = [bbx_settg;stg];            
        else
            bbx_settg(stg_i,:) = stg;
        end
        save('kth_bbx_setting','clp_names','bbx_settg');
        save(bbx_pth,'seq');
        fprintf('Boundingbox saved ....\n');
       % classify_clip(vid_pth,'/home/funzi/Documents/Experiments/pLSA_Act/tmp/none_0_words_1000_20131025T012347_NB.mat');
        waitforbuttonpress;            
        %pause();
    elseif isempty(strtrim(line))
        fprintf('\n');
    end                           
    line = fgets(seq_fid);
end


act_names = {'boxing','handclapping','handwaving','jogging','running','walking'};

scenario = [1 2 3 4]; %1: Static homogenous background 2: Scale variations 3: Different clothes    4: Lighting variations 

for act_inx = 1:6    
        act = act_names{act_inx};
        
end

clear all;