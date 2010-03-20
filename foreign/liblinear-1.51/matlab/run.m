[y,xt] = libsvmread('../heart_scale');
model=train(y, xt)
[l,a]=predict(y, xt, model);

