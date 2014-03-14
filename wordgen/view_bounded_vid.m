function view_bounded_vid(frames,seq)
rn = max(cellfun(@(x) (x(5)-x(1))/(x(7)-x(5)),seq.bbox)); % north ratio
rs = max(cellfun(@(x) (x(3)-x(7))/(x(7)-x(5)),seq.bbox)); % south ratio
re = max(cellfun(@(x) (x(4)-x(8))/(x(8)-x(6)),seq.bbox)); % east ratio
rw = max(cellfun(@(x) (x(6)-x(2))/(x(8)-x(6)),seq.bbox)); % west ratio

DIFF = 2;
bboxes = seq.bbox; 
sz     = size(frames,2);
%c = 1;
for f_inx = 1:sz
    bbox = bboxes{f_inx};    
    x_min = bbox(6) - round(rw*(bbox(8)-bbox(6)));
    x_max = bbox(8) + round(re*(bbox(8)-bbox(6)));
    y_min = bbox(5) - round(rn*(bbox(7)-bbox(5)));
    y_max = bbox(7) + round(rs*(bbox(7)-bbox(5)));
    
%      figure(5); imshow(double(imresize(frames(f_inx).cdata(bbox(5):bbox(7),bbox(6):bbox(8),1),[72 36]))/255);
%      waitforbuttonpress;
     
    if(x_min<=0), x_max = x_max - x_min+1; x_min = 1; end    
    if(x_max>160), x_min = x_min + 160- x_max; x_max = 160; end    
    if(y_min<=0), y_max = y_max - y_min+1; y_min = 1; end
    if(y_max>120), y_min = y_min + 120 - y_max; y_max = 120; end
    
    if(x_min<=0), x_min = 1; end
    if(y_min<=0), y_min = 1; end
    if(x_max>160),x_max = 160; end
    if(y_max>120),y_max = 120; end

     img_t = double(imresize(frames(f_inx).cdata(y_min:y_max,x_min:x_max,1),[72 36]))/255;
    if f_inx+DIFF<=sz
        bbox = bboxes{f_inx+DIFF};    
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
        
         img_tt = double(imresize(frames(f_inx+DIFF).cdata(y_min:y_max,x_min:x_max,1),[72 36]))/255;
         i_diff = img_tt-img_t;
         inx = intersect(find(i_diff<0.12),find(i_diff>-0.12));
         i_diff(inx) = 0;
         i_diff(i_diff>0) = 1;
         i_diff(i_diff<0) = -1;
         figure(1);
         subplot(1,2,1); imshow(img_t);
         subplot(1,2,2); imshow(((i_diff)+1)/2);
         %h1 = figure(1); set(h1,'Position',[100 500 36 72]); imshow(img_t);       
         %h2 = figure(2); set(h2,'Position',[300 500 36 72]); imshow(img_tt);       
         %waitforbuttonpress;
         %imwrite(((i_diff)+1)/2,strcat('/home/funzi/Documents/Experiments/pLSA_Act/tmp/vis/jog_',num2str(c),'_.png'));
         %c = c+1;   
         pause(0.05);
    end    
end
end 