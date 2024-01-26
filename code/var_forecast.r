# Required libraries
library(fracdiff)
library(forecast)

start_time <- Sys.time()

# Setting the work space directory
setwd("~/self/phd/courses/continuous-time-finance/equitypremium/code")
# Importing estimated daily variance data
daily_variance <- read.table("../data/daily_var.csv", header=FALSE)
# Obtaining daily returns
returns <- read.csv("../data/returns.csv", header=FALSE)
daily_returns <- ts(rowSums(returns))

# To time series
var_ts <- ts(daily_variance)
plot(var_ts)

# Initializing data frame for saving predicted realized variances
# First year of data to start real time estimation
columns <- c('d','monthly','bimonthly','trimonthly','semianually','anually')
n_cols <- length(columns)
n_days <- length(var_ts) - 252
predict_rvw <- data.frame(matrix(nrow = n_days, ncol=n_cols))
predict_rvr <- data.frame(matrix(nrow = n_days, ncol=n_cols))
colnames(predict_rvr) <- columns
colnames(predict_rvw) <- columns

# Estimating the model on increasing and rolling time windows
for (i in 1:n_days){
    
    # Defining the observed windows
    var_window <- ts(var_ts[1:(252+i)])
    var_rolling <- ts(var_ts[i:(252+i)])
    
    # Demeaning the sample
    # var_mean <- mean(var_window)
    # demeaned_window <- var_window - var_mean
    
    # Model estimation and saving the parameters
    frac_modelw <- fracdiff(var_window)
    frac_modelr <- fracdiff(var_rolling)
    predict_rvw$d[i] <- frac_modelw$d
    predict_rvr$d[i] <- frac_modelr$d
    
    # Forecasting up to 360 days ahead # 252
    var_forecastw <- forecast(frac_modelw,h=360)
    var_forecastr <- forecast(frac_modelr,h=360)
    
    # Computing predicted realized variances
    # 21,42,63,126
    predict_rvw$monthly[i] <- sum(var_forecastw$mean[1:30]) 
    predict_rvw$bimonthly[i] <- sum(var_forecastw$mean[1:60])
    predict_rvw$trimonthly[i] <- sum(var_forecastw$mean[1:90])
    predict_rvw$semianually[i] <- sum(var_forecastw$mean[1:180])
    predict_rvw$anually[i] <- sum(var_forecastw$mean)
    
    predict_rvr$monthly[i] <- sum(var_forecastr$mean[1:30]) 
    predict_rvr$bimonthly[i] <- sum(var_forecastr$mean[1:60])
    predict_rvr$trimonthly[i] <- sum(var_forecastr$mean[1:90])
    predict_rvr$semianually[i] <- sum(var_forecastr$mean[1:180])
    predict_rvr$anually[i] <- sum(var_forecastr$mean)
}

end_time <- Sys.time()
end_time - start_time

# Plotting the results
plot(ts(predict_rvw$d))
plot(ts(predict_rvr$d))
plot(ts(predict_rvw$monthly))
plot(ts(predict_rvw$bimonthly))
plot(ts(predict_rvw$trimonthly))
plot(ts(predict_rvw$semianually))
plot(ts(predict_rvw$anually))

# Saving the results as a CSV file
predict_rvr <- predict_rvr[columns]
predict_rvw <- predict_rvw[columns]

write.csv(predict_rvw, "../results/predicted_rv_window.csv", row.names = FALSE)
write.csv(predict_rvr, "../results/predicted_rv_rolling.csv", row.names = FALSE)



