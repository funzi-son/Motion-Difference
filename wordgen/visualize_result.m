function visualize_result(outputs,labels)
C = confusionmat(labels,outputs);
C
% act_names = {'boxing','handclapping','handwaving','jogging','running','walking'};
% tst_pers_num = [22, 02, 03, 05, 06, 07, 08, 09, 10];
% 
% for i=1:size(act_names,2)
%     act_names{i}
%     iiix = find(outputs==i);
%     inx =  find(labels(iiix) ~=1);
% end
end

