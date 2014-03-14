%% DIRECTORY    SETTING
EXP_DIR = '/home/funzi/Documents/temp/';
dl_ = '/';    

%% DATA SETTING
% format of file: <org(original)/diff(different between frame)>_<dataset_name>_<rowxcol>_<aligned or not>_<none/rbm/brbm/dbn/cvdbn>
RAW_F = 'diff3_weizmann_54x54_aligned';
DAT_FILE = strcat('./',RAW_F);
EXP_FILE = strcat(EXP_DIR,RAW_F,dl_);
if ~exist(EXP_FILE,'dir'), mkdir(EXP_FILE); end
%% load data
load(DAT_FILE);
%features = (features+1)/2;
%features(features==-1)=0;
%% DATA PARTITION
INX = randperm(size(clips,1));
TRN_INX = [1:46]; % TRN_INX = INX(1:round(end/2))
TST_INX = [47:93];% TST_INX = INX(round(end/2)+1:end);
%% PCA
PCA_RED = 0;
%% Feature Setting
F_TYPE = 'srbm'; %none, rbm, srbm, dbm

%% K-MEAN SETTING
K_TOOL        = 2;        % 1: MATLAB TOOLBOX  2: VGG K_MEANS
WORD_NUM      = 200; % Number of words
WWW           = [200];
MAX_ITER      = 500;
VERBOSITY     = 1;

TRIAL_NUM     = 1;

%% RBM

rbm_conf.hidNum  = 1000;
rbm_conf.eNum    = 100;                                                         % number of epoch
rbm_conf.bNum    = 1;                                                           % number of batches devides the data set
rbm_conf.sNum    = 0;                                                            % number of samples per batch
rbm_conf.gNum    = 1;                                                           % number of iteration for gibb sampling
rbm_conf.params  = [0.2 0.1 0.02 0.00002];     
rbm_conf.N       = 100;
rbm_conf.MAX_INC = 10;
rbm_conf.plot_   = 0;

rbm_conf.lambda  = 0;
rbm_conf.p       = 0.0001;

rbm_conf.vis_dir = strcat(EXP_DIR,dl_,'RBM_VIS',dl_);
rbm_conf.row     = 54;
rbm_conf.col     = 54;

%% SRBM (sparse-continous RBM)
srbm_conf.hidNum  = 500;
srbm_conf.eNum    = 100;                                                         % number of epoch
srbm_conf.bNum    = 1;                                                           % number of batches devides the data set
srbm_conf.sNum    = 0;                                                            % number of samples per batch
srbm_conf.gNum    = 1;                                                           % number of iteration for gibb sampling
srbm_conf.params  = [0.005 0.001 0.001 0.00002];     
srbm_conf.N       = 150;
srbm_conf.MAX_INC = 10;
srbm_conf.plot_   = 0;

srbm_conf.vis_type = 1;
srbm_conf.sigma   = 1;

srbm_conf.lambda  = 0;
srbm_conf.p       = 0.0001;

srbm_conf.vis_dir = strcat(EXP_DIR,dl_,'RBM_VIS',dl_);
srbm_conf.row     = 54;
srbm_conf.col     = 54;
%% DBM

%% WORD OUTPUT FILE
%WRD_FILE = strcat(EXP_FILE,F_TYPE,'_',num2str(PCA_RED),'_words_',num2str(WORD_NUM));
%% MODEL OUTPUT FILE
MODEL = 'NB'; % NB: Naive Bayes, pLSA: latent model