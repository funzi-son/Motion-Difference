function train_eval(setting_file)
eval(setting_file);
es = 0;
eres = 0;
tres = 0;
% Train and evaluate the model
files = dir(strcat(EXP_FILE,'*words_*','.mat'));
for i=1:size(files,1)
    if ~isempty(strfind(files(i).name,'_NB.mat')), continue; end
    if ~isempty(strfind(files(i).name,'_pLSA.mat')), continue; end
    file_path = strcat(EXP_FILE,files(i).name)
if strcmp(MODEL,'NB')    
    load(file_path,'trn_dat','trn_lab');
    figure(11);imagesc(trn_dat);colorbar;
    conf.prior = 0;
    conf.laplace_smooth = 1;

    model = nb_train(conf,trn_dat,trn_lab);
    probs = nb_classify(model,trn_dat);
    [~, output] = max(probs,[],2);
    res = sum(sum(output==trn_lab))/size(trn_lab,1);

    clear trn_dat trn_lab;
    
    load(file_path,'evl_dat','evl_lab');
    if exist('evl_dat','var')
        figure(12);imagesc(evl_dat);colorbar;
        probs = nb_classify(model,evl_dat);
        [~, output] = max(probs,[],2);        
        eres = sum(sum(output==evl_lab))/size(evl_lab,1);
        clear evl_dat evl_lab;
    end
    
    load(file_path,'tst_dat','tst_lab');    
    figure(13);imagesc(tst_dat);colorbar;
    probs = nb_classify(model,tst_dat);
    [~, output] = max(probs,[],2);    
    visualize_result(output,tst_lab);    
    tres = sum(sum(output==tst_lab))/size(tst_lab,1);
    clear tst_dat tst_lab;
       
    fprintf('Accuracy (trn/evl/tst) = %f / %f / %f\n',res,eres,tres);
    save(strcat(file_path(1:end-4),'_',MODEL),'conf','model','res','eres','tres');
elseif strcmp(MODEL,'pLSA')
    %% PUT EMMANOUIL's pLSA here
    tres = 0;
    for run_i = 1:10
        tres  =  tres + testing(500,file_path,1.5);
    end
    tres = tres/10;
    fprintf('Accuracy = %f\n',tres);
    save(strcat(file_path(1:end-4),'_',MODEL),'tres');
end
 end
end