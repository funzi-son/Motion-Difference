function [W visB hidB] = training_rbm_(conf,data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Training RBM                                                       %  
% conf: training setting                                             %
% W: weights of connections                                          %
% -*-sontran2012-*-                                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

assert(~isempty(data),'[KBRBM] Data is empty'); 
%% initialization
visNum  = size(data,2);
hidNum  = conf.hidNum;
sNum  = conf.sNum;
lr    = conf.params(1);
N     = conf.N;                                                                     % Number of epoch training with lr_1                     

W     = 0.001*randn(visNum,hidNum);
DW    = zeros(size(W));
visB  = zeros(1,visNum);
DVB   = zeros(1,visNum);
hidB  = zeros(1,hidNum);
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
    if lr>0.05, lr = conf.params(1)/ceil(i/20); end
    omse = mse;
    mse = 0;
    for j=1:conf.bNum
       visP = data((j-1)*conf.sNum+1:j*conf.sNum,:);
       %up
       hidP = logistic(visP*W + repmat(hidB,sNum,1));
       hidPs =  1*(hidP >rand(sNum,hidNum));
       hidNs = hidPs;
       for k=1:conf.gNum
           % down
           visN  = logistic(hidNs*W' + repmat(visB,sNum,1));
           visNs = 1*(visN>rand(sNum,visNum));
           % up
           hidN  = logistic(visNs*W + repmat(hidB,sNum,1));
           hidNs = 1*(hidN>rand(sNum,hidNum));
       end
       % Compute MSE for reconstruction
       rdiff = (visP - visN);
       mse = mse + sum(sum(rdiff.*rdiff))/(sNum*visNum);
       % Update W,visB,hidB
       diff = (visP'*hidP - visNs'*hidN)/sNum;
       DW  = lr*(diff - conf.params(4)*W) +  conf.params(3)*DW;
       W   = W + DW;
       DVB  = lr*sum(visP - visNs,1)/sNum + conf.params(3)*DVB;
       visB = visB + DVB;
       DHB  = lr*sum(hidP - hidNs,1)/sNum + conf.params(3)*DHB;
       hidB = hidB + DHB;

        %% Update sparse regularization
       if conf.lambda >0
           hidI = (visP*W + repmat(hidB,sNum,1));           
           hidN = logistic(hidI);
           hidB = hidB + lr*(2*conf.lambda)*((conf.p - sum(hidN,1)/sNum).*(sum((hidN.^2).*exp(-hidI),1)/sNum));
       end
    end
    % Visualize
    if ~isempty(conf.vis_dir)
        save_images(strcat(conf.vis_dir,'rbm_rec_',num2str(i),'.mat'),visN,sNum,conf.row,conf.col);        
        if i==1, save_images(strcat(conf.vis_dir,'rbm_org.mat'),visP,sNum,conf.row,conf.col); end
    end
    %
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
