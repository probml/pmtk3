function cvplot(s_opt, res_mean, res_std)
% CVPLOT  Simple plotting function for cross validation results. 
%    CVPLOT(S_OPT, RES_MEAN, RES_STD) plots the mean reconstruction error
%    with error bars resulting from the function CROSSVALIDATE. The optimal
%    model choice is marked with a dashed red line.
%



%figure; hold on;
s_sub = linspace(0, 1, 17);
s_sub = s_sub(2:end-1);
t_sub = round(s_sub*length(res_mean));
errorbar(s_sub, res_mean(t_sub), res_std(t_sub), 'bx');
s = linspace(0,1,length(res_mean));
plot(s, res_mean);
ax = axis;
line([s_opt s_opt], [ax(3) ax(4)], 'Color', 'r', 'LineStyle', '-.');

end