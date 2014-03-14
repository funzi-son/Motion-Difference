function [Ws visB hidBs] = training_dbm_mf_all(conf,Ws,visB,hidBs,trn_dat)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%     Training Deep Boltzmann Machine using mean-field posterior appox 
%     and persistence CD
%     sontran2013
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

all_s = size(trn_dat,1);
visNum = size(trn_dat,2);
sNum = conf.sNum;
M = conf.M;
% Initialize params
DW1  = zeros(size(Ws{1}));
DW2  = zeros(size(Ws{2}));
DVB  = zeros(size(visB));
DHB1 = zeros(size(hidBs{1}));
DHB2 = zeros(size(hidBs{2}));

h2_mu = zeros(sNum,conf.hidNum2);
% Initialize fantasy particle
v_f  = rand(M,visNum);
h1_f = rand(M,conf.hidNum1);
h2_f = rand(M,conf.hidNum2);
for e = 1:conf.eNum    
    trn_dat = trn_dat(randperm(all_s),:);
    lr = 1/e;
    re = 0;
    for b=1:conf.bNum
        X = trn_dat((b-1)*sNum+1:b*sNum,:);
        % approximate posterior distribution
        converged = 0;
        count= 1;
        while ~converged
            h1_mu = logistic(X*Ws{1} + h2_mu*Ws{2}' + repmat(hidBs{1},sNum,1));
            h2_mu = logistic(h1_mu*Ws{2} + repmat(hidBs{2},sNum,1));
            %converging condition 1 (max_iter is reach)
            if count >= conf.max_iter
                converged = 1;
                fprintf('[DBM_GEN] Max_iter has been reached. Optimal mean-field may not be found\n');
            end
            %converging condition 2 (derivatives is close to 0)
            if count>1
                if sum(sum(abs(o_h1_mu-h1_mu)))<=conf.tol && sum(sum(abs(o_h1_mu-h1_mu)))<=conf.tol
                    converged = 1;    
%                     fprintf('optimal found %d \n',count);
                end
            end
            o_h1_mu = h1_mu;
            o_h2_mu = h2_mu;
            count = count+1;
        end
        % get reconstruction error
         X_rec = logistic(h1_mu*Ws{1}' + repmat(visB,sNum,1));
         re = re + sum(sum((X - X_rec).^2))/(sNum*visNum);        
        % get new fantasy particle
        for i=1:conf.gNum
            h1_f = logistic(v_f*Ws{1} + h2_f*Ws{2}' + repmat(hidBs{1},M,1));
            h1_f = 1*(h1_f > rand(size(h1_f)));
            
            h2_f = logistic(h1_f*Ws{2} + repmat(hidBs{2},M,1));
            h2_f = 1*(h2_f > rand(size(h2_f)));
            
            h1_f = logistic(v_f*Ws{1} + h2_f*Ws{2}' + repmat(hidBs{1},M,1));
            h1_f = 1*(h1_f > rand(size(h1_f)));
            
            v_f  = logistic(h1_f*Ws{1}' + repmat(visB,M,1));
            v_f  = 1*(v_f > rand(size(v_f)));
        end        
        %update
        diff1    = (X'*h1_mu)/sNum - (v_f'*h1_f)/M;
        DW1      = lr*(diff1 - conf.cost*Ws{1}) + conf.mmt*DW1;
        Ws{1}    = Ws{1} + DW1;
        
        diff2    = (h1_mu'*h2_mu/sNum - (h1_f'*h2_f)/M);
        DW2      = lr*(diff2 - conf.cost*Ws{2}) + conf.mmt*DW2;
        Ws{2}    = Ws{2} + DW2;
        
        DVB      = lr*(sum(X,1)/sNum - sum(v_f,1)/M) + conf.mmt*DVB;
        visB     = visB  + DVB;
        
        DHB1     = lr*(sum(h1_mu,1)/sNum - sum(h1_f,1)/M) + conf.mmt*DHB1;
        hidBs{1} = hidBs{1} + DHB1;
        
        DHB2     = lr*(sum(h2_mu,1)/sNum - sum(h2_f,1)/M) + conf.mmt*DHB2;
        hidBs{2} = hidBs{2} + DHB2;
                
    end
    % Visualize reconstruction
    if ~isempty(conf.vis_dir)
        save_images(strcat(conf.vis_dir,'dbm_rec_',num2str(e),'.mat'),X_rec,sNum,conf.row,conf.col);
    end
    fprintf('[Epoch %d] Reconstruction Error = %f\n',e,re/conf.bNum);
end
end