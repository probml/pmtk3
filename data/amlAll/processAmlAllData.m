function [Xtrain, ytrain, Xtest, ytest] = processAmlAllData()


raw = getText('data_set_ALL_AML_train.txt');
raw = removeEmpty(raw);
raw = cellfuncell(@(c)tokenize(c, '\t'), raw);
raw(1) = []; % header
raw = cellfuncell(@(c)c(3:end), raw);

Xtrain = zeros(38, 7129);

for i=1:numel(raw)
    Xtrain(:, i) = cell2mat(cellfuncell(@(c)str2double(c), raw{i}(1:2:end)));
end


raw = getText('data_set_ALL_AML_independent.txt');
raw = removeEmpty(raw);
raw = cellfuncell(@(c)tokenize(c, '\t'), raw);
raw(1) = []; % header
raw = cellfuncell(@(c)c(3:end), raw);

Xtest = zeros(34, 7129);

for i=1:numel(raw)
    Xtest(:, i) = cell2mat(cellfuncell(@(c)str2double(c), raw{i}(1:2:end)));
end


%% y data from table_ALL_AML.doc 
% (hand processed)
ALL = -1;
AML = 1;
ytrain = ALL*ones(38, 1);  
ytrain(28:38) = AML; 

ytest = -1*ones(34, 1); 
ytest([12:16, 19:20, 22:28]) = AML; 

save('amlAll', 'Xtrain', 'ytrain', 'Xtest', 'ytest'); 

%% ytest data

%1  		ALL 	
%2  		ALL 	
%3  		ALL 	
%4  		ALL 	
%5  		ALL 	
%6  		ALL 	
%7  		ALL 	
%8  		ALL 	
%9  		ALL 	
%10  		ALL 	
%11  		ALL 	
%12  		AML 	
%13 		AML 	
%14  		AML 	
%15  		AML		
%16  		AML		
%17  		ALL		
%18 		ALL		
%19  		AML		
%20  		AML		
%21  		ALL 	
%22  		AML		
%23  		AML		
%24  		AML 	
%25  		AML 	
%26  		AML 	
%27  		AML 	
%28  		AML 	
%29  		ALL		
%30  		ALL		
%31  		ALL		
%32  		ALL		
%33  		ALL		
%34 		ALL		






end