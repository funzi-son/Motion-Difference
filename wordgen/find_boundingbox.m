function [bbx setting] = find_boundingbox(img,setting)
%setting = [];
setting
if ~isempty(setting)
    Ty = setting(1);
    Tx = setting(2);

    Ty_ = setting(3);
    Tx_ = setting(4);    
    g   = setting(5);
    th  = setting(6);
else    
      Ty = 0.017;
      Tx = 0.001;
  
      Ty_ = 0.02;
      Tx_ = 0.001;    
      g   = 5;
      th  = 0.15;
      setting = [Ty Tx Ty_ Tx_ g th];
end
bbx = [];

figure(1);
subplot(2,3,4); imshow(img);
% image gradient

[gx gy] = gradient(gauss2d(g,1));
Ix = conv2(img,gx,'same');
Iy = conv2(img,gy,'same');

I = sqrt(Ix.*Ix + Iy.*Iy);
I(I<th*max(max(I))) = 0;
%I(I<mean(mean(I))) = 0;
%% remove conner objects
% I(1:20,1:20) = 0;
% I(end-10:end,1:40) = 0;
% I(end-10:end,end-20:end) = 0;
%% remove top line
for k=1:25
    if sum(I(k,1:10)>0)>=9, I(k,:)  =0; end    
    if sum(I(k,end-10:end)>0)>=9, I(k,:)  =0; end    
end
for k=26:30
     if sum(I(k,end-10:end)>0)>=9, I(k,max(find(I(k,:)==0)):end)  =0; end    
end

%% remove bottom small objects
I(end-10:end,1:end) = 0;

subplot(2,3,6); imshow(I);%imagesc(a);
% find bbx width
% (sum(I,1)/size(I,1)) >0.01
% pause();
p = ceil(g/2);
%(sum(I,1)/size(I,1))
inx = (sum(I,1)/size(I,1)) > Ty;



inx(1:p) = 0;
inx(end-p:end) = 0;
c = inx;
subplot(2,3,3); imshow(repmat(c,50,1));
%disp([sum(inx(p+1:p+6)) sum(inx(p+1:p+10))]);
sum(inx(p+1:p+20))
%6 as normal 30 for boxing and clapping with shadow
if sum(inx(p+1:p+6))>=1 || inx(end-p-1) ==1    
    if sum(inx(70:90))>1 && sum(inx(p+1:p+20))<15   
        t = find(inx,1);
        inx(t:t+find(inx(t:80)==0,1)) = 0;
        % for east side
    else
        %fprintf('...%d',max(find(inx)) - min(find(inx)));
        if max(find(inx)) - min(find(inx))<45                    
        x = 1;
        disp(x);     
        return; 
        end
    end
end

f_ic = min(find(inx));
 if f_ic+5>160, return; end
 if sum(inx(1:f_ic+5))<=3, inx(f_ic:f_ic+5) = 0; end
 f_ic = max(find(inx));
 
 if f_ic-5<=0, return; end 
 if sum(inx(f_ic-5:end))<=3,inx(f_ic-5:end)= 0 ; end
 
 
inx = find(inx);
if isempty(inx), x = 2; disp(x); return;  end

min_x = min(inx);
max_x = max(inx);
% find bbx height
a = sum(I(:,min_x:max_x),2)/size(I(:,min_x:max_x),2);
inx = sum(I(:,min_x:max_x),2)/size(I(:,min_x:max_x),2) > Tx;
inx(1:p+1) = 0;
inx(end-p:end) = 0;
b = inx;
subplot(2,3,5); imagesc(b);%


% if sum(inx(p+1:p+6))>=1 && sum(inx(85:100))>1
%         t = find(inx,1);
%         inx(t:t+find(inx(t:60)==0,1)) = 0;
% end

 f_ic = min(find(inx)); 
xxx = find(inx(f_ic:end)==0,1);
 if f_ic+xxx>120, return; end

if sum(inx(1:f_ic+xxx))<=2
    inx(f_ic:f_ic+xxx) = 0;
% elseif xxx +f_ic < 20   
%     inx(f_ic:find(inx(f_ic:end)==0)+f_ic) = 0;
end

 f_ic = max(find(inx));
 if sum(inx(f_ic-5:end))<=2,inx(f_ic-5:end)= 0 ; end
 
inx = find(inx);
if isempty(inx), x=4; disp(x); return; end
min_y = min(inx);
max_y = max(inx);
%min_y
if size(inx,1) <= p+1, return; end
if (min_y<=p+2 && (max_y - min_y)<50) || inx(end-p-1) ==1, x=3; disp(x); return; end    

subplot(2,3,1); imshow(img(min_y:max_y,min_x:max_x));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inx = (sum(I,1)/size(I,1)) > Ty_;
inx(1:p) = 0;
inx(end-p:end) = 0;
inx = find(inx);
if isempty(inx), x=5; disp(x);return; end

min_x_ = min(inx);
max_x_ = max(inx);
% find bbx height
inx = sum(I(:,min_x:max_x),2)/size(I(:,min_x:max_x),2) >Tx_;
inx(1:p+1) = 0;
inx(end-p:end) = 0;

    
f_ic = min(find(inx)); 
xxx = find(inx(f_ic:end)==0,1);
if sum(inx(1:f_ic+xxx))<=2
    inx(f_ic:f_ic+xxx) = 0;
% elseif xxx +f_ic < 20   
%     inx(f_ic:find(inx(f_ic:end)==0)+f_ic) = 0;
end
 f_ic = max(find(inx));
 if sum(inx(f_ic-5:end))<=2,inx(f_ic-5:end)= 0 ; end
inx = find(inx);
if isempty(inx), x=6; disp(x); return; end
min_y_ = min(inx);
max_y_ = max(inx);

%(max_x_ - min_x_)/(max_y_-min_y_)

if (max_x_ - min_x_)/(max_y_-min_y_) <0.12, x=7; disp(x);return; end
% for shadow
 min_x = min_x - 10;
 max_x = max_x + 10; 
bbx = [min_y min_x max_y max_x min_y_ min_x_ max_y_ max_x_];


subplot(2,3,2); imshow(img(min_y_:max_y_,min_x_:max_x_));
  
%waitforbuttonpress;
pause(0.05);
end