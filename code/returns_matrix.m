clear
clc

tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data treatment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Importing SPX minute data
SPX1mSample = readtable("../data/SPX1mSample.csv");

% No missing data
min_count = groupcounts(SPX1mSample, "ts");
groupcounts(min_count.GroupCount)

day_count = groupcounts(SPX1mSample, "t");
groupcounts(day_count.GroupCount)

% Creating returns table
SPX1mRet = SPX1mSample(2:end,:);
SPX1mRet = renamevars(SPX1mRet, "Price", "Return");
SPX1mRet.Return = log(SPX1mRet.Return./SPX1mSample.Price(1:end-1));

% Drop the first day since it has 1 less observation
SPX1mRet = SPX1mRet(SPX1mRet.t ~= SPX1mRet.t(1),:);

% From table to array
n_days = height(day_count) - 1;
data = zeros(n_days, 390);

for i = 1:n_days
    day = day_count.t(i+1);

    for j = 1:390
        minute = min_count.ts(j);
        loc = (SPX1mRet.t == day & SPX1mRet.ts == minute);
        data(i,j) = SPX1mRet(loc,:).Return;
    end

end

% Save matrix as CSV file
writematrix(data,"../data/returns.csv")

toc

