clc
clear 
close all

% Load data 
load('C:\Users\andre\Desktop\Magistrale\FINTECH\ZENTI\Progetto 3\EWS.mat')

%% DATA EXPLORATION 

Time = Data;

% Plot USA stock market against response 
figure()
yyaxis left
b = bar(Time,Y);
ylabel('Y (risk-on/risk-off)')
yyaxis right
p= plot(Time,MXUS);
ylabel('MSCI USA')
p.LineWidth = 3;
title('US Equities and risk-on/risk-off periods')
xlabel('Timeline')

% Plot VIX against response 
figure()
yyaxis left
b = bar(Time,Y);
ylabel('Y (risk-on/risk-off)')
yyaxis right
p= plot(Time,VIX);
ylabel('VIX')
p.LineWidth = 3;
title('US Equities and risk-on/risk-off periods')
xlabel('Timeline')

% Plot 2Y-10Y US Treasury Bond spread against response 
spread2Y10Y = GT10-USGG2YR;
figure()
yyaxis left
b = bar(Time,Y);
ylabel('Y (risk-on/risk-off)')
yyaxis right
p = plot(Time,spread2Y10Y);
ylabel('spread2Y10Y')
p.LineWidth = 3;
title('US Equities and risk-on/risk-off periods')
xlabel('Timeline')


% Always positive variables   => log-differences (log-returns)
Indices_Currencies = [XAUBGNL BDIY CRY Cl1 DXY EMUSTRUU GBP JPY LF94TRUU...
       LF98TRUU LG30TRUU LMBITR LP01TREU...
       LUACTRUU LUMSTRUU MXBR MXCN MXEU MXIN MXJP MXRU MXUS VIX];

% Possibly negative variables => first differences
InterestRates = [EONIA GTDEM10Y GTDEM2Y GTDEM30Y GTGBP20Y GTGBP2Y GTGBP30Y...
    GTITL10YR GTITL2YR GTITL30YR GTJPY10YR GTJPY2YR GTJPY30YR US0001M USGG3M USGG2YR GT10 USGG30YR];

Data = [diff(log(Indices_Currencies)) ECSURPUS(2:end) diff(InterestRates)];  % make stationary
Response = Y(2:end);                                                         % we lose one observation
Time = Time(2:end);                                                          % at the first day 


%% 

abn_mean = mean(Data(Response == 1,:));
norm_mean = mean(Data(Response == 0,:));
diff_mean = rescale(abs(abn_mean - norm_mean))';
index = find(diff_mean>0.5);

X = [Data(:,index) GT10(2:end)-USGG2YR(2:end)];



