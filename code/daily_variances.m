clear
clc

% Importing data
SPX1mSample = readtable("../data/SPX1mSample.csv");
returns = readmatrix("../data/returns.csv");

tic

% Daily variance
n_days = height(returns);
n_obs = width(returns);
n_subsamples = n_obs/78;

% Temporary matrix for 5 min returns
subreturns = zeros(n_subsamples, 77);
% Temporary matrix for 5 min return subsample variance
var_samples = zeros(n_days,n_subsamples);

for i = 1:n_days
    for j = 1:n_subsamples
        for k = 1:77
            idx1 = j + n_subsamples*(k-1);
            idx2 = j + n_subsamples*k;
            if j==1 && k==1
                % ignore the overnight return period
                idx1 = idx1 + 1;
            end
            subreturns(j,k) = sum(returns(i,idx1:idx2));
        end
        var_samples(i,j) = sum(subreturns(j,:).^2);
    end
end

% Daily variances
daily_var = mean(var_samples,2);

plot(daily_var)

% Save matrix as CSV file
writematrix(daily_var,"../data/daily_var.csv")

toc