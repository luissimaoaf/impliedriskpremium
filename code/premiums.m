clear
clc

tic

% Importing the data
% Expanding window realized variance forecasts
pred_rvw = readtable("../results/predicted_rv_window.csv");
pred_rvw = pred_rvw{:,:};
% Rolling window realized variance forecasts
pred_rvr = readtable("../results/predicted_rv_rolling.csv");
pred_rvr = pred_rvr{:,:};
% Risk neutral moments
rn_moments30 = readmatrix("../results/rn_moments30.csv");
rn_moments60 = readmatrix("../results/rn_moments60.csv");
rn_moments90 = readmatrix("../results/rn_moments90.csv");
rn_moments180 = readmatrix("../results/rn_moments180.csv");
rn_moments360 = readmatrix("../results/rn_moments360.csv");
% Risk free rate and discount factors
rfrate = readmatrix("../data/riskfreerate.csv");
discount = readmatrix("../data/discount.csv");
% Dates
dates = readtable('../data/dates.csv');
dates = dates.t;
n_days = length(dates);

% Variance premium
rn_variance = zeros(height(rn_moments30),5);
rn_variance(:,1) = rn_moments30(:,1);
rn_variance(:,2) = rn_moments60(:,1);
rn_variance(:,3) = rn_moments90(:,1);
rn_variance(:,4) = rn_moments180(:,1);
rn_variance(:,5) = rn_moments360(:,1);

variance_premiumw = rn_variance(254:end,:) - pred_rvw(:,2:end);
variance_premiumr = rn_variance(254:end,:) - pred_rvr(:,2:end);

% Equity premium and GO portfolio weigths

% Setting up the regressors
regressor1 = zeros(n_days,5);
regressor1(:,1) = rn_moments30(:,2);
regressor1(:,2) = rn_moments60(:,2);
regressor1(:,3) = rn_moments90(:,2);
regressor1(:,4) = rn_moments180(:,2);
regressor1(:,5) = rn_moments360(:,2);
regressor1 = -regressor1.*discount;

regressor2 = zeros(n_days,5);
regressor2(:,1) = rn_moments30(:,3) - rn_moments30(:,1).^2;
regressor2(:,2) = rn_moments60(:,3) - rn_moments60(:,1).^2;
regressor2(:,3) = rn_moments90(:,3) - rn_moments90(:,1).^2;
regressor2(:,4) = rn_moments180(:,3) - rn_moments180(:,1).^2;
regressor2(:,5) = rn_moments360(:,3) - rn_moments360(:,1).^2;
regressor2 = -regressor2.*discount;

regressor3 = zeros(n_days,5);
regressor3(:,1) = rn_moments30(:,4) - rn_moments30(:,1).*rn_moments30(:,2);
regressor3(:,2) = rn_moments60(:,4) - rn_moments60(:,1).*rn_moments60(:,2);
regressor3(:,3) = rn_moments90(:,4) - rn_moments90(:,1).*rn_moments90(:,2);
regressor3(:,4) = rn_moments180(:,4) - rn_moments180(:,1).*rn_moments180(:,2);
regressor3(:,5) = rn_moments360(:,4) - rn_moments360(:,1).*rn_moments360(:,2);
regressor3 = -regressor3.*discount;

regressor4 = zeros(n_days,5);
regressor4(:,1) = rn_moments30(:,5) - rn_moments30(:,1).*rn_moments30(:,3);
regressor4(:,2) = rn_moments60(:,5) - rn_moments60(:,1).*rn_moments60(:,3);
regressor4(:,3) = rn_moments90(:,5) - rn_moments90(:,1).*rn_moments90(:,3);
regressor4(:,4) = rn_moments180(:,5) - rn_moments180(:,1).*rn_moments180(:,3);
regressor4(:,5) = rn_moments360(:,5) - rn_moments360(:,1).*rn_moments360(:,3);
regressor4 = -regressor4.*discount;

% Dropping the first 253 observations to match the variance premium
regressor1 = regressor1(254:end,:);
regressor2 = regressor2(254:end,:);
regressor3 = regressor3(254:end,:);
regressor4 = regressor4(254:end,:);

% Increasing window cross-sectional regression
n_weights = size(regressor1,1) - 252;
go_weights1 = zeros(n_weights,1);
go_weights2 = zeros(n_weights,2);
go_weights3 = zeros(n_weights,3);
go_weights4 = zeros(n_weights,4);

for i=1:n_weights
    idx = 252 + i;
    n_rows = 5*idx;

    % Merging observations across maturities for regressing
    X = zeros(n_rows,4);
    X(:,1) = reshape(regressor1(1:idx,:),1,[])';
    X(:,2) = reshape(regressor2(1:idx,:),1,[])';
    X(:,3) = reshape(regressor3(1:idx,:),1,[])';
    X(:,4) = reshape(regressor4(1:idx,:),1,[])';

    Y = reshape(variance_premiumw(1:idx,:),1,[])';
    
    % K = 1
    model = fitlm(X(:,1),Y,Intercept=true);
    go_weights1(i,:) = model.Coefficients.Estimate(2:end);

    % K = 2
    model = fitlm(X(:,1:2),Y,Intercept=true);
    go_weights2(i,:) = model.Coefficients.Estimate(2:end);

    % K = 3
    model = fitlm(X(:,1:3),Y,Intercept=true);
    go_weights3(i,:) = model.Coefficients.Estimate(2:end);

    % K = 4
    model = fitlm(X,Y,Intercept=true);
    go_weights4(i,:) = model.Coefficients.Estimate(2:end);
end

% Implied Equity Premiums
% K = 1
iep1 = zeros(n_weights,5);
iep1(:,1) = sum(go_weights1.*rn_moments30(end-n_weights+1:end,1),2);
iep1(:,2) = sum(go_weights1.*rn_moments60(end-n_weights+1:end,1),2);
iep1(:,3) = sum(go_weights1.*rn_moments90(end-n_weights+1:end,1),2);
iep1(:,4) = sum(go_weights1.*rn_moments180(end-n_weights+1:end,1),2);
iep1(:,5) = sum(go_weights1.*rn_moments360(end-n_weights+1:end,1),2);
iep1 = iep1.*discount(end-n_weights+1:end,:);

% K = 2
iep2 = zeros(n_weights,5);
iep2(:,1) = sum(go_weights2.*rn_moments30(end-n_weights+1:end,1:2),2);
iep2(:,2) = sum(go_weights2.*rn_moments60(end-n_weights+1:end,1:2),2);
iep2(:,3) = sum(go_weights2.*rn_moments90(end-n_weights+1:end,1:2),2);
iep2(:,4) = sum(go_weights2.*rn_moments180(end-n_weights+1:end,1:2),2);
iep2(:,5) = sum(go_weights2.*rn_moments360(end-n_weights+1:end,1:2),2);
iep2 = iep2.*discount(end-n_weights+1:end,:);

% K = 3
iep3 = zeros(n_weights,5);
iep3(:,1) = sum(go_weights3.*rn_moments30(end-n_weights+1:end,1:3),2);
iep3(:,2) = sum(go_weights3.*rn_moments60(end-n_weights+1:end,1:3),2);
iep3(:,3) = sum(go_weights3.*rn_moments90(end-n_weights+1:end,1:3),2);
iep3(:,4) = sum(go_weights3.*rn_moments180(end-n_weights+1:end,1:3),2);
iep3(:,5) = sum(go_weights3.*rn_moments360(end-n_weights+1:end,1:3),2);
iep3 = iep3.*discount(end-n_weights+1:end,:);

% K = 4
iep4 = zeros(n_weights,5);
iep4(:,1) = sum(go_weights4.*rn_moments30(end-n_weights+1:end,1:4),2);
iep4(:,2) = sum(go_weights4.*rn_moments60(end-n_weights+1:end,1:4),2);
iep4(:,3) = sum(go_weights4.*rn_moments90(end-n_weights+1:end,1:4),2);
iep4(:,4) = sum(go_weights4.*rn_moments180(end-n_weights+1:end,1:4),2);
iep4(:,5) = sum(go_weights4.*rn_moments360(end-n_weights+1:end,1:4),2);
iep4 = iep4.*discount(end-n_weights+1:end,:);

% Martin's lower bound
iepmartin = rn_variance.*discount;

% Saving the results
writematrix(variance_premiumr,"../results/variance_premiumr.csv")
writematrix(variance_premiumw,"../results/variance_premiumw.csv")

writematrix(go_weights1,"../results/go_portfolio_weights1.csv")
writematrix(go_weights2,"../results/go_portfolio_weights2.csv")
writematrix(go_weights3,"../results/go_portfolio_weights3.csv")
writematrix(go_weights4,"../results/go_portfolio_weights4.csv")

writematrix(iepmartin,"../results/martin_lower_bound.csv")
writematrix(iep1,"../results/implied_equity_premium1.csv")
writematrix(iep2,"../results/implied_equity_premium2.csv")
writematrix(iep3,"../results/implied_equity_premium3.csv")
writematrix(iep4,"../results/implied_equity_premium4.csv")

toc