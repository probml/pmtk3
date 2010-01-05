function mu = softmax(eta)

mu = exp(eta)./sum(exp(eta));
