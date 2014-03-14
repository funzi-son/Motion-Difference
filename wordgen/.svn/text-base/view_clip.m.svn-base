function view_clip(clip_data,video)
%% Display a sequence of sihoulette images
figure();
[row col m] = size(clip_data);
if video==1
    for i=1:m    
        imshow(clip_data(:,:,i));
        pause(0.01);    
    end
else
   clip_data = reshape(clip_data,[row*col m])';   
   %imshow(reshape(clip_data(1,:),[row col]));  
   show_images(clip_data,m,row,col);
end  
end

