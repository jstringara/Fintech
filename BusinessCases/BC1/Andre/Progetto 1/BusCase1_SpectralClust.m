close all
clear
clc

load('C:\Users\giuli\OneDrive\Desktop\Fintech\ZENTI\Progetto 1/BankClients.mat')

%% 

%% DATA 

% --- NUMERICAL FEATURES 
N = vartype('numeric');
Data = BankClients(:,2:end);    % Exclude 1st col = ID
NumFeatures = Data(:,N);        % subtable of numerical features
XNum = NumFeatures.Variables;
for i = 1:size(XNum,2)
    XNum(:,i) = rescale(XNum(:,i)); % normalize in [0, 1], mostly unnecessary here
end

% --- CATEGORICAL FEATURES 
C = vartype('categorical');
CatFeatures = Data(:,C); % subtable of categorical features

% Encoding (i.e. create dummy variables)
XCat = [];
for i = 1:size(CatFeatures, 2)
    XCat_i = dummyvar(grp2idx(CatFeatures{:,i}));
    XCat = [XCat XCat_i(:,1:end-1)]; 
end

X = [XCat XNum];

% --- SUBSAMPLING 
nSubSample = 1950;
rng('default') % for reproducibility
randRows = randperm(size(X, 1), nSubSample);
X = X(randRows', :);
%% 


%% DIMENSONALITY REDUCTION (PCA)

% 2D PCA 
[coeff,score,latent] = pca(X);
figure
scatter(score(:,1),score(:,2), 'r')
title('2-D Embedding with PCA')
Y = [score(:,1), score(:,2), score(:,3)];
% 3D PCA
figure
scatter3(score(:,1),score(:,2),score(:,3),...
        'MarkerEdgeColor','c',...
        'MarkerFaceColor',[0 .25 .85])
title('3-D Embedding with PCA')
view(-30,15)
%% 

%% DIMENSONALITY REDUCTION (T-SNE)

rng('default') 
Y = tsne(X,'Algorithm','exact','Distance', @MixDistance,'NumDimensions',3);
figure
scatter3(Y(:,1),Y(:,2),Y(:,3),...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',[0 .75 .75])
title('3-D Embedding')
view(-30,15)

%% 

%% CLUSTERING 
% Spectral Clustering Algorithm 

Distance = MixDistance(X,X);
Similarity = exp(-Distance.^2); % kernel transformation
issymmetric(Similarity); % check symmetry
nCluster = 4;
[SpectralIdx, V, D] = spectralcluster(Similarity,nCluster,'Distance','precomputed','LaplacianNormalization','symmetric');

figure
for i = 1:nCluster
    scatter3(Y(SpectralIdx==i,1),Y(SpectralIdx==i,2),Y(SpectralIdx==i,3),...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',[rand() rand() rand()])  % random colors
    hold on
end
title('3-D Embedding of 5 clusters')
hold off
legend
%% 

%% CLUSTER ANALYSIS

Xtot = BankClients;

X0 = Xtot(DBSCANidx==1,:);
X1 = Xtot(DBSCANidx==2,:);
X2 = Xtot(DBSCANidx==3,:);
X3 = Xtot(DBSCANidx==4,:);

% 1 Age distribution 
figure
temp = mean(BankClients.Age);
subplot(2,2,1)
histogram(X0.Age)
loc = mean(X0.Age);
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
subplot(2,2,2)
loc = mean(X1.Age);
histogram(X1.Age)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
subplot(2,2,3)
loc = mean(X2.Age);
histogram(X2.Age)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
subplot(2,2,4)
loc = mean(X3.Age);
histogram(X3.Age)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
sgtitle('Age')

X0_ = X0;
X1_ = X1;
X2_ = X2;
X3_ = X3;
X4_ = X4;

X1 = X0_;
X2 = X1_;
X3 = X2_;
X4 = X3_;

% 2 Income distribution
figure
temp = mean(BankClients.Income);
subplot(2,2,1)
loc = mean(X1.Income);
histogram(X1.Income)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
subplot(2,2,2)
loc = mean(X2.Income);
histogram(X2.Income)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
subplot(2,2,3)
loc = mean(X3.Income);
histogram(X3.Income)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
subplot(2,2,4)
histogram(X4.Income)
loc = mean(X4.Income);
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
sgtitle('Income')

% 3 Wealth distribution
figure
temp = mean(BankClients.Wealth);
subplot(2,2,1)
loc = mean(X1.Wealth);
histogram(X1.Wealth)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
subplot(2,2,2)
loc = mean(X2.Wealth);
histogram(X2.Wealth)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
subplot(2,2,3)
loc = mean(X3.Wealth);
histogram(X3.Wealth)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
subplot(2,2,4)
loc = mean(X4.Wealth);
histogram(X4.Wealth)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
sgtitle('Wealth')

% 4 Debt distribution 
figure
temp = mean(BankClients.Debt);
subplot(2,2,1)
histogram(X1.Debt)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
loc = mean(X1.Debt);
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
subplot(2,2,2)
histogram(X2.Debt)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
loc = mean(X2.Debt);
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
subplot(2,2,3)
histogram(X3.Debt)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
loc = mean(X3.Debt);
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
subplot(2,2,4)
histogram(X4.Debt)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
loc = mean(X4.Debt);
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
sgtitle('Debt')

% 5 CitySize distribution
figure
subplot(2,2,1)
histogram(X1.CitySize)
subplot(2,2,2)
histogram(X2.CitySize)
subplot(2,2,3)
histogram(X3.CitySize)
subplot(2,2,4)
histogram(X4.CitySize)
sgtitle('CitySize')

% 6 BankFriend distribution 
figure
temp = mean(BankClients.BankFriend);
subplot(2,2,1)
histogram(X1.BankFriend)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
loc = mean(X1.BankFriend);
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
subplot(2,2,2)
histogram(X2.BankFriend)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
loc = mean(X2.BankFriend);
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
subplot(2,2,3)
histogram(X3.BankFriend)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
loc = mean(X3.BankFriend);
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
subplot(2,2,4)
histogram(X4.BankFriend)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
loc = mean(X4.BankFriend);
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
sgtitle('BankFriend')

% 7 Investments distribution
figure
subplot(2,2,1)
histogram(X1.Investments)
subplot(2,2,2)
histogram(X2.Investments)
subplot(2,2,3)
histogram(X3.Investments)
subplot(2,2,4)
histogram(X4.Investments)
sgtitle('Investments')

% 8 FamilySize distribution
figure
temp = mean(BankClients.FamilySize);
subplot(2,2,1)
histogram(X1.FamilySize)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
subplot(2,2,2)
histogram(X2.FamilySize)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
subplot(2,2,3)
histogram(X3.FamilySize)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
subplot(2,2,4)
histogram(X4.FamilySize)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
sgtitle('FamilySize')

% 9 Saving distribution
figure
temp = mean(BankClients.Saving);
subplot(2,2,1)
histogram(X1.Saving)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
subplot(2,2,2)
histogram(X2.Saving)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
subplot(2,2,3)
histogram(X3.Saving)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
subplot(2,2,4)
histogram(X4.Saving)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
sgtitle('Saving')

% 10 ESG distribution
figure
temp = mean(BankClients.ESG);
subplot(2,2,1)
histogram(X1.ESG)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
subplot(2,2,2)
histogram(X2.ESG)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
subplot(2,2,3)
histogram(X3.ESG)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
subplot(2,2,4)
histogram(X4.ESG)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
sgtitle('ESG')

% 11 Luxury distribution
figure
temp = mean(BankClients.Luxury);
subplot(2,2,1)
histogram(X1.Luxury)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
loc = mean(X1.Luxury);
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
subplot(2,2,2)
histogram(X2.Luxury)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
loc = mean(X2.Luxury);
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
subplot(2,2,3)
histogram(X3.Luxury)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
loc = mean(X3.Luxury);
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
subplot(2,2,4)
histogram(X4.Luxury)
hold on
plot([temp,temp],[0,300],'r-','Linewidth',1.7)
loc = mean(X4.Luxury);
plot([loc,loc],[0,300],'b-','Linewidth',1.7)
sgtitle('Luxury')

% Gender 
disp('Cluster 1:') 
countcats(X1.Gender)

disp('Cluster 2:') 
countcats(X2.Gender)

disp('Cluster 3:') 
countcats(X3.Gender)

disp('Cluster 4:') 
countcats(X4.Gender)




