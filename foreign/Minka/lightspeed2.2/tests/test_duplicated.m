% demonstrates the difference in speed between duplicated and unique.

tim = [];
for iter = 1:100
  x = [1:100 1:100]';
  tic;for iter2 = 1:100;u1=unique(x);end;tim(1,iter)=toc;
  tic;for iter2 = 1:100;u=x(~duplicated(x));end;tim(2,iter)=toc;
  assert(isequal(u1,u));

  x = reshape(x,10,20)';
  tic;for iter2 = 1:100;u1=unique(x,'rows');end;tim(3,iter)=toc;
  tic;for iter2 = 1:100;u=x(~duplicated(x),:);end;tim(4,iter)=toc;
  assert(isequal(u1,u));
end
tim = row_sum(tim);
fprintf('    unique: %gs\nduplicated: %gs\n    unique rows: %gs\nduplicated rows: %gs\n',tim);
