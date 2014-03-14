function [] = batchProcessing(folderInd)


% Initialize
c = {'diff2_weizmann_54x54_aligned/none_50_bk',
'diff2_weizmann_54x54_aligned/none_100_bk',
'diff2_weizmann_54x54_aligned/none_200_bk',
'diff2_weizmann_54x54_aligned/srbm_500_50_bk',
'diff2_weizmann_54x54_aligned/srbm_500_100_bk',
'diff2_weizmann_54x54_aligned/srbm_500_200_bk',
'org_weizmann_54x54_aligned/none_50_bk',
'org_weizmann_54x54_aligned/none_100_bk',
'org_weizmann_54x54_aligned/none_200_bk',
'org_weizmann_54x54_aligned/RBM_1000_bk',
'org_weizmann_54x54_aligned/srbm_500_50_bk',
'org_weizmann_54x54_aligned/srbm_500_100_bk',
'org_weizmann_54x54_aligned/srbm_500_200_bk'};
folder = c{folderInd};
fileList = dir([folder '/*.mat']);


% For each .mat file
for i=1:length(fileList)
    
    if(isempty(strfind(fileList(i).name,'_NB')))
        
        res = testing(200,[folder '/' fileList(i).name],1.0)
        fileList(i).name = strrep(fileList(i).name, '.mat', '');  
        save([folder '/' fileList(i).name '_PLSA'],'res');
        
    end
    
end