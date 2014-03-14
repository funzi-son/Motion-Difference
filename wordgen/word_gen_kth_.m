function word_gen_kth(setting_file)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This script convert clips into words
%% sontran2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eval(setting_file);

%% PCA
coeffs = [];
if ~exist(PRE_FILE,'file')    
if ~exist('trn_ftr','var'), load(DAT_FILE,'trn_ftr'); end    
if PCA_RED >0 
    if ~exist(PCA_FILE,'file')
        fprintf('PCA .... \n');
        [coeffs, trn_ftr] = princomp(trn_ftr);
        trn_ftr = trn_ftr(:,1:PCA_RED);    
        save(PCA_FILE,'coeffs');
    else
        fprintf('Load PCA .... \n');
        load(PCA_FILE);
        trn_ftr = trn_ftr*coeffs(:,1:PCA_RED);            
        figure(1); imagesc(trn_ftr);colorbar;
    end
    fprintf('Done PCA!\n');
end

if strcmp(F_TYPE,'srbm')
    if ~exist(NOR_FILE,'file')
        % Normalize data to have zeros mean and unit variance        
        fprintf('SRBM preprocessing .... \n');
        M_ = mean(trn_ftr);
        D_ = std(trn_ftr);   
        tst_ftr = bsxfun(@rdivide,bsxfun(@minus,trn_ftr,M_),D_);        
        trn_ftr(isnan(trn_ftr)) = 0;
        trn_ftr(isinf(trn_ftr)) = 0;                            
        save(NOR_FILE,'M_','D_');
    else
        fprintf('Found srbm prep, loading .... \n');
        load(NOR_FILE);
        tst_ftr = bsxfun(@rdivide,bsxfun(@minus,trn_ftr,M_),D_);        
        trn_ftr(isnan(trn_ftr)) = 0;
        trn_ftr(isinf(trn_ftr)) = 0;                            
    end    
    fprintf('Done SRBM preprocessing!\n');
end
    save(PRE_FILE,'trn_ftr');
else
    fprintf('Loading PCA, NOR, PRE files\n');
    if exist(PCA_FILE,'file'), load(PCA_FILE); end
    if exist(NOR_FILE,'file'), load(NOR_FILE); end    
    fprintf('Done loading\n');
end

fprintf('Done preprocessing ...\n');
%% Get features & label
ftr_files = dir(strcat(EXP_FILE,'*_FTR_*.mat'));
for iii = 1:size(ftr_files,1)
    FTR_FILE = strcat(EXP_FILE,ftr_files(iii).name);
    fprintf('Try new words for %s\n',ftr_files(iii).name);    
    str_date = ftr_files(iii).name(end-18:end-4);    
    %load(FTR_FILE,'trn_ftr');
%% Run K-means to obtain the words 
for WORD_NUM=WWW
fprintf('Generating words (size=%d)\n',WORD_NUM);
load(FTR_FILE,'trn_ftr');
figure(3); imagesc(trn_ftr); colorbar;
WRD_FILE = strcat(EXP_FILE,F_TYPE,num2str(HID_NUM),'_PCA',num2str(PCA_RED),'_words_',num2str(WORD_NUM));
switch K_TOOL
    case 1
        % MATLAB TOOLBOX
        fprintf('KNN using Matlab toolbox\n');
        opts = statset('Display','final');
        [vw, C] = kmeans(double(trn_ftr),WORD_NUM,...
                'distance','sqEuclidean',...
                'emptyaction','drop',...
                'replicates',5,...
                'options',opts);
    case 2
        % VGG K-MEAN by Mark Everingham
        fprintf('KNN using VGG\n');
        cluster_options.maxiters = MAX_ITER;
        cluster_options.verbose  = VERBOSITY;   
        [C,sse] = vgg_kmeans(double(trn_ftr'), WORD_NUM, cluster_options);
        C= C';       
end

WRD_FILE_ = strcat(WRD_FILE,'_',str_date,'.mat');
%v-words & word occurence for training data
load(DAT_FILE,'trn_clp','trn_lab');
trn_vwords = assign_words(trn_ftr,C);
%disp(trn_vwords(trn_clp(1,1):trn_clp(1,2)));
%disp(trn_vwords(trn_clp(2,1):trn_clp(2,2)));
trn_dat = zeros(size(trn_clp,1),WORD_NUM);
size(trn_vwords)
size(trn_dat)
for i=1:size(trn_dat,1)
    occ = accumarray(trn_vwords(trn_clp(i,1):trn_clp(i,2))',1)';
    trn_dat(i,1:size(occ,2)) = occ;
end
save(WRD_FILE_,'C','trn_dat','trn_lab','trn_vwords','coeffs','sse');
clear trn_ftr trn_dat trn_clp trn_lab trn_vwords;

%v-words for evaluating data
load(DAT_FILE,'evl_ftr','evl_clp','evl_lab');
if PCA_RED > 0, evl_ftr =  evl_ftr*coeffs(:,1:PCA_RED); end
if strcmp(F_TYPE,'srbm')    
    evl_ftr = bsxfun(@rdivide,bsxfun(@minus,evl_ftr,M_),D_);
    evl_ftr(isnan(evl_ftr)) = 0;
    evl_ftr(isinf(evl_ftr)) = 0;
    evl_ftr = logistic(bsxfun(@plus,evl_ftr*W,hidB));
end
figure(4);imagesc(evl_ftr); colorbar;
evl_vwords = assign_words(evl_ftr,C);
evl_dat = zeros(size(evl_clp,1),WORD_NUM);
for i=1:size(evl_dat,1)
    occ = accumarray(evl_vwords(evl_clp(i,1):evl_clp(i,2))',1)';
    evl_dat(i,1:size(occ,2)) = occ;
end
save(WRD_FILE_,'evl_dat','evl_lab','evl_vwords','-append');
clear evl_ftr evl_clp evl_lab evl_dat evl_vwords;
% v-words for testing data
load(DAT_FILE,'tst_ftr','tst_clp','tst_lab');
if PCA_RED > 0, tst_ftr =  tst_ftr*coeffs(:,1:PCA_RED); end
if strcmp(F_TYPE,'srbm')
    tst_ftr = bsxfun(@rdivide,bsxfun(@minus,tst_ftr,M_),D_);
    tst_ftr(isnan(tst_ftr)) = 0;
    tst_ftr(isinf(tst_ftr)) = 0;            
    tst_ftr = logistic(bsxfun(@plus,tst_ftr*W,hidB));
end
figure(5);imagesc(tst_ftr); colorbar;
tst_vwords = assign_words(tst_ftr,C);
tst_dat = zeros(size(tst_clp,1),WORD_NUM);
for i=1:size(tst_dat,1)
    occ = accumarray(tst_vwords(tst_clp(i,1):tst_clp(i,2))',1)';
    tst_dat(i,1:size(occ,2)) = occ;
end
save(WRD_FILE_,'tst_dat','tst_lab','tst_vwords','-append');
clear tst_ftr tst_clp tst_lab tst_dat tst_vwords;
end
end
end