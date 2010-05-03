function deconstructTest()


model.mu = zeros(1, 10); 
model.Sigma = randpd(10); 
model.pi = normalize(ones(1, 10)); 


tic
for i=1:1000

[pi, Sigma, mu] = deconstruct(model);
end
t = toc/1000


tic
for i=1000
   pi = model.pi;
   Sigma = model.Sigma; 
   mu = model.mu;
end
t2 = toc/1000


end