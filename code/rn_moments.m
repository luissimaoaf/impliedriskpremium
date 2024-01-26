clear
clc
tic

% Location of the daily SPX options data
opt_dir = "../data/SPX_Opt/";
opt_files = dir(fullfile(opt_dir, "*.csv"));
n_files = length(opt_files);

% Initialize Risk Neutral Moments matrix
% We are computing the j-th moment for j=2,3,4,5,6
% and for horizons T=30,60,90,180,360 days

moments = [2,3,4,5,6];
standard_maturities = [30,60,90,180,360];
n_moments = length(moments);

rn_moments30 = zeros(n_files, n_moments);
rn_moments60 = zeros(n_files, n_moments);
rn_moments90 = zeros(n_files, n_moments);
rn_moments180 = zeros(n_files, n_moments);
rn_moments360 = zeros(n_files, n_moments);

% To store the interpolated risk-free rates and discount factors
riskfreerate = zeros(n_files, length(standard_maturities));
discount = zeros(n_files, length(standard_maturities));

% Main loop, iterated over each daily file to save memory
for i = 1:n_files
    opt_file = strcat(opt_dir,opt_files(i).name);
    daily_data = readtable(opt_file);
    
    % Dropping options without bid or missing values
    loc = (daily_data.bid ~= 0 & isnan(daily_data.mid)==false);
    daily_data = daily_data(loc,:);
    
    % Estimating moments for available maturities
    maturities = groupcounts(daily_data,"tau_d").tau_d;
    n_maturities = length(maturities);
    
    rnmoments = zeros(n_maturities,n_moments);
    rfrates = zeros(n_maturities,1);

    for t = 1:n_maturities
        T = maturities(t);

        % Subsetting the data
        sub_data = daily_data(daily_data.tau_d == T,:);
        
        % Getting spot, forward and risk-free interest rate
        S = sub_data.under_mid(1);
        F = sub_data.F(1);
        rf = sub_data.r(1);
        rfrates(t) = rf;

        % Separating call and put data
        cloc = (char(sub_data.opt_type) == 'c');
        ploc = (char(sub_data.opt_type) == 'p');
        call_data = sub_data(cloc,:);
        put_data = sub_data(ploc,:);

        % Integration limits
        cloc = (call_data.K > F);
        ploc = (put_data.K < F);
        call_data = call_data(cloc,:);
        put_data = put_data(ploc,:);

        n_calls = height(call_data);
        n_puts = height(put_data);

        % Call integral computations (trapezoid method)
        prices = call_data.mid;
        strikes = call_data.K;

        vals = ((strikes-F).^(moments-2)).*prices;
        increments = (vals(1:end-1,:)+vals(2:end,:))/2;
        dt = strikes(2:end) - strikes(1:end-1);
        for j = 1:n_moments
            integral = dot(dt,increments(:,j));
            rnmoments(t,j) = integral;
        end

        % Put integral computations
        prices = put_data.mid;
        strikes = put_data.K;

        vals = ((strikes - F).^(moments-2)).*prices;
        increments = (vals(1:end-1,:)+vals(2:end,:))/2;
        dt = strikes(2:end) - strikes(1:end-1);
        for j = 1:n_moments
            integral = dot(dt,increments(:,j));
            rnmoments(t,j) = rnmoments(t,j) + integral;

            % Multiplying by the remaining factors
            rnmoments(t,j) = rnmoments(t,j)*factorial(j+1)*exp(rf*T/360)/(S^(j+1));
        end
    end

    % Linear interpolation/extrapolation for standardized maturities
    interp_moments = interp1(maturities,rnmoments,standard_maturities,"linear","extrap");
    interp_rates = interp1(maturities,rfrates,standard_maturities,"linear","extrap");

    % Saving to the results matrix
    rn_moments30(i,:) = interp_moments(1,:);
    rn_moments60(i,:) = interp_moments(2,:);
    rn_moments90(i,:) = interp_moments(3,:);
    rn_moments180(i,:) = interp_moments(4,:);
    rn_moments360(i,:) = interp_moments(5,:);
    riskfreerate(i,:) = interp_rates;
    discount(i,:) = exp(-interp_rates.*standard_maturities/360);
end


% Save results as CSV files
writematrix(rn_moments30,"../results/rn_moments30.csv")
writematrix(rn_moments60,"../results/rn_moments60.csv")
writematrix(rn_moments90,"../results/rn_moments90.csv")
writematrix(rn_moments180,"../results/rn_moments180.csv")
writematrix(rn_moments360,"../results/rn_moments360.csv")
writematrix(riskfreerate,"../results/riskfreerate.csv")
writematrix(discount,"../data/discount.csv")

toc