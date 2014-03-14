function save_images(name,Is,num,img_row,img_col)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save num images in Is                                                   %
% sontran2012                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if num>1000, num = 100; end;
N = 4;
col = floor(sqrt(num));
row = ceil(num/col);
gap = 2;
pos = ones(1,col*row);
pos = cumsum(pos);
pos = vec2mat(pos,col);
bigImg = zeros(row*img_row + (row-1)*gap,col*img_col + (col-1)*gap);
for i=1:row
    if i>N, break; end
    for j=1:col
        y = 1 + (i-1)*(img_row+gap);
        x = 1 + (j-1)*(img_col+gap);
        if pos(i,j) <= num, bigImg(y:y+img_row-1,x:(x+img_col-1)) = reshape(Is(pos(i,j),:),img_row,img_col); end;
    end
    
end
%bigImg = bigImg(1:N*40+(N-1)*gap,:);
imwrite(bigImg,strcat(name,'.png'),'PNG');
end


