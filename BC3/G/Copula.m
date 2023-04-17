clc
clear 
close all

% Load data 
load('C:\Users\giuli\OneDrive\Desktop\Fintech\Fintech\BC3\Zenti\EWS.mat')
%% 

% Always positive variables   => log-differences (log-returns)
Indices_Currencies = [XAUBGNL BDIY CRY Cl1 DXY EMUSTRUU GBP JPY LF94TRUU...
                      LF98TRUU LG30TRUU LMBITR LP01TREU...
                      LUACTRUU LUMSTRUU MXBR MXCN MXEU MXIN MXJP MXRU MXUS VIX];

% Possibly negative variables => first differences (variations)
InterestRates = [EONIA GTDEM10Y GTDEM2Y GTDEM30Y GTGBP20Y GTGBP2Y GTGBP30Y...
                 GTITL10YR GTITL2YR GTITL30YR GTJPY10YR GTJPY2YR...
                 GTJPY30YR US0001M USGG3M USGG2YR GT10 USGG30YR];
             
% Stationary Features  
X = [diff(log(Indices_Currencies)) ECSURPUS(2:end) diff(InterestRates)]; 

% Response 
Response = Y(2:end);      

% Time window 
Days = Data(1:end);       
%% FEATURE SELECTION 
% We have proceeded in feature selection on Python 
%  - we have applied a statistical test to discard features that did not
%    have a relevant change in distributions between the classes
%  - we have eliminated highly correlated features 
%  - we have selected a subset of the remaining features accordingly to
%    their financial menaing and geographical information 

% Selected Features 
selected_cols = [2 3 25 27 30 16 18 22 40 23];
X = X(:,selected_cols);

%SISTEMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA


%% DATASET SPLITTING 

% Splitting for copula novelty detection models

% Tot number of samples 
nObs = length(Response);   

% Tot number of normal samples 
nObsNorm = sum(Response == 0); 
% Tot number of abnormal samples 
nObsAbNorm = nObs - nObsNorm; 

% Training set size (normal samples only)
nObsTrain = round(0.80*nObsNorm); 

% Validation set normal portion size 
nObsCVNorm = round(0.10*nObsNorm); 
% Validation set abnormal portion size (balanced wrt normal part)
nObsCVabNorm = nObsCVNorm; 

% Test set abnormal portion size 
nObsTest_abNorm = nObsAbNorm - nObsCVabNorm; 

% Dataset Shuffling 
idxPermutation = randperm(nObs);

X = X(idxPermutation,:);
Response = Response(idxPermutation);

% dividing normal/abnormal
Xnormal   = X(Response == 0,:);
Xabnormal = X(Response == 1,:);        % we don't need response for training set (all zeros)
Yabnormal = Response(Response == 1,:);

% TRAINING SET 
X_train = Xnormal(1:nObsTrain,:);
% VALIDATION SET 
XCV     = [Xnormal(nObsTrain+1:nObsTrain+1+nObsCVNorm,:); Xabnormal(1:nObsCVabNorm,:)];
% TEST SET 
X_test  = [Xnormal(nObsTrain+1+nObsCVNorm+1:end,:); Xabnormal(nObsCVabNorm+1:end,:)];

% Responses 
yCV = zeros(length(XCV),1);
yCV(end-nObsCVabNorm+1:end) = Yabnormal(1:nObsCVabNorm);
Y_test = zeros(length(X_test),1);
Y_test(end-nObsTest_abNorm+1:end) = Yabnormal(nObsCVabNorm+1:end);

%% %% DATA RESCALING 
% We choose to apply a min-Max sacaling transformation to the data 

% Test set scaling wrt training set 
for i = 1:numel(selected_cols)
   X_test(:,i) = rescale(X_test(:,i),min(X_train(:,i)),max(X_train(:,i))); 
end

% Validation set scaling wrt training set 
for i = 1:numel(selected_cols)
   XCV(:,i) = rescale(XCV(:,i),min(X_train(:,i)),max(X_train(:,i))); 
end

% Training set scaling 
for i = 1:numel(selected_cols)
   X_train(:,i) = rescale(X_train(:,i)); 
end
%% COPULAS NOVELTY DETECTION MODELS #1 T-Student Copula 

% Trainin set size 
[nSample, nFeatures] = size(X_train(:,:));

% T-student copula fitting 
uTrain = zeros(nSample, nFeatures);
for i = 1:nFeatures
    uTrain(:,i) = ksdensity(X_train(:,i), X_train(:,i), 'function', 'cdf');
end
[rhohat0, nuhat0] = copulafit('t', uTrain); % fit Copula t
%% HYPERPARAMETER EPSILON TUNING 
% We performed hyperparameter tuning on the validation set by optimizing
% different performance measures in the function "OptimThreshold"

% Validation Set size 
[nSample, nFeatures] = size(XCV(:,:));

% Validation set solution of the model 
uCV = zeros(nSample, nFeatures);
for i = 1:nFeatures
    uCV(:,i) = ksdensity(XCV(:,i), XCV(:,i), 'function', 'cdf');
end
p = copulapdf('t',uCV,rhohat0,nuhat0); 

% Cross Validation Tuning 
[bestEpsilon, bestrec] = OptimThreshold(yCV, p);

disp('--- T-Student copula model ---')
disp('Best Epsilon:')
disp(bestEpsilon)
disp('Best Performance Measure on validation:')
disp(bestrec)
%% TEST SET MODEL PERFORMANCE  
% We analyzed our model performance on the unseen test set 

% Test set size 
[nSample, nFeatures] = size(X_test(:,:));

% Test set solution of the model 
uTest = zeros(nSample, nFeatures);
for i = 1:nFeatures
    uTest(:,i) = ksdensity(X_test(:,i), X_test(:,i), 'function', 'cdf');
end
p = copulapdf('t',uTest,rhohat0,nuhat0);

% Model predictions 
predictions = p < bestEpsilon;

% Performance Measures 
tp = sum((predictions == 1) & (Y_test == 1));
fp = sum((predictions == 1) & (Y_test == 0));
fn = sum((predictions == 0) & (Y_test == 1));
tn = sum((predictions == 0) & (Y_test == 0));

accuracy  = (tp+tn)/(tp+fp+tn+fn);
precision = tp / (tp + fp);
recall    = tp / (tp + fn);
F1_score  = 2 * precision * recall / (precision + recall);

disp('Recall on test set:')
disp(recall)
disp('Precision on test set:')
disp(precision)
%% COPULAS NOVELTY DETECTION MODELS #2 Gaussian Copula 

% Trainin set size 
[nSample, nFeatures] = size(X_train(:,:));

% Gaussian copula fitting 
uTrain = zeros(nSample, nFeatures);
for i = 1:nFeatures
    uTrain(:,i) = ksdensity(X_train(:,i), X_train(:,i), 'function', 'cdf');
end
[rhohat0] = copulafit('Gaussian', uTrain); 
%% HYPERPARAMETER EPSILON TUNING 
% We performed hyperparameter tuning on the validation set by optimizing
% different performance measures in the function "OptimThreshold"

% Validation Set size 
[nSample, nFeatures] = size(XCV(:,:));

% Validation set solution of the model 
uCV = zeros(nSample, nFeatures);
for i = 1:nFeatures
    uCV(:,i) = ksdensity(XCV(:,i), XCV(:,i), 'function', 'cdf');
end
p = copulapdf('Gaussian',uCV,rhohat0); 

% Cross Validation Tuning 
[bestEpsilon, bestrec] = OptimThreshold(yCV, p);

disp('--- Gaussian copula model ---')
disp('Best Epsilon:')
disp(bestEpsilon)
disp('Best Performance Measure on validation:')
disp(bestrec)

%% TEST SET MODEL PERFORMANCE  
% We analyzed our model performance on the unseen test set 

% Test set size 
[nSample, nFeatures] = size(X_test(:,:));

% Test set solution of the model 
uTest = zeros(nSample, nFeatures);
for i = 1:nFeatures
    uTest(:,i) = ksdensity(X_test(:,i), X_test(:,i), 'function', 'cdf');
end
p = copulapdf('Gaussian',uTest,rhohat0);

% Model predictions 
predictions = p < bestEpsilon;

% Performance Measures 
tp = sum((predictions == 1) & (Y_test == 1));
fp = sum((predictions == 1) & (Y_test == 0));
fn = sum((predictions == 0) & (Y_test == 1));
tn = sum((predictions == 0) & (Y_test == 0));

accuracy  = (tp+tn)/(tp+fp+tn+fn);
precision = tp / (tp + fp);
recall    = tp / (tp + fn);
F1_score  = 2 * precision * recall / (precision + recall);

disp('Recall on test set:')
disp(recall)
disp('Precision on test set:')
disp(precision)
%% 










