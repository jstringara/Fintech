close all
clear
clc

load('C:\Users\andre\Desktop\Magistrale\FINTECH\ZENTI\Progetto 1/BankClients.mat')
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

%% DIMENSONALITY REDUCTION (T-SNE)

rng('default') 
Y = tsne(X,'Algorithm','exact','Distance', @MixDistance,'NumDimensions',3);
figure
scatter3(Y(:,1),Y(:,2),Y(:,3),...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',[0 .75 .75])
title('3-D Embedding')
view(-30,15)


%% CLUSTERING 
% DB Scan Clustering Algorithm 

% --- Setting Epsilon 
minpts = 40;
Distance = MixDistance(X,X);
orderedDistance = sort(Distance, 'ascend');
figure
plot(sort(orderedDistance(minpts,:)));

% --- Clustering
epsilon = 0.6;
[DBSCANidx, corepts] = dbscan(Distance,epsilon,minpts,'Distance','precomputed');
nDBSCANCluster = unique(DBSCANidx);
disp(nDBSCANCluster)

% --- Cluster Visualization
Y = tsne(X,'Algorithm','exact','Distance', @MixDistance,'NumDimensions',3);
figure
for i = 1:size(nDBSCANCluster,1)
    pointer = nDBSCANCluster(i);
    scatter3(Y(DBSCANidx==pointer,1),Y(DBSCANidx==pointer,2),Y(DBSCANidx==pointer,3),...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',[rand() rand() rand()])  % random colors
    hold on
end
hold off
legend


