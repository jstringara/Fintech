% Synthetic target weights
wHFRXGL = 0.5; 
wMXWO = 0.25;
wLEGATRUU = 0.25;

% Define the state variables
x = [wHFRXGL wMXWO wLEGATRUU];

% Building the target, observation variables 
y = wHFRXGL*price2ret(HFRXGL) + wMXWO*price2ret(MXWO) + wLEGATRUU*price2ret(LEGATRUU); % "Monster Index" returns
% target = (ret2price(y)); % "Monster Index" levels

% Futures returns
X = [price2ret(CO1) price2ret(DU1) price2ret(ES1) price2ret(GC1)...
           price2ret(LLL1) price2ret(NQ1) price2ret(RX1) price2ret(TP1)...
           price2ret(TU2) price2ret(TY1) price2ret(VG1)];

% Set up the state-space model 
m = 11;
F = eye(m);
H = X; %dipende dal tempo
V2 = std(y);
V1 = eye(m).*var(X);


%Initialization 
x_0 = zeros(1,m);
P = ones(m,m);

y_meas = y; %dipende dal tempo
x_corr = zeros(length(y_meas), m);
x_pred = zeros(length(y_meas)+1, m);
x_pred(1,:) = x_0;
K = zeros(length(y_meas), m);

for t = 1:length(y_meas)
   % Correction step
    n = length(x_pred); % Obtain the dimension of the state
    K = (P*H(t,:)')/(H(t,:)*P*H(t,:)' + V2); % Update the Kalman filter gain
    P = (eye(m) - K*H(t,:))*P; % Correct the state variance based on the new Kalman gain.
    x_corr = x_pred + (y_meas(t) - H(t,:)*x_pred')'*K'; % Correct the state estimate based on the current measurement
   % Prediction step
    x_pred = x_corr*F;
    P_pred = F*P*F' + V1;
end

replRetOLS = X*x_pred(1,:)'; % compute portfolio returns using regression coefficients as weights
repOLS = ret2price(replRetOLS); % from returns to levels

figure
plot(XTab.Date,ret2price(y),'DisplayName','Target');
hold on;
plot(XTab.Date,repOLS,'DisplayName','KF replica');
xlabel('Timeline')
ylabel('Value')
legend
hold off;