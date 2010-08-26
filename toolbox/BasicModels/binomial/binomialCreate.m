function model = binomialCreate(mu, N)
%% Construct a binomial distribution
%PMTKdefn binom(x | N, \mu)

model = structure(mu, N); 
end