load kth_bbx_setting;
r = 1;
t_clp_names = {};
t_bbx_settg = [];
ixxx = [];
while r<size(clp_names,1)
    str = clp_names{r};        
    ind = strmatch(str,clp_names,'exact');
    if sum(ismember(ind,ixxx)) == 0 % if not counted
        ixxx = [ixxx;ind];
        t_clp_names = [t_clp_names; clp_names{max(ind)}];
        t_bbx_settg = [t_bbx_settg; bbx_settg(max(ind),:)];
    end
    r = r+1;
end