function [W visB hidB] = training_rbm(conf,W,data_file)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Training RBM                                                       %  
% conf: training setting                                             %
% W: weights of connections                                          %
% -*-sontran2012-*-                                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load data
vars = whos('-file', data_file);
A = load(data_file,vars(1).name);
data = A.(vars(1).name);
[W visB hidB] = training_rbm_(conf,W,data);
end