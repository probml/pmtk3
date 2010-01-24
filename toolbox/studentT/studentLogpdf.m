function logp = studentLogpdf(x, mu, sigma, nu)
s2 = sigma^2;
logc = gammaln(nu/2 + 0.5) - gammaln(nu/2) - 0.5*log(nu*pi*s2);
logp = logc  -(nu+1)/2*log1p((1/nu)*((x-mu)/s2).^2);
end
