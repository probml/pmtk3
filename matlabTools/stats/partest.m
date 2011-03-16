function partest(x)
%This function calculate the performance, based on Bayes theorem, of a
%clinical test.
%
% Syntax: 	PARTEST(X)
%      
%     Input:
%           X is the following 2x2 matrix.
%
%....................Affected(D+)..Healthy(D-)
%                    _______________________
%Positive Test(T+)  |   True    |  False    |
%                   | positives | positives |
%                   |___________|___________|
%                   |  False    |   True    |
%Negative Test(T-)  | negatives | negatives |
%                   |___________|___________|
%
%     Outputs:
%           - Prevalence of disease
%           - Test Sensibility with 95% confidence interval
%           - Test Specificity with 95% confidence interval
%           - False positive and negative proportions
%           - Youden's Index
%           - Test Accuracy
%           - Mis-classification Rate
%           - Positive predictivity with 95% confidence interval
%           - Positive Likelihood Ratio
%           - Negative predictivity with 95% confidence interval
%           - Negative Likelihood Ratio
%           - Error odds ratio
%           - Diagnostic odds ratio
%           - Discriminant Power
%           - Test bias
%           - Number needed to Diagnose (NDD)
%
%      Example: 
%
%           X=[80 3; 5 20];
%
%           Calling on Matlab the function: partest(X)
%
%           Answer is:
%
% Prevalence: 78.7%
%  
% Sensitivity (probability that test is positive on unhealthy subject): 94.1%
% 95% confidence interval: 89.1% - 99.1%
% False negative proportion: 5.9%
%  
% Specificity (probability that test is negative on healthy subject): 87.0%
% 95% confidence interval: 73.2% - 100.0%
% False positive proportion: 13.0%
%  
% Youden's Index (a perfect test would have a Youden index of +1): 0.8107
%  
% Accuracy or Potency: 92.6%
% Mis-classification Rate: 7.4%
%  
% Predictivity of positive test (probability that a subject is unhealthy when test is positive): 96.4%
% 95% confidence interval: 92.4% - 100.0%
% Positive Likelihood Ratio: 7.2
% Moderate increase in possibility of disease presence
%  
% Predictivity of negative test (probability that a subject is healthy when test is negative): 80.0%
% 95% confidence interval: 64.3% - 95.7%
% Negative Likelihood Ratio: 0.1
% Large (often conclusive) increase in possibility of disease absence
%  
% Error odds ratio: 2.4000
% Diagnostic odds ratio: 106.6667
% Discriminant Power: 2.6
%      A test with a discriminant value of 1 is not effective in discriminating between affected and unaffected individuals.
%      A test with a discriminant value of 3 is effective in discriminating between affected and unaffected individuals.
% Test bias: 0.9765
% Test underestimates the phenomenon
% Number needed to Diagnose (NDD): 1.2
%
%           Created by Giuseppe Cardillo
%           giuseppe.cardillo-edta@poste.it
%
% To cite this file, this would be an appropriate format:
% Cardillo G. (2006). Clinical test performance: the performance of a
% clinical test based on the Bayes theorem. 
% http://www.mathworks.com/matlabcentral/fileexchange/12705

%Input Error handling
[r,c] = size(x);
if (r ~= 2 || c ~= 2)
    error('Warning: PARTEST requires a 2x2 input matrix')
end
clear r c %clear unnecessary variables

cs=sum(x); %columns sum
rs=sum(x,2); %rows sums
N=sum(x(:)); %numbers of elements
d=diag(x); %true positives and true negatives

%Prevalence
%the prevalence of disease is estimated all D+/N 
pr=(cs(1)/N)*100; 

%Sensitivity and Specificity
%The Sensitivity is the probability that the test is positive on sick subjects: P(T+|D+) 
%The Specificity is the probability that the test is negative on healthy subjects: P(T-|D-) 
%In Matlab both parameters are obtained with only one instruction:
SS=d./cs'; %Sensitivity and Specificity
%Of course the false proportion is the complement to 1
fp=1-SS; %false proportions
% 95% confidence interval critical value for Sensitivity and Specificity
SScv=1.96.*sqrt(SS.*fp./cs'); 
%Of course, the critical interval lower bound cannot be less than 0 and the
%upper bound cant be greater than 1 and so:
Seci=[max(0,SS(1)-SScv(1)) min(1,SS(1)+SScv(1))].*100;
Spci=[max(0,SS(2)-SScv(2)) min(1,SS(2)+SScv(2))].*100;

%Youden's Index
%Youden's J statistics (also called Youden's index) is a single statistic that
%captures the performance of a diagnostic test. The use of such a single index
%is "not generally to be recommended". It is equal to the risk difference for a
%dichotomous test and it defined as: J = Sensitivity + Specificity - 1. 
%A perfect test has J=1. 
J=sum(SS)-1; %Youden's index

%Positive and Negative predictivity
%Positive predictivity is the probability that a subject is sick when test is positive: P(D+|T+)
%Negative predictivity is the probability that a subject is healthy when test is negative: P(D-|T-)
%Positive predictivity=Precision
%In Matlab both parameters are obtained with only one instruction:
PNp=d./rs; %Positive and Negative predictivity
% 95% confidence interval critical value for Positive and Negative predictivity
PNpcv=1.96.*sqrt(PNp.*(1-PNp)./rs); 
%Of course, the critical interval lower bound cannot be less than 0 and the
%upper bound cant be greater than 1 and so:
Ppci=[max(0,PNp(1)-PNpcv(1)) min(1,PNp(1)+PNpcv(1))].*100;
Npci=[max(0,PNp(2)-PNpcv(2)) min(1,PNp(2)+PNpcv(2))].*100;

%Positive and Negative Likelihood Ratio
%When we decide to order a diagnostic test, we want to know which test (or
%tests) will best help us rule-in or rule-out disease in our patient.  In the
%language of clinical epidemiology, we take our initial assessment of the
%likelihood of disease (“pre-test probability”), do a test to help us shift our
%suspicion one way or the other, and then determine a final assessment of the
%likelihood of disease (“post-test probability”). 
%Likelihood ratios tell us how much we should shift our suspicion for a
%particular test result. Because tests can be positive or negative, there are at
%least two likelihood ratios for each test.  The “positive likelihood ratio”
%(LR+) tells us how much to increase the probability of disease if the test is
%positive, while the “negative likelihood ratio” (LR-) tells us how much to
%decrease it if the test is negative.
%You can also define the LR+ and LR- in terms of sensitivity and specificity:
%LR+ = sensitivity / (1-specificity)
%LR- = (1-sensitivity) / specificity
plr=SS(1)/fp(2); %Positive Likelihood Ratio
nlr=fp(1)/SS(2); %Negative Likelihood Ratio

%Accuracy and Mis-classification rate
%The Accuracy (or Power) is the probability that the test correctly classifies 
%the subjects; the Mis-classification rate is its complement to 1.
%In statistics, the F1 score (also F-score or F-measure) is a measure of a
%test's accuracy. It considers both the Precision (positive predictivity) 
%and the Sensitivity of the test to compute the score: 
%P is the number of correct results divided by the number of all returned results
%S is the number of correct results divided by the number of results that should 
%have been returned. 
%The F1 score can be interpreted as a weighted average of the Precision and
%Sensitivity, where an F1 score reaches its best value at 1 and worst score at 0. 
acc=trace(x)/N; %Accuracy
mcr=1-acc; %Mis-classification rate
FMeasure=harmmean([SS(1) PNp(1)]); %F-measure

%Test Bias (TB)
%A test which shows provable and systematic differences in the results of people
%based on group membership. For example, a test might be considered biased if
%members of one particular gender or race consistently and systematic have
%statistically different results from the rest of the testing population. 
%It is defined as (T+)/(D+)=(TP+FP)/(TP+FN)
%A perfect test has a TB=1;
%If TB<1 the test underestimates the disease because there are more affected than positive test
%If TB>1 the test overestimates the disease because there are more positive test than affected
TB=rs(1)/cs(1); %Test Bias

%Error Odds Ratio. 
%Indicates if the probability of being wrongly classified is highest in the
%diseased or in the non-diseased group. If the error odds is higher than one the
%probability is highest in the diseased group (and the specificity of the test
%is better than the sensitivity), if the value is lower than one the probability
%of an incorrect classification is highest in the non-diseased group (and the
%sensitivity of the test is better than the specificity).     
%It is defined as (Sensitivity/(1-Sensitivity))/(Specificity/(1-Specificity));

%Diagnostic Odds Ratio. 
%Often used as a measure of the discriminative power of the test. Has the value
%one if the test does not discriminate between diseased and not diseased. Very
%high values above one means that a test discriminates well. Values lower than
%one mean that there is something wrong in the application of the test.   
%It is defined as (Sensitivity/(1-Sensitivity))/((1-Specificity)/Specificity);
EOR=(SS(1)/fp(1))/(SS(2)/fp(2)); %Error odds ratio
DOR=(SS(1)/fp(1))/(fp(2)/SS(2)); %Diagnostic odds ratio

%Discriminant power
%The discriminant power for a test, also termed the test effectiveness, is a
%measure of how well a test distinguishes between affected and unaffected
%persons. It is the sum of logs of Sensivity and Specificity over own false
%proportion, scaled by the standard deviation of the logistic normal
%distribution curve (square root of 3 divided by π). Test effectiveness is
%interpreted as the standardized distance between the means for both populations.     
%A test with a discriminant value of 1 is not effective in discriminating between affected and unaffected individuals.
%A test with a discriminant value of 3 is effective in discriminating between affected and unaffected individuals.
dpwr=(realsqrt(3)/pi)*sum(log(SS./fp)); %Discriminant power

NDD=1/J; %Number needed to Diagnose (NDD)

%display results
fprintf('Prevalence: %0.1f%%\n',pr)
disp(' ')
fprintf('Sensitivity (probability that test is positive on unhealthy subject): %0.1f%%\n',SS(1)*100)
fprintf('95%% confidence interval: %0.1f%% - %0.1f%%\n', Seci)
fprintf('False negative proportion: %0.1f%%\n',fp(1)*100)
disp(' ')
fprintf('Specificity (probability that test is negative on healthy subject): %0.1f%%\n',SS(2)*100)
fprintf('95%% confidence interval: %0.1f%% - %0.1f%%\n', Spci)
fprintf('False positive proportion: %0.1f%%\n', fp(2)*100)
disp(' ')
fprintf('Youden''s Index (a perfect test would have a Youden index of +1): %0.4f\n', J)
disp(' ')
fprintf('Precision or Predictivity of positive test (probability that a subject is unhealthy when test is positive): %0.1f%%\n', PNp(1)*100)
fprintf('95%% confidence interval: %0.1f%% - %0.1f%%\n', Ppci)
fprintf('Positive Likelihood Ratio: %0.1f\n', plr)
dlr(plr)
disp(' ')
fprintf('Predictivity of negative test (probability that a subject is healthy when test is negative): %0.1f%%\n', PNp(2)*100)
fprintf('95%% confidence interval: %0.1f%% - %0.1f%%\n', Npci)
fprintf('Negative Likelihood Ratio: %0.1f\n', nlr)
dlr(nlr)
disp(' ')
fprintf('F-measure: %0.1f%%\n', FMeasure*100)
fprintf('Accuracy or Potency: %0.1f%%\n', acc*100)
fprintf('Mis-classification Rate: %0.1f%%\n', mcr*100)
disp(' ')
fprintf('Error odds ratio: %0.4f\n',EOR)
fprintf('Diagnostic odds ratio: %0.4f\n',DOR)
fprintf('Discriminant Power: %0.1f\n',dpwr)
disp([blanks(5) 'A test with a discriminant value of 1 is not effective in discriminating between affected and unaffected individuals.'])
disp([blanks(5) 'A test with a discriminant value of 3 is effective in discriminating between affected and unaffected individuals.'])
fprintf('Test bias: %0.4f\n',TB)
if TB>1
    disp('Test overestimates the phenomenon')
elseif TB<1
    disp('Test underestimates the phenomenon')
else
    disp('There is not test bias')
end
fprintf('Number needed to Diagnose (NDD): %0.1f\n',NDD);
xg=cs./N;
figure
hold on
H=zeros(1,4);
H(1)=fill(xg(1)+[0 xg(2) xg(2) 0],SS(2)+[0 0 fp(2) fp(2)],'r');
H(2)=fill([0 xg(1) xg(1) 0],fp(1)+[0 0 SS(1) SS(1)],'g');
H(3)=fill([0 xg(1) xg(1) 0],[0 0 fp(1) fp(1)],'y');
H(4)=fill(xg(1)+[0 xg(2) xg(2) 0],[0 0 SS(2) SS(2)],'b');
hold off
axis square
title('PARTEST GRAPH')
xlabel('Subjects proportion')
ylabel('Parameters proportion')
legend(H,'False Positive','True Positive (Sensibility)','False Negative','True Negative (Specificity)','Location','NorthEastOutside')

%The rose plot is a variation of the common pie chart. For both, we have k data
%points where each point denotes a frequency or a count. Pie charts and rose
%plots both use the area of segments of a circle to convey amounts. 
%The pie chart uses a common radius and varies the central angle according to
%the data. That is, the angle is proportional to the frequency. So if the i-th
%point has count X and the total count is N, the i-th angle is 360*(X/N). 
%For the rose plot, the angle is constant (i.e., divide 360 by the number of
%groups, k) and it is the square root of the radius that is proportional to the
%data. 
%According to Wainer (Wainer (1997), Visual Revelations: Graphical Tales of Fate
%and Deception from Napolean Bonaporte to Ross Perot, Copernicus, Chapter 11.),
%the use of a common angle is the strength of the rose plot since it allows us
%to easily compare a sequence of rose plots (i.e., the corresponding segments in
%different rose plots are always in the same relative position). 
%In particular, this makes rose plots an effective technique for displaying the
%data in contingency tables.  
%As an interesting historical note, Wainer points out that rose plots were used
%by Florence Nightingale (she referred to them as coxcombs).  
%color={'r','g','y','b'};
H=roseplot([fp(2) SS(1) fp(1) SS(2)]);
title('ROSEPLOT PARTEST GRAPH')
legend(H,'False Positive','True Positive (Sensibility)','False Negative','True Negative (Specificity)','Location','NorthEastOutside')
return
end

function dlr(lr) %Likelihood dialog
if lr==1
    disp('Test is not suggestive of the presence/absence of disease')
    return
end

if lr>10 || lr<0.1
    p1='Large (often conclusive)';
elseif (lr>5 && lr<=10) || (lr>0.1 && lr<=0.2)
    p1='Moderate';
elseif (lr>2 && lr<=5) || (lr>0.2 && lr<=0.5)
    p1='Low';
elseif (lr>1 && lr<=2) || (lr>0.5 && lr<=1)
    p1='Poor';
end

p2=' increase in possibility of disease ';

if lr>1
    p3='presence';
elseif lr<1
    p3='absence';
end
disp([p1 p2 p3])
return
end

function H=roseplot(x)
color={'r','g','y','b'};
k=length(x); H=zeros(1,k);
ang=(0:1:k)./k.*2.*pi;
figure
axis square
hold on
for I=1:k
    theta=[ang(I) linspace(ang(I),ang(I+1),500) ang(I+1)];
    rho=[0 repmat(realsqrt(x(I)),1,500) 0];
    [xg,yg]=pol2cart(theta,rho);
    H(I)=patch(xg,yg,color{I});
end
hold off
return
end