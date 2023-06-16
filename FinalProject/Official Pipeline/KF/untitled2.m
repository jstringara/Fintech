Returns = replRetKF;
DateReturns = Date(rollingWindow+1:end);
SampleSize = length(Returns);

TestWindowStart      = rollingWindow+1;
TestWindow           = TestWindowStart : SampleSize;
EstimationWindowSize = rollingWindow/2; 

pVaR = [0.05 0.01];

Historical95_kf = zeros(length(TestWindow),1);
Historical99_kf = zeros(length(TestWindow),1);

for t = TestWindow
    i = t - TestWindowStart + 1;
    EstimationWindow = t-EstimationWindowSize:t-1;
    X = Returns(EstimationWindow);
    Historical95_kf(i) = -quantile(X,pVaR(1)); 
    Historical99_kf(i) = -quantile(X,pVaR(2)); 
end

figure;
plot(DateReturns(TestWindow-1),[Historical95_kf Historical99_kf])
ylabel('VaR')
xlabel('Date')
legend({'95% Confidence Level','99% Confidence Level'},'Location','Best')
title('VaR Estimation of KF Using the Historical Simulation Method')