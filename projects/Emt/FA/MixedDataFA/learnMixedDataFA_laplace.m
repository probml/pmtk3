function params = learnMixedDataFA_laplace(data, params, options)

  [ss, logLik, postDist] = inferMixedDataFA_laplace2(data, params, options)

