clear 
close all
clc

path = 'C:\Users\andre\Desktop\Magistrale\FINTECH\ZENTI\Progetto 4\Business4\InvestmentReplica.mat';
load(path)

% Synthetic target weights
wHFRXGL = 0.5; 
wMXWO = 0.25;
wLEGATRUU = 0.25;

% Building the target
y = wHFRXGL*price2ret(HFRXGL) + wMXWO*price2ret(MXWO) + wLEGATRUU*price2ret(LEGATRUU);    % "Monster Index" returns
target = (ret2price(y));                                                                  % "Monster Index" levels

% Futures returns
X = [price2ret(CO1) price2ret(DU1) price2ret(ES1) price2ret(GC1)...
           price2ret(LLL1) price2ret(NQ1) price2ret(RX1) price2ret(TP1)...
           price2ret(TU2) price2ret(TY1) price2ret(VG1)];
%        
% figure
% yvalues = {'Target','C01','DU1','ES1','GC1','LLL1','NQ1','RX1','TP1','TU2','TY1','VG1'};
% xvalues = {'Target','C01','DU1','ES1','GC1','LLL1','NQ1','RX1','TP1','TU2','TY1','VG1'};
% h = heatmap(xvalues,yvalues,corr([y X],'type', 'Kendall'));
% h.Title = 'Correlation matrix (Kendall): target vs Futures';


% %% LASSO 
% 
% [bLasso,fitinfo] = lasso(X,y,'CV',10, 'Intercept',false);
% 
% lassoPlot(bLasso,fitinfo,'PlotType','CV');
% legend('show')
% 
% lam = fitinfo.IndexMinMSE;      % Lambda such that MSE is min
% fitinfo.MSE(lam)
% 
% bLasso = bLasso(:,lam);
% 
% GrossExposure = sum(abs(bLasso));
% 
% figure
% bar(bLasso)
% title('Weights (Lasso regression coefficients)')
% ylabel('Weight')
% xlabel('Assets (#)')
% 
% replicaRetLasso = X*bLasso;
% replicaLasso = ret2price(replicaRetLasso);
% 
% figure
% plot(Date,ret2price(y),'DisplayName','Target');
% hold on
% plot(Date,replicaLasso,'DisplayName','LASSO replica');
% legend
% xlabel('Timeline')
% ylabel('Value')
% hold off;
% 
% %% RIDGE 
% 
% [bRidge] = ridge(y,X,0.1);
% 
% GrossExposure = sum(abs(bRidge));
% 
% figure
% bar(bRidge)
% title('Weights (Ridge regression coefficients)')
% ylabel('Weight')
% xlabel('Assets (#)')
% 
% replicaRetRidge= X*bRidge;
% replicaRidge= ret2price(replicaRetRidge);
% 
% figure
% plot(Date,ret2price(y),'DisplayName','Target');
% hold on
% plot(Date,replicaRidge,'DisplayName','RIDGE replica');
% legend
% xlabel('Timeline')
% ylabel('Value')
% hold off;
% 
% 
% %% RIDGE CV 
% 
% lambda = 10.^(-20:10);
% errs = [];
% 
% for i = 1:numel(lambda)
%     [bRidge] = ridge(y,X,lambda(i));
%     replicaRetRidge = X*bRidge;
%     replicaRidge = ret2price(replicaRetRidge);
%     err = sqrt(sum((ret2price(y)-replicaRidge).^2));
%     errs = [errs err];
% %     figure
% %     plot(Date,ret2price(y),'DisplayName','Target');
% %     hold on
% %     plot(Date,replicaRidge,'DisplayName','RIDGE replica');
% %     legend
% %     xlabel('Timeline')
% %     ylabel('Value')
% %     hold off;
% end
% 
% index = find(errs==min(errs));
% lambda_opt = lambda(index);
% 
% %% AURO REGRESSIVE MODEL
% 
% rollingWindow = 26;        % in weeks (52 = 1Y, 104 = 2Y...)
% i = rollingWindow;
% b = zeros(size(X,2));
% bENet2 = [];
% rENet2 = [];
% GrossExposure = [];
% endSample = 0;
% warning('off','all'); % avoid annoying warnings during the loop
% 
% while endSample <= (length(X) - rollingWindow -2)
%     startSample = i;
%     endSample = i+rollingWindow-1;
%     [b,fitinfo] = lasso(X(startSample:endSample,:),y(startSample:endSample),'Alpha',0.85,'CV',5, 'Intercept',false);
% %   lam = fitinfo.IndexMinMSE; % lambda corresponding to MinMSE (better fit)
% %   lam = fitinfo.Index1SE; % lambda 1SE away from MinMSE (more robust)
%     lam = round((fitinfo.Index1SE + fitinfo.IndexMinMSE)/2); % lambda half-way between MinMSE and 1SE away from MinMSE
%     b = b(:,lam);
%     GrossExposure = [GrossExposure; sum(abs(b))];
%     for j = 1:26  
%         bENet2 = [bENet2; b'];
%         r = X(startSample + j,:)*b;
%         rENet2 = [rENet2; r];
%     end
%     i = i+rollingWindow;
% end
% 
% warning('on','all'); % warnings on again
% 
% figure
% plot(Date(rollingWindow+1:end),ret2price(y(rollingWindow + 1: end)),'DisplayName','Target');
% hold on;
% plot(Date(rollingWindow+3:end),ret2price(rENet2),'DisplayName','Replica');
% legend
% title('Replica (ML-based sparse clone) vs target')
% hold off;

% figure
% plot(Date(rollingWindow+2:end),GrossExposure+1);   % add 1 for your collateral + margins
% title('Leverage = Total gross exposure')
% xlabel('Timeline')
% ylabel('Gross exposure')
% hold off;


% %% AURO REGRESSIVE MODEL
% 
% rollingWindow = 156;        % in weeks (52 = 1Y, 104 = 2Y...)
% i = 1;
% telescope = 1;
% res = mod(length(X)-rollingWindow,telescope);
% if res~=0
%     for q = 1:res
%         y = [y(1); y];
%         X = [X(1,:); X];
%     end
% end
% 
% GrossExposure = [];
% r = [];
% 
% for i=rollingWindow:telescope:(length(X)-telescope)
%     if i == rollingWindow
%         startSample = 1;
%         endSample = i;
%     else
%         startSample = startSample + telescope;
%         endSample = startSample+rollingWindow-1;
%     end
%     lm = fitlm(X(startSample:endSample,:),y(startSample:endSample),'Intercept',false);
%     b = lm.Coefficients.Estimate;
%     GrossExposure = [GrossExposure; sum(abs(b))];
%     r = [r; X(endSample+1:endSample+telescope,:)*b];
%     disp([startSample, endSample,size(r)])
% end
% % 
% % disp(numel(Date(rollingWindow+2:end)))
% % disp(numel(ret2price(y(rollingWindow + 1: end))))
% % disp(numel(ret2price(y)))
% 
% figure
% plot(Date(rollingWindow+1:end),ret2price(y(rollingWindow+1:end,:)),'DisplayName','Target');
% hold on;
% plot(Date(rollingWindow+1:end),ret2price(r),'DisplayName','Replica');
% legend
% title('Replica (ML-based sparse clone) vs target')
% hold off;    

%% Lasso

rollingWindow = 104;        % in weeks (52 = 1Y, 104 = 2Y...)
i = 1;
telescope = 4;
res = mod(length(X)-rollingWindow,telescope);
if res~=0
    for q = 1:res
        y = [y(1); y];
        X = [X(1,:); X];
    end
end

GrossExposure = [];
r = [];

for i=rollingWindow:telescope:(length(X)-telescope)
    if i == rollingWindow
        startSample = 1;
        endSample = i;
    else
        startSample = startSample + telescope;
        endSample = startSample+rollingWindow-1;
    end
    [b,fitinfo] = lasso(X(startSample:endSample,:),y(startSample:endSample),'Alpha',1,'CV',5, 'Intercept',false);
    lam = fitinfo.IndexMinMSE; % lambda corresponding to MinMSE (better fit)
    lam = fitinfo.Index1SE; % lambda 1SE away from MinMSE (more robust)
    lam = round((fitinfo.Index1SE + fitinfo.IndexMinMSE)/2); % lambda half-way between MinMSE and 1SE away from MinMSE
    b = b(:,lam);
    GrossExposure = [GrossExposure; sum(abs(b))];
    r = [r; X(endSample+1:endSample+telescope,:)*b];
    disp([startSample, endSample,size(r)])
end
% 
% disp(numel(Date(rollingWindow+2:end)))
% disp(numel(ret2price(y(rollingWindow + 1: end))))
% disp(numel(ret2price(y)))

%% Indici
rENet2 = r;
figure
plot(Date(rollingWindow+1:end),ret2price(y(rollingWindow+1:end,:)),'DisplayName','Target');
hold on;
plot(Date(rollingWindow+1:end),ret2price(r),'DisplayName','Replica');
legend
title('Replica (ML-based sparse clone) vs target')
hold off;    

TE = rENet2 - y(rollingWindow + 1: end); % tracking error
TEV = std(TE)*sqrt(52)

logRClone = diff(log(ret2price(rENet2))); % ...much easier to compute annualized metrics from log-returns
logRTarget = diff(log(ret2price(y(rollingWindow + 1: end))));
logTE = logRClone - logRTarget;
meanTRTarget = exp(mean(logRTarget)*52) - 1
meanTRClone = exp(mean(logRClone)*52) - 1
meanER = exp(mean(logTE)*52) - 1

IR = meanER/TEV

% Turnover = calcTurnover(bENet2); % weekly turnover
% meanTurnover = mean(Turnover)*52 % average annual turnover
% tradingCosts = 0.0004; % transaction costs (hp: buyCosts=sellCost)
% meanTradingCosts = meanTurnover*tradingCosts
% 
% 
% NetTR = meanTRClone - meanTradingCosts % transaction costs (hp: buyCosts=sellCost)
% NetER = meanER - meanTradingCosts
% NetIR = NetER/TEV
