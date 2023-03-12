clc
clear 
close all

% Load data 
load('C:\Users\andre\Desktop\Magistrale\FINTECH\ZENTI\Progetto 3\EWS.mat')

%% DATA EXPLORATION 

Time = Data;

% Plot USA stock market against response 
% figure()
% yyaxis left
% b = bar(Time,Y);
% ylabel('Y (risk-on/risk-off)')
% yyaxis right
% p= plot(Time,MXUS);
% ylabel('MSCI USA')
% p.LineWidth = 3;
% title('US Equities and risk-on/risk-off periods')
% xlabel('Timeline')

% Plot VIX against response 
% figure()
% yyaxis left
% b = bar(Time,Y);
% ylabel('Y (risk-on/risk-off)')
% yyaxis right
% p= plot(Time,VIX);
% ylabel('VIX')
% p.LineWidth = 3;
% title('US Equities and risk-on/risk-off periods')
% xlabel('Timeline')

% Plot 2Y-10Y US Treasury Bond spread against response 
spread2Y10Y = GT10-USGG2YR;
% figure()
% yyaxis left
% b = bar(Time,Y);
% ylabel('Y (risk-on/risk-off)')
% yyaxis right
% p = plot(Time,spread2Y10Y);
% ylabel('spread2Y10Y')
% p.LineWidth = 3;
% title('US Equities and risk-on/risk-off periods')
% xlabel('Timeline')


% Always positive variables   => log-differences (log-returns)
Indices_Currencies = [XAUBGNL BDIY CRY Cl1 DXY EMUSTRUU GBP JPY LF94TRUU...
       LF98TRUU LG30TRUU LMBITR LP01TREU...
       LUACTRUU LUMSTRUU MXBR MXCN MXEU MXIN MXJP MXRU MXUS VIX]; % 23

% Possibly negative variables => first differences
InterestRates = [EONIA GTDEM10Y GTDEM2Y GTDEM30Y GTGBP20Y GTGBP2Y GTGBP30Y...
    GTITL10YR GTITL2YR GTITL30YR GTJPY10YR GTJPY2YR GTJPY30YR US0001M USGG3M USGG2YR GT10 USGG30YR]; % 18

Data = [diff(log(Indices_Currencies)) ECSURPUS(2:end) diff(InterestRates)];  % make stationary
Response = Y(2:end);                                                         % we lose one observation
Time = Time(2:end);                                                          % at the first day 

%% oversampling
% num1 = sum(Response);
% num0 = size(Response,1) - num1;
% index1 = find(Response==1);
% index0 = find(Response==0);
% toAdd = 100;
% toAddIndex = randsample(index1,toAdd);
% Data = [Data; Data(toAddIndex,:)];
% Response = [Response; Response(toAddIndex,1)];
%% 
% 
% abn_mean = mean(Data(Response == 1,:));
% norm_mean = mean(Data(Response == 0,:));
% diff_mean = rescale(abs(abn_mean - norm_mean))';
% index = find(diff_mean>0.5);
% 
% X = [Data(:,index) GT10(2:end)-USGG2YR(2:end)];

%% permutational test
% n = size(Data,1);
% p = size(Data,2);
% 
% B = 10000;
% pval = zeros(p,5);
% for col_index = 1:p
%     index0 = find(Response==0);
%     index1 = find(Response==1);
%     n1 = length(index1);
%     n0 = length(index0);
%     feature = Data(:,col_index);
%     x0 = feature(index0);
%     x1 = feature(index1);
%     x_pooled = [x1; x0];
%     T1 = abs(quantile(x0,0.05) - quantile(x1,0.05));
%     T2 = abs(quantile(x0,0.25) - quantile(x1,0.25));
%     T3 = abs(quantile(x0,0.5)  - quantile(x1,0.5)) ;
%     T4 = abs(quantile(x0,0.75) - quantile(x1,0.75));
%     T5 = abs(quantile(x0,0.90) - quantile(x1,0.90));
%     T0 = [T1, T2, T3, T4, T5];
%     T_stat = zeros(B,5);
%     for perm = 1:B
%       permutation = randperm(size(Data,1));
%       x_perm = x_pooled(permutation,1);
%       x0_perm = x_perm(1:n0,1);
%       x1_perm = x_perm((n0+1):n,1);
%       T_stat(perm,1) = abs(quantile(x0_perm,0.05) - quantile(x1_perm,0.05));
%       T_stat(perm,2) = abs(quantile(x0_perm,0.25) - quantile(x1_perm,0.25));
%       T_stat(perm,3) = abs(quantile(x0_perm,0.5)  - quantile(x1_perm,0.5)) ;
%       T_stat(perm,4) = abs(quantile(x0_perm,0.75) - quantile(x1_perm,0.75));
%       T_stat(perm,5) = abs(quantile(x0_perm,0.90) - quantile(x1_perm,0.90));
%     end
%     pval(col_index,1) = sum(T_stat(:,1)>=T0(1))/B;
%     pval(col_index,2) = sum(T_stat(:,2)>=T0(2))/B;
%     pval(col_index,3) = sum(T_stat(:,3)>=T0(3))/B;
%     pval(col_index,4) = sum(T_stat(:,4)>=T0(4))/B;
%     pval(col_index,5) = sum(T_stat(:,5)>=T0(5))/B;
% end
% pval2 = pval
%% test pvalues
n = size(Data,1);
p = size(Data,2);
index=[];
threshold = 0.05;
percentage = 0.7; % if higher, then less variables
w = [1, 1, 1, 1, 1];
w = w/sum(w);
for row = 1:p
    lin_comb = 0;
    for col = 1:5
       lin_comb = lin_comb + (pval(row,col) < threshold) * w(col);
    end
    if lin_comb > percentage
        index = [index row];
    end
end
index = [index 23 24]
% financial features
% index = [1, 24, 23, 41, 40, 39, 25, 14, 10, 22, 18, 17, 33]
%% 
 X = [Data(:,index) GT10(2:end)-USGG2YR(2:end)];
 X = Data(:,index);
size(X)
%% 0: 237; 1: 873 
X_OG = X;
Response_OG = Response;
rng('default')
idx_perm = randperm(size(X,1));
X = X(idx_perm,:);
Response = Response(idx_perm,1);
index0 = find(Response==0); index1 = find(Response==1);
X0 = X(index0,:);
X1 = X(index1,:);
% train solo da X0, validation e test sono un po' e un po'
Xtrain = X0(1:600, :);
Xval = [X1(1:100,:); X0(600:700,:)];
ResponseVal = [ones(100,1); zeros(100+1,1)];
Xtest = [X1(100:237,:); X0(700:873,:)];
ResponseTest = [ones(137+1,1); zeros(173+1,1)];
% reshuffle
randpermVal = randperm(size(Xval,1));
Xval = Xval(randpermVal,:);
ResponseVal = ResponseVal(randpermVal,1);
randpermTest = randperm(size(Xtest,1));
Xtest = Xtest(randpermTest,:);
ResponseTest = ResponseTest(randpermTest,1);
% Xtrain = X(1:900,:);
% ResponseTrain = Response(1:900,1);
% Xtest = X(901:end,:);
% ResponseTest = Response(901:end,1);
% Xval = Xtrain(1:100,:);
% ResponseVal = ResponseTrain(1:100,1);
% Xtrain = Xtrain(101:end,:);
% ResponseTrain = ResponseTrain(101:end,1);

nSampleTrain = size(Xtrain,1);
nFeatures = size(Xtrain,2);
%% copulafit
uTrain = zeros(nSampleTrain, nFeatures);

for i = 1:nFeatures
    uTrain(:,i) = ksdensity(Xtrain(:,i), Xtrain(:,i), 'function', 'cdf');
end

rhohat0 = copulafit('Gaussian', uTrain); 
% [rhohat0,nu0] = copulafit('t', uTrain); % fit Copula t
%% CV
nSampleVal = size(Xval,1);
uCV = zeros(nSampleVal, nFeatures);

for i = 1:nFeatures
    uCV(:,i) = ksdensity(Xval(:,i), Xval(:,i), 'function', 'cdf');
end

p = copulapdf('Gaussian',uCV,rhohat0); % parameters estimated on the train set
% p = copulapdf('t',uCV,rhohat0,nu0); % parameters estimated on the train set
[bestEpsilon, bestF1] = OptimThreshold(ResponseVal, p) % find the optimal hyperparameter

%% test
nSampleTest = size(Xtest,1);
uTest = zeros(nSampleTest, nFeatures);

for i = 1:nFeatures
    uTest(:,i) = ksdensity(Xtest(:,i), Xtest(:,i), 'function', 'cdf');
end

p = copulapdf('Gaussian',uTest,rhohat0);
% p = copulapdf('t',uTest,rhohat0,nu0);
predictions = p < bestEpsilon;
tp = sum((predictions == 1) & (ResponseTest == 1));
fp = sum((predictions == 1) & (ResponseTest == 0));
fn = sum((predictions == 0) & (ResponseTest == 1));
prec = tp / (tp + fp) % positivi veri che il modello azzecca / positivi secondo il modello
rec = tp / (tp + fn) % positivi veri che il modello azzecca / positivi 
F1 = 2 * prec * rec / (prec + rec)



































%% OptimThreshold
function [bestEpsilon bestF1] = OptimThreshold(ycval, p)
% Find the best threshold (epsilon) to use for selecting anomalies
% ycval = responses Y=1 if anomaly, 0 otherwise
% p = density;

bestEpsilon = 0;
bestF1 = 0;
stepsize = (max(p) - min(p)) / 1000;

for epsilon = min(p):stepsize:max(p)

    predictions = p < epsilon;
    tp = sum((predictions == 1) & (ycval == 1));
    fp = sum((predictions == 1) & (ycval == 0));
    fn = sum((predictions == 0) & (ycval == 1));
    prec = tp / (tp + fp);
    rec = tp / (tp + fn);
    F1 = 2 * prec * rec / (prec + rec);

    if F1 > bestF1
        bestF1 = F1;
        bestEpsilon = epsilon;
    end
    
end

end


