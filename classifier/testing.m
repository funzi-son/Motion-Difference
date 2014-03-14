function [acc] = testing(iter,matFile,sz)

% iter: number of iterations (e.g. 1000)
% matFile: .mat filename with features and words
%
% e.g. testing(100,'org_weizmann_54x54_aligned_none_words200');

% e.g. for i=1:100 acc(i) = testing(200,'org_weizmann_54x54_aligned_none_words200',3.3); end;
%      for i=1:100 acc(i) = testing(200,'diff2_weizmann_54x54_aligned_none_words200',0.20); end;


% Load .mat file
load(matFile,'trn_dat','trn_lab');
lbs = unique(trn_lab);
numZ = size(lbs,1);
% Create training dictionary
W = zeros(size(trn_dat,2),numZ);
for i=lbs' % for each action class   
    ind = find(trn_lab ==i);
    temp_W = trn_dat(ind,:);
    W(:,i) = plsa_train(temp_W',iter); % perform PLSA for each action class
end

clear trn_dat trn_lab
load(matFile,'tst_dat','tst_lab');
% Perform PLSA for testing
V = tst_dat;
W = W';
[Z,W] = plsa_test(V,W,iter,sz,numZ);
%figure; imagesc(Z)
for i=1:size(Z,2)
    [B,testLabel(i)] = max(Z(:,i));
end;


% Evaluate
testGT = tst_lab;
correct=0;
for i=1:length(testGT)
    if(testGT(i)==testLabel(i))
        correct = correct+1;
    end
end;
acc = sum(correct)/length(tst_lab);
%disp(['Accuracy: ' num2str(sum(correct)/length(tst_lab))]);
end