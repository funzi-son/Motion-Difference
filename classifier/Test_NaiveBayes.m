CASE = 2;
switch CASE
    case 1
        load sample_dataset;
        conf.prior = 0;
        conf.laplace_smooth = 1;
        model = nb_train(conf,trn_dat,trn_lab);
        probs = nb_classify(model,trn_dat);
        sum((probs - [Pc_d_pos_train([2 1],:),Pc_d_neg_train([2 1],:)]'))
        trn_val = (probs(:,2) - probs(:,1));

        probs = nb_classify(model,tst_dat);
        sum((probs - [Pc_d_pos_test([2 1],:),Pc_d_neg_test([2 1],:)]'))
        tst_val = (probs(:,2) - probs(:,1));
        %% roc
        [roc_curve_train,roc_op_train,roc_area_train,roc_threshold_train] = roc([trn_val,trn_lab]);
        [roc_curve_test,roc_op_test,roc_area_test,roc_threshold_test] = roc([tst_val,tst_lab]);


        figure; hold on;
        plot(roc_curve_train(:,1),roc_curve_train(:,2),'r');
        plot(roc_curve_test(:,1),roc_curve_test(:,2),'g');
        axis([0 1 0 1]); axis square; grid on;
        xlabel('P_{fa}'); ylabel('P_d'); title('ROC Curves');
        legend('Train','Test');
    case 2
        load /home/funzi/My.Academic/My.Codes/DATA/DOC/20NewsGroup/20news_w100.mat
        data_ok = 0;
        while ~data_ok
            inx = randperm(size(newsgroups,2));            
            
            pos = round(size(inx,2)/2);        
            fprintf('%d %d %d %d\n',sum(sum(newsgroups(inx(1:pos))==1)),sum(sum(newsgroups(inx(1:pos))==2)),sum(sum(newsgroups(inx(1:pos))==3)),sum(sum(newsgroups(inx(1:pos))==4)));
            if sum(sum(newsgroups(inx(1:pos))==1)) >0 && sum(sum(newsgroups(inx(1:pos))==2))>0 ...
                    && sum(sum(newsgroups(inx(1:pos))==3))>0  && sum(sum(newsgroups(inx(1:pos))==4)) >0 
                data_ok = 1;
            end
        end
            
        trn_dat = documents(:,inx(1:pos))';
        trn_lab = newsgroups(inx(1:pos))';
        tst_dat = documents(:,inx(pos+1:end))';
        tst_lab = newsgroups(inx(pos+1:end))';
        
        conf.prior = 0;
        conf.laplace_smooth = 1;
        
        model = nb_train(conf,trn_dat,trn_lab);
        probs = nb_classify(model,tst_dat);
        
        [~, output] = max(probs,[],2);
        fprintf('Accuracy = %f\n',sum(sum(tst_lab==output))/size(tst_lab,1));
end