function s = sampling3(inp,r)
[M N] = size(inp);
e_pos_state = exp(inp);
e_neg_state = zeros(size(inp));%exp(-inp);
prob_neg    = e_neg_state./(e_pos_state + e_neg_state + 1);
prob_pos    = e_pos_state./(e_pos_state + e_neg_state + 1);

prob_pos    = prob_pos + prob_neg;

s = zeros(size(inp));
neg_inx = find(prob_neg>r);
s(neg_inx) = -1;
pos_inx = setdiff(find(prob_pos>r),neg_inx);
s(pos_inx) = 1;
%reshape(s,[M N]);
end