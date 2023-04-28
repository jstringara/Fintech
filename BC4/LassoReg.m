function RegressCoeff = LassoReg(X,y)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[b,fitinfo] = lasso(X,y,'CV',5, 'Intercept',false);
lam = fitinfo.IndexMinMSE;
fitinfo.MSE(lam);
RegressCoeff = b(:,lam);
end

