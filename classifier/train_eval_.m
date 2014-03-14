function train_eval_(setting_file)
eval(setting_file);
eres = 0;
res = 0;
tres = 0;
% Train and evaluate the model
delete(strcat(EXP_FILE,'*words*_',MODEL,'.mat'));
files = dir(strcat(EXP_FILE,'*words*','.mat'));
for i=1:size(files,1)    
    file_path = strcat(EXP_FILE,files(i).name)
if strcmp(MODEL,'NB')    
    load(file_path,'trn_dat','trn_lab');
    figure(1);imagesc(trn_dat);colorbar;
    conf.prior = 0;
    conf.laplace_smooth = 1;

    model = nb_train(conf,trn_dat,trn_lab);
    probs = nb_classify(model,trn_dat);
    [~, output] = max(probs,[],2);        
    res = sum(sum(output==trn_lab))/size(trn_lab,1);
    
    clear trn_dat trn_lab;
    
    load(file_path,'evl_dat','evl_lab');
    if exist('evl_dat','var')
        figure(2);imagesc(evl_dat);colorbar;
        probs = nb_classify(model,evl_dat);
        [~, output] = max(probs,[],2);        
        eres = sum(sum(output==evl_lab))/size(evl_lab,1);
        clear evl_dat evl_lab;
    end
    
    load(file_path,'tst_dat','tst_lab');    
    figure(3);imagesc(tst_dat);colorbar;
    probs = nb_classify(model,tst_dat);
    [~, output] = max(probs,[],2);    
    tres = sum(sum(output==tst_lab))/size(tst_lab,1);
    clear tst_dat tst_lab;
       
    fprintf('Accuracy (trn/evl/tst) = %f / %f / %f\n',res,eres,tres);
    save(strcat(file_path(1:end-4),'_',MODEL),'conf','model','res','eres','tres');
elseif strcmp(MODEL,'pLSA')
    %% PUT EMMANOUIL's pLSA here
    load(f.name);
    
    %save(strcat(f.name(1:end-4),'_',MODEL),'conf','model','res');
end
 end
end

