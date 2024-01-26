clear
clc
tic

% Importing the results for plotting
% Dates
dates = readtable('../data/dates.csv');
dates = dates.t;
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
% Variance Premium
variance_premiumr = readmatrix("../results/variance_premiumr.csv");
variance_premiumw = readmatrix("../results/variance_premiumw.csv");
% GO Portfolio Weights
go_weights1 = readmatrix("../results/go_portfolio_weights1.csv");
go_weights2 = readmatrix("../results/go_portfolio_weights2.csv");
go_weights3 = readmatrix("../results/go_portfolio_weights3.csv");
go_weights4 = readmatrix("../results/go_portfolio_weights4.csv");
% Implied Equity Premium
iep1 = readmatrix("../results/implied_equity_premium1.csv");
iep2 = readmatrix("../results/implied_equity_premium2.csv");
iep3 = readmatrix("../results/implied_equity_premium3.csv");
iep4 = readmatrix("../results/implied_equity_premium4.csv");
iepmartin = readmatrix("../results/martin_lower_bound.csv");


% Forecasted Variance
figure
time = dates(end-848:end,:);
plot(time,pred_rvr(:,1))
title('d_t on a rolling regression window')
ylabel('d_t')

figure
plot(time,pred_rvw(:,1))
title('d_t on an expanding regression window')
ylabel('d_t')

figure
plot(time,pred_rvw(:,2)*12,time,pred_rvr(:,2)*12,'--')
legend('Expanding window','Rolling window')
title('Forecasted annualized monthly variances')

figure
plot(time,pred_rvw(:,6),time,pred_rvr(:,6),'--')
legend('Expanding window','Rolling window')
title('Forecasted annual variances')

% Risk Neutral Moments
time = dates;
figure
plot(time,rn_moments30(:,1)*12,time,rn_moments60(:,1)*6,time,rn_moments90(:,1)*4, ...
    time,rn_moments180(:,1)*2,time,rn_moments360(:,1))
legend('30-day','60-day','90-day','180-day','360-day')
title('Estimated risk-neutral market variance')

figure
plot(time,rn_moments30(:,2)*12,time,rn_moments60(:,2)*6,time,rn_moments90(:,2)*4, ...
    time,rn_moments180(:,2)*2,time,rn_moments360(:,2))
legend('30-day','60-day','90-day','180-day','360-day')
title('Estimated risk-neutral market skewness')

figure
plot(time,rn_moments30(:,3)*12,time,rn_moments60(:,3)*6,time,rn_moments90(:,3)*4, ...
    time,rn_moments180(:,3)*2,time,rn_moments360(:,3))
legend('30-day','60-day','90-day','180-day','360-day')
title('Estimated risk-neutral market kurtosis')

figure
plot(time,rn_moments30(:,4)*12,time,rn_moments60(:,4)*6,time,rn_moments90(:,4)*4, ...
    time,rn_moments180(:,4)*2,time,rn_moments360(:,4))
legend('30-day','60-day','90-day','180-day','360-day')
title('Estimated risk-neutral market moment (k=5)')

figure
plot(time,rn_moments30(:,5)*12,time,rn_moments60(:,5)*6,time,rn_moments90(:,5)*4, ...
    time,rn_moments180(:,5)*2,time,rn_moments360(:,5))
legend('30-day','60-day','90-day','180-day','360-day')
title('Estimated risk-neutral market moment (k=6)')

% Variance Premium
figure
time = dates(end-848:end,:);
plot(time,variance_premiumw.*[12,6,4,2,1])
title('Annualized Variance Premium')
legend('30-day','60-day','90-day','180-day','360-day')

figure
plot(time,pred_rvw(:,2)*12,time,rn_moments30(end-848:end,1)*12)
title('Annualized Variance Premium')
legend('Expected 30-day variance','Risk-neutral 30-day variance')

figure
plot(time,pred_rvw(:,end)*12,time,rn_moments360(end-848:end,1)*12)
title('Annual Variance Premium')
legend('Expected 360-day variance','Risk-neutral 360-day variance')


% GO Portfolio Weights
figure
time = dates(end-596:end,:);
plot(time,go_weights1,time,go_weights2(:,1),time,go_weights3(:,1), ...
    time,go_weights4(:,1))
title('Market weight in GO portfolio')
legend('K = 1','K = 2','K = 3','K = 4')

figure
plot(time,go_weights4)
title('GO portfolio weights (K = 4)')
legend('k = 1','k = 2','k = 3','k = 4')

% Implied Equity Premium
figure
plot(time,iep1(:,5),time,iep2(:,5),time,iep3(:,5),time,iep4(:,5));
title('Implied Equity Premiums (360-day)')
legend('K = 1','K = 2','K = 3','K = 4')

figure
plot(time,iep4.*[12,6,4,2,1])
title('Annualized Implied Equity Premiums (K = 4)')
legend('30-day','60-day','90-day','180-day','360-day')

% Martin's Lower Bound
figure
plot(time,iep4(:,5),time,iepmartin(end-596:end,5))
title("Martin's Lower Bound (Annual)")
legend('Implied Equity Premium (K=4)', "Martin's Lower Bound")

toc