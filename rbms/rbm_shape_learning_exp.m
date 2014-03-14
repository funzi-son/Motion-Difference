function rbm_shape_learning_exp(setting_file,rand_init)
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
        
    
    rbm_conf.model  = '/home/funzi/Documents/Experiments/pLSA_Act/RBM/rbm_500';
    rbm_conf.vis_dir = '/home/funzi/Documents/Experiments/pLSA_Act/RBM/VIS/';    
    
    rbm_conf.hidNum  = 500;
    rbm_conf.eNum    = 100;    
    rbm_conf.sNum    = 100;
    rbm_conf.bNum    = 100;
    rbm_conf.gNum    = 1;
    rbm_conf.params  = [0.5 0.2 0.1 0.00002];   
    rbm_conf.N       = 50;
    rbm_conf.MAX_INC = 10;
    rbm_conf.plot_   = 0;            
    rbm_conf.row     = H;
    rbm_conf.col     = W;
    
    rbm_conf.lambda  = 0;
    rbm_conf.p       = 0.00001;
    
    
    trn_features = trn_features(1:rbm_conf.sNum*rbm_conf.bNum,:);
        
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

if rbm_conf(1).sNum==0
    rbm_conf.sNum = size(trn_features,1);
    rbm_conf.bNum = 1;       
end;
[Ws visBs hidBs] = training_rbm_(rbm_conf,trn_features);
end