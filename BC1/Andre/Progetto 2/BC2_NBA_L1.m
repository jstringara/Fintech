clear 
close all
clc


%% Data Loading 

path = '/Users/andre/Desktop/Magistrale/FINTECH/ZENTI/Progetto 2/Needs1.mat';
load(path)
Data = Needs;


%% Data Transformation 

logWealth = log(Data.Wealth);
logIncome = log(Data.Income);

X =[rescale(Data.Age) Data.Gender rescale(Data.FamilyMembers) rescale(Data.FinancialEducation)...
    rescale(Data.RiskPropensity) rescale(logIncome) rescale(logWealth)];

Y1 = Data.IncomeInvestment;
Y2 = Data.AccumulationInvestment;

Y = Y2;

%% Feature Engineering 

X = [X , rescale(Data.Income./Data.Wealth)];


%% Dataset Splitting

train_ratio = 0.9;

N_train = floor(numel(X(:,1))*train_ratio);


Xtrain = X(1:N_train,:);
Xtest  = X(N_train+1:end,:);

Ytrain = Y(1:N_train,:);
Ytest  = Y(N_train+1:end,:);

%% Random Forest with Bagging

rng(5)
template = templateTree('MaxNumSplits',5,'MinLeafSize',100);
MdlBagging = fitcensemble(Xtrain,Ytrain,'Method','Bag','Learners',template,'KFold',5,'CrossVal','on');
MdlOptimum = fitcensemble(Xtrain,Ytrain,'OptimizeHyperparameters','auto','Learners',template, ...
    'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName','expected-improvement-plus'));

%% Visualize 

CVLoss = kfoldLoss(MdlBagging,'Mode','cumulative');
figure
plot(CVLoss);
ylabel('10-fold Misclassification rate');
xlabel('Learning cycle');


%% 

% Predict with the models the Test set 
[labels,scores] = predict(MdlOptimum,Xtest);
% Rates 
tp   = sum((labels == '1') & (Ytest=='1'));
fp   = sum((labels == '1') & (Ytest=='0'));
fn   = sum((labels == '0') & (Ytest=='1'));
% Precision
prec = tp / (tp + fp);


%% Next Best Action #1 

% Retrieving clients IDs
ClientID = Data.ID;
ClientIDTest   = ClientID(N_train+1:end,:);
TargetClientID = ClientIDTest(labels=='1');

% Retrieving clients' risk propensities
ClientRiskPropensity = Data.RiskPropensity;
ClientRiskPropensityTest   = ClientRiskPropensity(N_train+1:end,:);
TargetClientRiskPropensity = ClientRiskPropensityTest(labels=='1');

% Let's have a look at these risk propensities...
figure()
histogram(ClientRiskPropensityTest, 'FaceColor', 'r')
title('Risk Propensity of target clients')
xlabel('Risk propensity')
ylabel('Frequency')

% Find NBA
AccumulationProducts = Products(Products.Type == 1,:);
NBA_IDProduct        = []; % --> will store id of recommendation 
RecommendedRiskLevel = []; % --> will store risk of recommendation
minRisk    = min(AccumulationProducts.Risk);
product_ID = cast(AccumulationProducts.ID, "uint16");
client_ID  = cast(TargetClientID, "uint16");

for i = 1: size(TargetClientRiskPropensity, 1)
    if TargetClientRiskPropensity(i)> minRisk
        % find the suitable product with the highest acceptable risk
        M = max(AccumulationProducts.Risk(AccumulationProducts.Risk<TargetClientRiskPropensity(i)));
        NBA_IDProduct = [NBA_IDProduct; product_ID(AccumulationProducts.Risk == M)];
    else
        % no suitable product in the product range -> add a zero
        NBA_IDProduct = [NBA_IDProduct; 0];
        M = 0;
    end
    % Add the risk level of the recommendation 
    RecommendedRiskLevel = [RecommendedRiskLevel; M];
end

% recommendations
NBA = [client_ID NBA_IDProduct];

figure
c = linspace(0,1,length(TargetClientRiskPropensity));
scatter(TargetClientRiskPropensity, RecommendedRiskLevel, [], c, 'filled')
title('Adequacy: client risk propensity vs product risk')
xlabel('Client risk propensity')
ylabel('Product risk')


%% Next Best Action #2

% Retrieving clients IDs
ClientID       = Data.ID;
ClientIDTest   = ClientID(N_train+1:end,:);
TargetClientID = ClientIDTest(labels=='1');

% Retrieving clients' risk propensities
ClientRiskPropensity       = Data.RiskPropensity;
ClientRiskPropensityTest   = ClientRiskPropensity(N_train+1:end,:);
TargetClientRiskPropensity = ClientRiskPropensityTest(labels=='1');

% Find NBA
AccumulationProducts = Products(Products.Type == 1,:);
NBA_IDProduct        = []; % --> will store id of recommendation 
RecommendedRiskLevel = []; % --> will store risk of recommendation
minRisk    = min(AccumulationProducts.Risk);
minRisk    = minRisk*0.7;
product_ID = cast(AccumulationProducts.ID, "uint16");
client_ID  = cast(TargetClientID, "uint16");

for i = 1: size(TargetClientRiskPropensity, 1)
    if TargetClientRiskPropensity(i)> minRisk
        % Find the closest product wrt risk 
        diff = abs(AccumulationProducts.Risk - TargetClientRiskPropensity(i));
        [M,Ind] = min(diff);        
        % Add the product ID to the recommendation list 
        NBA_IDProduct = [NBA_IDProduct; product_ID(Ind)];
        % Add the risk level of the recommendation 
        RecommendedRiskLevel = [RecommendedRiskLevel; AccumulationProducts.Risk(Ind)];
    else
         % Add the product ID to the recommendation list 
        NBA_IDProduct = [NBA_IDProduct; 0];
        % Add the risk level of the recommendation 
        RecommendedRiskLevel = [RecommendedRiskLevel; 0];
    end
    
end

% recommendations
NBA = [client_ID NBA_IDProduct];

figure
c = linspace(0,1,length(TargetClientRiskPropensity));
scatter(TargetClientRiskPropensity, RecommendedRiskLevel, [], c, 'filled')
title('Adequacy: client risk propensity vs product risk')
xlabel('Client risk propensity')
ylabel('Product risk')


