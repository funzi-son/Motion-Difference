function words = assign_words(features,centroids)
%% Assign features to cluster
% sontran 2013
words = zeros(1,size(features,1));
for i=1:size(features,1)        
    [~, words(i)] = min(sqrt(sum((centroids-repmat(features(i,:),size(centroids,1),1)).^2,2)));
end
end

