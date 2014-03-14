function view_bounded_vid_(name)
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
        iix = findstr(name,'_');       
        act = name(iix(1)+1:iix(2)-1);

        vid_pth = strcat(dat_dir,act,dlm,name,'_uncomp.avi');
        bbx_pth = strrep(vid_pth,'uncomp.avi','bbx_n.mat');                
        [vid,~] = mmread(vid_pth,[],[],false,true); % Read all frame & disable the audio                                            
        load(bbx_pth);        
        for s_inx = 1:size(seq,2)          
            s_f = seq(s_inx).start;
            e_f = seq(s_inx).end;   
            view_bounded_vid(vid.frames(s_f:e_f),seq(s_inx));    
        end
end

