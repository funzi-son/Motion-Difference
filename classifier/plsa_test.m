function [Z,W] = plsa_test(V,W,iter,sz,numZ)

% Input: V: D x W
%        W: Z x W

% Reconstruction: Z'*W


% Initialize
sumD = sum(V,2)+eps; % P(d)
Z = rand(numZ,size(V,1)); % P(z|d)
Z = Z ./ (repmat(sum(Z),[numZ 1])+eps);


% Iterate
for it=1:iter
    
    % E-step
    V_a = Z'*W;
    V_a = V_a .* repmat(sumD,[1 size(V,2)]);
    R = V ./ (V_a+eps);

    
    % M-step
    nz = Z .* (W*R');
    nw = W .* (Z*R);

    
    % Assign and normalize
    Z = nz.^sz;
    Z = Z ./ (repmat(sum(Z),[numZ 1])+eps);
    %W = nw;
    %W = W ./ (repmat(sum(W,2),[1 size(V,2)])+eps);
    
end
