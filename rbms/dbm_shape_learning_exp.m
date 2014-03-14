function dbm_shape_learning_exp(setting_file,rand_init)
%% Testing RBM for Learning Shape
if isempty(setting_file)
    mnist_trn_dat_file = '/home/funzi/My.Academic/My.Codes/DATA/MNIST/mnist_train_dat_60k.mat';
    mnist_tst_dat_file = '/home/funzi/My.Academic/My.Codes/DATA/MNIST/mnist_test_dat_10k.mat';
    
    vars = whos('-file', mnist_trn_dat_file);
    A = load(mnist_trn_dat_file,vars(1).name);
    trn_features = A.(vars(1).name);
        
    vars = whos('-file', mnist_tst_dat_file);
    A = load(mnist_tst_dat_file,vars(1).name);
    tst_features = A.(vars(1).name);
    
    clear A;
    H = 28;
    W = 28;
    
    
    dbm_conf.sNum = 100;
    dbm_conf.bNum = 100;
    dbm_conf.model  = '/home/funzi/Documents/Experiments/pLSA_Act/DBM/dbm_mnist_500_100';
    dbm_conf.vis_dir = '/home/funzi/Documents/Experiments/pLSA_Act/DBM/VIS/';
    
    dbm_conf.layer(1).hidNum = 500;
    dbm_conf.layer(1).eNum   = 100;
    dbm_conf.layer(1).bNum   = dbm_conf.bNum;
    dbm_conf.layer(1).sNum   = dbm_conf.sNum;
    dbm_conf.layer(1).gNum   = 1;
    dbm_conf.layer(1).params = [0.5 0.2 0.1 0.00002];   
    dbm_conf.layer(1).N = 50;
    dbm_conf.layer(1).MAX_INC = 10;
    dbm_conf.layer(1).plot_ = 0;        
    dbm_conf.layer(1).vis_dir  = dbm_conf.vis_dir;
    dbm_conf.layer(1).row     = H;
    dbm_conf.layer(1).col     = W;
    
    dbm_conf.layer(2).hidNum = 1000;
    dbm_conf.layer(2).eNum   = 100;
    dbm_conf.layer(2).bNum   = dbm_conf.bNum;
    dbm_conf.layer(2).sNum   = dbm_conf.sNum;
    dbm_conf.layer(2).gNum   = 1;
    dbm_conf.layer(2).params = [0.5 0.2 0.1 0.00002];  
    dbm_conf.layer(2).N = 50;
    dbm_conf.layer(2).MAX_INC = 10;
    dbm_conf.layer(2).plot_ = 0;            
        
    dbm_conf.gen.hidNum1 = dbm_conf.layer(1).hidNum;
    dbm_conf.gen.hidNum2 = dbm_conf.layer(2).hidNum;
    dbm_conf.gen.eNum    = 100;
    dbm_conf.gen.bNum    = dbm_conf.bNum;
    dbm_conf.gen.sNum    = dbm_conf.sNum;
    dbm_conf.gen.gNum    = 10;
    dbm_conf.gen.mmt     = 0.1;
    dbm_conf.gen.cost    = 0.00002;
    
    dbm_conf.gen.M        = 100;
    dbm_conf.gen.max_iter = 100;
    dbm_conf.gen.tol      = 0.001;
    
    dbm_conf.gen.row     = H;
    dbm_conf.gen.col     = W;
    dbm_conf.gen.vis_dir  = dbm_conf.vis_dir;
    
    trn_features = trn_features(1:dbm_conf.sNum*dbm_conf.bNum,:);
        
else
    eval(setting_file);
    CR = sscanf(strrep(DAT_FILE,'_',' '),'%*s %*s %ux%u%*s');

    trn_f_inx = [];
    tst_f_inx = [];
    for i=TRN_INX
        trn_f_inx = [trn_f_inx clips(i,1):clips(i,2)];
    end
    trn_features = features(trn_f_inx',:);

    for i=TST_INX
        tst_f_inx = [tst_f_inx clips(i,1):clips(i,2)];
    end
    tst_features = features(tst_f_inx',:);   
    
    H = 54;
    W = 54;
end

if rand_init
    tst_features = rand(200,size(trn_features,2));
end

if dbm_conf.sNum==0
    dbm_conf.layer(1).sNum = size(trn_features,1); 
    dbm_conf.layer(1).bNum = 1;
    
    dbm_conf.layer(2).sNum = dbm_conf(1).sNum;
    dbm_conf.layer(2).bNum = dbm_conf(1).bNum;
    
    dbm_conf.gen.sNum = dbm_conf(1).sNum;
    dbm_conf.gen.bNum = dbm_conf(1).bNum;
end;
[Ws visBs hidBs] = training_dbm_(dbm_conf,trn_features);
%% Visualize construction
% vis_s = test_features;
% for gibbs = 1:100
%     %up
%     for layer=1:size(Ws,2)
%         hid_p = logistic(vis_s*Ws{i} + repmat(hidBs{i},size(vis_s,1),1));
%         hid_s = hid_p>rand(size(hid_p));
%         vis_s = hid_s;
%     end
%     %down
%     for layer=size(Ws,2):-1:1
%         vis_p = logistic(hid_s*Ws{i}' + repmat(visBs{i},size(hid_s,1),1));
%         vis_s = vis_p>rand(size(vis_p));
%         hid_s = vis_s;
%     end
%     if rem(gibbs,100)==0
%         save_images(strcat('/home/funzi/Documents/Experiments/pLSA_Act/DBM/spl_',num2str(gibbs)),vis_p,size(vis_p,1),H,W);
%     end
% end
end

