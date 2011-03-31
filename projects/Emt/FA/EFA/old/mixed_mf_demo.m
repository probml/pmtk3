%load auto.mat
[data, nClass] = processData('auto', [])

K = 20;        %Number oflatent factors
sigma = 1;     %Stanrd deviation of guassian noise
lambda = 0.01  %L2 penalty on factors

%Data for training - can contain missing values coded as nan
train_data.continuous = data.continuous;
train_data.discrete   = data.discrete;

%Data for test time inference - can contain missing values coded as nan
infer_data.continuous = data.continuousTest;
infer_data.discrete   = data.discreteTest;
[iXb,iXm,iXc]         = mixed_mf_prepare_data(infer_data);

%Ground truth data for testing
test_data.continuous = data.continuousTestTruth;
test_data.discrete   = data.discreteTest;
[tXb,tXm,tXc]        = mixed_mf_prepare_data(test_data);

%Learn the model
model = mixed_mf_learn(data,K,sigma,lambda);

%Make prediction based on infer data
[iXbhat,iXmhat,iXchat] = mixed_mf_predict(iXb,iXm,iXc,model);

%compute test rmse
continuous_test_mse = mean(((iXchat(isnan(iXc)) - tXc(isnan(iXc))).^2))

%Compute train rmse
continuous_train_mse = mean(((iXchat(~isnan(iXc)) - tXc(~isnan(iXc))).^2))
