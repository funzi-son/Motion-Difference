function [Ws visB hidBs] = training_dbm_(conf,trn_dat)
% Training Generative Deep Boltzmann Machine with 2 layers
% sontran 2013

Ws = cell(1,size(conf,1)-1);
hidBs = cell(1,size(conf,1)-1);
%% Greedy training
% fprintf('[Greedy_LN] Layer 1\n');
% [Ws{1}, visB, hidBs{1}] = training_dbm_first_l(conf.layer(1),trn_dat);
% save(conf.model,'Ws','visB','hidBs');

% load(conf.model,'Ws','visB','hidBs');
% first_ftures = logistic(2*trn_dat*Ws{1} + repmat(hidBs{1},size(trn_dat,1),1));
% fprintf('[Greedy_LN] Layer 2\n');
% [Ws{2}, hidBs{2}, hidBs{2}] = training_dbm_last_l(conf.layer(2),first_ftures);
% save(strcat(conf.model,'_l2'),'Ws','visB','hidBs');

load(strcat(conf.model,'_l2'),'Ws','visB','hidBs');
%% Generative training
fprintf('[Generative_LN] All\n');
[Ws visB hidBs] = training_dbm_mf_all(conf.gen,Ws,visB,hidBs,trn_dat);
%save(conf.model,'Ws','visB','hidBs');
end

