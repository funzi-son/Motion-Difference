function [ model ] = nb_train(conf,trn_dat,trn_lab)
% Training Naive Bayes for bag-of-words dataset
% sontran 2013
[labels it il] = unique(trn_lab);
C = size(labels,1);
[M N] = size(trn_dat);
model.Prior_Y = zeros(C,1);
model.Post_X = zeros(C,N);
if conf.prior
    % If prior is computed from dataset
    model.Prior_Y = accumarray(il,1)/M;        
else
    model.Prior_Y = ones(C,1)/C;
end
for c=1:C
    inx = find(trn_lab == labels(c));    
    model.Post_X(c,:) = sum(trn_dat(inx,:));
    model.Post_X(c,:) = (conf.laplace_smooth + model.Post_X(c,:))/(sum(model.Post_X(c,:),2) + conf.laplace_smooth*N);
end
end