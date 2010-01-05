% demonstrates the difference in speed between sorted and non-sorted set 
% operations.

tim = [];
for iter = 1:100
  a = 1:10;
  s = 1:1000;
  tic;for iter2=1:100;tf1=ismember(a,s);end;tim(1,iter)=toc;
  tic;for iter2=1:100;tf=ismember_sorted(a,s);end;tim(2,iter)=toc;
  assert(all(tf==tf1));

  tic;for iter2=1:100;tf1=setdiff(a,s);end;tim(3,iter)=toc;
  tic;for iter2=1:100;tf=setdiff_sorted(a,s);end;tim(4,iter)=toc;
  assert(all(tf==tf1));
end
tim = row_sum(tim);
fprintf('       ismember: %gs\nismember_sorted: %gs (%g times faster)\n       setdiff: %gs\nsetdiff_sorted: %gs (%g times faster)\n',[tim(1) tim(2) tim(1)/tim(2) tim(3) tim(4) tim(3)/tim(4)]);
