function [probs] = nb_classify(model,tst_dat)
% Classify data using Naive Bayes
% sontran 2013
C = size(model.Prior_Y,1);
[M N] = size(tst_dat);
probs = zeros(M,C);

for c=1:C
    probs(:,c) = log(model.Prior_Y(c)) + sum(tst_dat.*repmat(log(model.Post_X(c,:)),M,1),2);
end
end

