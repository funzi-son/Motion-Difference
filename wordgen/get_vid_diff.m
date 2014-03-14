function vid = get_vid_diff(video,step)
vid = zeros(size(video,1),size(video,2),size(video,3)-step);
for i=1:size(vid,3)
    vid(:,:,i) = video(:,:,i+step) - video(:,:,i);
end

end