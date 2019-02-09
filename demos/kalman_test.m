%https://github.com/QuantEcon/QuantEcon.jl/blob/master/test/test_kalman.jl

A = [.5 .4;
     .3 .2];
Q = [.34 .17;
     .17 .17];
G = [.5 .4];
R = [.05^2];
y = [1. 2. 3. 4.];
cov_init = [0.722222222222222   0.386904761904762;
            0.386904761904762   0.293154761904762];

%{   
    %k = Kalman(A, G, Q, R); 
set_state!(k, zeros(2), cov_init)
x_smoothed, logL, P_smoothed = smooth(k, y)
x_matlab = [1.36158275104493    2.68312458668362    4.04291315305382    5.36947053521018;
            0.813542618042249   1.64113106904578    2.43805629027213    3.22585113133984]
logL_matlab = -22.1434290195012
%}
F=A; H = G;
initmu = [0.0; 0.0];
initV = cov_init;
[xfilt, Vfilt,  loglik] = kalmanFilter(y, F, H, Q, R, initmu, initV);
[xsmooth, Vsmooth] = kalmanSmoother(y, F, H, Q, R, initmu, initV);    

loglik_matlab = -22.14;
xfilt_matlab = ...
    [1.3409    2.6585    4.0142    5.3695;
    0.8076    1.6334    2.4293    3.2259];
xsmooth_matlab = ...
    [1.3616    2.6831    4.0429    5.3695;
    0.8135    1.6411    2.4381    3.2259];