function show_grouped_dat(dat, fig_inx)
[~,inx] = sort(rem(0:size(dat,1)-1,6)+1);
figure(fig_inx); imagesc(dat(inx,:)); colorbar;
end
