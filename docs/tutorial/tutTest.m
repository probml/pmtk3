%% Compare
% In the spirit of reproducible research,
% we created a simpler demo, called
% linearKernelDemo.m , 
% which only uses linear kernels (so we don't have to cross validate
% over gamma in the RBF kernel) and only runs on a few datasets.
% This is much faster, allowing us to perform multiple trials.
% Below we show the median misclassification rates on the different data sets,
% averaged over 3 random splits.
% We also added logregL1path and logregL2path to the mix;
% these are written in Fortran (glmnet).
% The results are shown below.
%%
% <html>
% <TABLE BORDER=3 CELLPADDING=5 WIDTH="100%" >
% <TR><TH COLSPAN=7 ALIGN=center> test error rate (median over 3 trials) </font></TH></TR>
% <TR ALIGN=left>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000></FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>SVM</FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>RVM</FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>SMLR</FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>RMLR</FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>logregL2</FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>logregL1</FONT></TH>
% </TR>
% <tr>
% <td BGCOLOR=#00CCFF><FONT COLOR=000000>soy</FONT>
% <td> 0.108
% <td> 0.108
% <td> 0.118
% <td> 0.129
% <td> 0.710
% <td> 0.108
% <tr>
% <td BGCOLOR=#00CCFF><FONT COLOR=000000>fglass</FONT>
% <td> 0.477
% <td> 0.554
% <td> 0.400
% <td> 0.431
% <td> 0.708
% <td> 0.492
% <tr>
% <td BGCOLOR=#00CCFF><FONT COLOR=000000>colon</FONT>
% <td> 0.211
% <td> 0.211
% <td> 0.158
% <td> 0.211
% <td> 0.316
% <td> 0.211
% <tr>
% <td BGCOLOR=#00CCFF><FONT COLOR=000000>amlAll</FONT>
% <td> 0.455
% <td> 0.227
% <td> 0.136
% <td> 0.182
% <td> 0.364
% <td> 0.182
% </table>
% </html>
%%
% Before reading too much into these results,
% let's look at the boxplots, which show that
% the differences are probably not signficant
% (we don't plot L2 lest it distort the scale)
%%
% <html>
% <img 
% src="http://pmtk3.googlecode.com/svn/trunk/docs/tutorial/extraFigures/linearKernelBoxplotErr.png">
% </html>
%%
% Below are the training times in seconds (median over 3 trials)
%
%%
% <html>
% <TABLE BORDER=3 CELLPADDING=5 WIDTH="100%" >
% <TR><TH COLSPAN=7 ALIGN=center> training time in seconds (median over 3 trials) </font></TH></TR>
% <TR ALIGN=left>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000></FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>SVM</FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>RVM</FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>SMLR</FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>RMLR</FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>logregL2</FONT></TH>
% <TH BGCOLOR=#00CCFF><FONT COLOR=000000>logregL1</FONT></TH>
% </TR>
% <tr>
% <td BGCOLOR=#00CCFF><FONT COLOR=000000>soy</FONT>
% <td> 0.566
% <td> 0.549
% <td> 43.770
% <td> 24.193
% <td> 0.024
% <td> 0.720
% <tr>
% <td BGCOLOR=#00CCFF><FONT COLOR=000000>fglass</FONT>
% <td> 0.586
% <td> 0.146
% <td> 67.552
% <td> 30.204
% <td> 0.043
% <td> 0.684
% <tr>
% <td BGCOLOR=#00CCFF><FONT COLOR=000000>colon</FONT>
% <td> 1.251
% <td> 0.028
% <td> 2.434
% <td> 2.618
% <td> 0.021
% <td> 0.418
% <tr>
% <td BGCOLOR=#00CCFF><FONT COLOR=000000>amlAll</FONT>
% <td> 3.486
% <td> 0.017
% <td> 2.337
% <td> 2.569
% <td> 0.097
% <td> 1.674
% </table>
% </html>
%%
% And here are the boxplots
%%
% <html>
% <img 
% src="http://pmtk3.googlecode.com/svn/trunk/docs/tutorial/extraFigures/linearKernelBoxplotTime.png">
% </html>
%%
% We see that the RVM is consistently the fastest.
% which is somewhat surprising since the SVM code is in C.
% However, the SVM needs to use cross validation, whereas RVM uses
% empirical Bayes.
%
