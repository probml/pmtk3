function model = svmlibFit(X, y, C, kernelParam, kernelType, varargin)
% PMTK interface to libsvm
% If RBF, the kernelParam is gamma in exp(-gamma ||X-X'||^2).
%
%% Setup
% (1) Download libsvm from
%     http://www.csie.ntu.edu.tw/~cjlin/cgi-bin/libsvm.cgi?+http://www.csie.ntu.edu.tw/~cjlin/libsvm+zip
% (2) unzip to e.g. C:\libsvm\
% (3) (if linux, run make - windows executables already built)
% (4) add the executables to your system path
%     e.g. addtosystempath('C:\libsvm\libsvm-2.9\windows');
%     note, addtosystempath does not persist between matlab sessions, so
%     add this line to your startup.m file.
% (5) (if linux, mexify by running libsvmMake.m - already done for windows)
% (6) test the mex interface with libsvmTest.m
%% libsvm options:
% -s svm_type : set type of SVM (default 0)
% 	0 -- C-SVC
% 	1 -- nu-SVC
% 	2 -- one-class SVM
% 	3 -- epsilon-SVR
% 	4 -- nu-SVR
% -t kernel_type : set type of kernel function (default 2)
% 	0 -- linear: u'*v
% 	1 -- polynomial: (gamma*u'*v + coef0)^degree
% 	2 -- radial basis function: exp(-gamma*|u-v|^2)
% 	3 -- sigmoid: tanh(gamma*u'*v + coef0)
% -d degree : set degree in kernel function (default 3)
% -g gamma : set gamma in kernel function (default 1/num_features)
% -r coef0 : set coef0 in kernel function (default 0)
% -c cost : set the parameter C of C-SVC, epsilon-SVR, and nu-SVR (default 1)
% -n nu : set the parameter nu of nu-SVC, one-class SVM, and nu-SVR (default 0.5)
% -p epsilon : set the epsilon in loss function of epsilon-SVR (default 0.1)
% -m cachesize : set cache memory size in MB (default 100)
% -e epsilon : set tolerance of termination criterion (default 0.001)
% -h shrinking: whether to use the shrinking heuristics, 0 or 1 (default 1)
% -b probability_estimates: whether to train a SVC or SVR model for probability estimates, 0 or 1 (default 0)
% -wi weight: set the parameter C of class i to weight*C, for C-SVC (default 1)
%%

% This file is from pmtk3.googlecode.com

y = colvec(y); 
[shrink, epsilonTube, estProb, customOptions] = process_options...
    (varargin, 'shrink', 0, 'epsilonTube', 0.1, 'estProb', 0, 'customOptions', '');
shrinkSwitch = sprintf('-h %d', shrink);
estProbSwitch = sprintf('-b %d', estProb);

if isempty(customOptions)
    if nargin < 5
        if nargin < 4
            kernelType = 'default';
        else
            kernelType = 'rbf';
        end
    end
    switch lower(kernelType)
        case 'rbf'
            kernelSwitch = '-t 2';
            paramSwitch = sprintf('-g %f', kernelParam);
        case 'polynomial'
            kernelSwitch = '-t 1';
            paramSwitch = sprintf('-d %f', kernelParam);
        case 'linear'
            kernelSwitch = '-t 0';
            paramSwitch = '';
        case 'sigmoid'
            kernelSwitch = '-t 3';
            paramSwitch = sprintf('-g %f', kernelParam);
        otherwise
            kernelSwitch = '';
            paramSwitch = '';
    end
    
    if isequal(y, round(y)) 
        typeSwitch = '-s 0'; %classification (both binary and multiclass)
        epsilonTubeSwitch = '';
    else
        typeSwitch = '-s 3'; %regression
        epsilonTubeSwitch = sprintf('-p %d', epsilonTube);
    end
    Cswitch = sprintf('-c %f', C);
    options = sprintf('%s %s %s %s %s %s %s', ...
        Cswitch, typeSwitch, kernelSwitch, paramSwitch,...
        epsilonTubeSwitch, shrinkSwitch, estProbSwitch);
else
    options = customOptions;
end
model = libsvmTrain(y, X, options);
model.C = C;
model.fitEngine = mfilename();
end
