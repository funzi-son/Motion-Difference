function [W] = plsa_train(V,iter)

% Input:  V: w x d
%
% Output: W: w x 1
%         H: 1 x d

% Reconstruction: W*H


% Initialize
r = 1;
W = rand(size(V,1),1); % P(w|z)
W = W ./ sum(W);
H = rand(r,size(V,2)); % P(d|z)
H = H ./ sum(H);


% Iterate
for it=1:iter
    
    % E-step
    R = V ./ (W*H+eps);

    
    % M-step
    nw = W .* (R*H');
    nh = H .* (W'*R);

    
    % Assign and normalize
    H = nh;
    H = H ./ (sum(H)+eps);
    W = nw;
    W = W ./ (sum(W)+eps);  
    
end