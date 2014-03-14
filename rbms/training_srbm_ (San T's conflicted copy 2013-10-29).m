function [W visB hidB] = training_srbm_(conf,data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Training Sparse RBM (with real visible, binary hidden)             %
% Visible units are encoded by Gaussian distribution with 0 mean     %
% conf: training setting                                             %
% W: weights of connections                                          %
% -*-sontran2012-*-                                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

assert(~isempty(data),'[KBRBM] Data is empty'); 
%% initialization
[sD visNum] = size(data);
hidNum  = conf.hidNum;
if conf.sNum ==0    
    conf.sNum = size(data,1);
    bNum = 1;
elseif conf.bNum == 0;
    bNum = ceil(size(data,1)/conf.sNum);    
end
lr    = conf.params(1);
N     = conf.N;                                                                     % Number of epoch training with lr_1                     

W     = 0.01*randn(visNum,hidNum);
visB  = 0.01*randn(1,visNum);
hidB  = 0.01*randn(1,hidNum);

DW    = zeros(size(W));
DVB   = zeros(1,visNum);
DHB   = zeros(1,hidNum);

%% Reconstruction error & evaluation error & early stopping
mse    = 0;
omse   = 0;
inc_count = 0;
MAX_INC = conf.MAX_INC;                                                                % If the error increase MAX_INC times continuously, then stop training
%% Average best settings
n_best  = 1;
aW  = size(W);
aVB = size(visB);
aHB = size(hidB);
%% Plotting
if conf.plot_, h = plot(nan); end
%% ==================== Start training =========================== %%
for i=1:conf.eNum
    if i== N+1
        lr = conf.params(2);
    end
    omse = mse;
    mse = 0;    
    for j=1:bNum   
       sInx = (j-1)*conf.sNum+1;
       visP = data(sInx:sInx + min(conf.sNum-1,sD-sInx),:);      
       sNum = size(visP,1);
       %up
       hidI = (visP*W + repmat(hidB,sNum,1))/(conf.sigma^2);
       hidP = logistic(hidI);
       hidPs =  1*(hidP >rand(sNum,hidNum));
       hidNs = hidPs;
       for k=1:conf.gNum
            % down
            if conf.vis_type ==1 % gaussian rbm
                visN  = (hidNs*W' + repmat(visB,sNum,1)); % sampling from normal distribution
                %visN  = normpdf(1,(hidNs*W' + repmat(visB,sNum,1)),conf.sigma); % sampling from normal distribution
                visNs = visN +  + conf.sigma*randn(sNum,visNum);           
            else
             visN = logistic((hidNs*W' + repmat(visB,sNum,1))/(conf.sigma^2));
             visNs = visN>rand(sNum,visNum);
            end
           hidN  = logistic((visNs*W + repmat(hidB,sNum,1))/(conf.sigma^2));
           hidNs = 1*(hidN>rand(sNum,hidNum));
       end
       % Compute MSE for reconstruction       
       mse = mse + sum(sum((visP-visNs).^2))/(sNum*visNum);
       % Update W,visB,hidB
       diff = (visP'*hidP - visNs'*hidN)/(sNum*conf.sigma^2);       
       
       DW  = lr*(diff - conf.params(4)*W) +  conf.params(3)*DW;
       W   = W + DW;
       
       DVB  = lr*sum(visP - visNs,1)/(sNum*conf.sigma^2) + conf.params(3)*DVB;
       visB = visB + DVB;
       
       DHB  = lr*sum(hidP - hidN,1)/(sNum*conf.sigma^2)  + conf.params(3)*DHB;
       hidB = hidB + DHB;
       
       %% Update sparse regularization
       if conf.lambda >0
           hidI = (visP*W + repmat(hidB,sNum,1))/(conf.sigma^2);           
           hidN = logistic(hidI);
           hidB = hidB + lr*(2*conf.lambda)*((conf.p - sum(hidN,1)/sNum).*(sum((hidN.^2).*exp(-hidI),1)/sNum));                  
       end
    end
    %% 
    if conf.plot_
        mse_plot(i) = mse;
        axis([0 (conf.eNum+1) 0 5]);
        set(h,'YData',mse_plot);
        drawnow;
    end
    
    if mse > omse
        inc_count = inc_count + 1
    else
        inc_count = 0;
    end
    if inc_count> MAX_INC, break; end;
    fprintf('Epoch %d  : MSE = %f\n',i,mse);  
end
end