close all
clear 
clc

%% Dataset Creation 

T = readtable('Needs.xls');

logWealth = log(T.Wealth);
logIncome = log(T.Income);

X = [rescale(T.Age)                 ...   % Age
     T.Gender                       ...   % Gender 
     rescale(T.FamilyMembers)       ...   % FamSize
     rescale(T.FinancialEducation)  ...   % FinEdu 
     rescale(T.RiskPropensity)      ...   % Risk
     rescale(logIncome)             ...   % LogIncome
     rescale(logWealth)             ...   % LogWealth
     rescale(T.Income./T.Wealth)];        % IncomeWealthRatio
 
Y = T.Class;

% 0 : no inv need at all
% 1 : need for income investment only 
% 2 : need for accumulation investment only 
% 3 : need for both investment types 

%% Dataset Splitting 
col = [1,5,7,8];
% Number of training samples 
N = numel(X(:,1))*0.9;
% Splitting
Xtrain = X(1:N,col);
Xtest  = X(N+1:end,col);
Ytrain = Y(1:N,:);
Ytest  = Y(N+1:end,:);






