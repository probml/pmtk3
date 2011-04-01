
clear all
seed = 1;
name = 'newsgroup';

% Train
 setSeed(seed);
 [data, nClass] = processData(name, struct('ratio',0.1));
 numOfMix = 1;
 maxIters = 100;
 train.labels = data.discrete'; %KPM
 
s0 = 0.1;
options = struct('maxNumOfItersLearn', maxIters, 'lowerBoundTol', 1e-4, 'regCovMat', 1, 'covMat', 'diag','display',1)
data.discrete = encodeDataOneOfM(data.discrete, nClass, 'M');
opt=struct('initMethod','random','numOfMix',numOfMix,'scale',3, 'refine', 0, 'nClass', nClass, 's0',s0);
[params0, data] = initImm(data, [], opt);
funcName = struct('inferFunc', @inferImm, 'maxParamsFunc', @maxParamsImm);
[params, trainLogLik] = learnEm(data, funcName, params0, options);



  
% Test
missProbD = 0.3;
setSeed(seed);
[data, nClass] = processData(name, []);

ycT = data.continuousTestTruth;
ydT = data.discreteTestTruth;
testData.continuous = ycT;
testData.discrete = ydT;

miss = rand(size(ydT))<missProbD;
testData.discrete(miss) = NaN;


test.labels = data.discreteTestTruth'; %KPM
test.labelsMasked = test.labels; %KPM
test.labelsMasked(miss') = nan; %KPM
test.missingMask = miss'; %KPM

yd = testData.discrete;
yc = testData.continuous;
  
  
testData.discrete = encodeDataOneOfM(testData.discrete, nClass, 'M');
miss = isnan(testData.discrete);
testData.discrete(miss) = 0;




[pred, logLik] = imputeMissingImm(testData, params, struct('regCovMat',0));

%{
M = params.nClass;
for d = 1:length(M)
  idx = sum(M(1:d-1))+1:sum(M(1:d));
  p1 = pred.discrete(idx,:);
  if ~isempty(find(sum(p1,2) == 0))
    p1 = p1 + eps;
    p1 = bsxfun(@times, p1, 1./sum(p1));
  end
  pred.discrete(idx,:) = p1;
end
 %}

ydT_oneOfM = encodeDataOneOfM(ydT, nClass, 'M');
yd_oneOfM = encodeDataOneOfM(yd, nClass, 'M');
N = size(yd_oneOfM,2);
miss = isnan(yd_oneOfM);
yhatD = pred.discrete;
mseD = mean((ydT_oneOfM(miss) - yhatD(miss)).^2);
entrpyD = -sum(ydT_oneOfM(miss).*log2(yhatD(miss)))/(N*length(nClass))

% Sanity check
n = 1;
disp('true values')
ydT(1:10, n)'
disp('dummy encoding')
ydT_oneOfM(1:20, n)'
disp('missingness')
miss(1:20, n)'
disp('prediction')
yhatD(1:20,n)'



%{
%%%
% KPM code

model = discreteFit(train.labels);
predKPM = discretePredictMissing(model, test.labelsMasked);
pred2 = permute(predKPM, [3 2 1]); % K D N
[Ntest  Nnodes] = size(test.labelsMasked);
pred3 = reshape(pred2, [sum(nClass) Ntest]); % KD * N
approxeq(pred3, yhatD)

 %}