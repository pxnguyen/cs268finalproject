function regression_test
fid = fopen('data.fanduel.formatted.scsv');
fmt = repmat('%s', [1, 105]);
output = textscan(fid, fmt, 'delimiter', ';');
info = {};
info.names = output{1};
info.teams = output{2};
info.positions = output{3};
fp = cat(2, output{5:3:end});
minutes = cat(2, output{6:3:end});
fantasypoint = cell2mat(cellfun(@(x) str2double(x), fp, 'UniformOutput', false));
minutes = cell2mat(cellfun(@(x) str2double(x), minutes, 'UniformOutput', false));

windowSize = 1:5;
errorsTop50 = zeros(length(windowSize), 1);
errorsAll = zeros(length(windowSize), 1);

maxDay = size(fantasypoint, 2);
daysToTest = 20:maxDay;
gt = fantasypoint(:,daysToTest);

% sweep for regression parameter
for windowSize = 1:10;
  predicted = zeros(size(gt));
  daysToPredict = daysToTest;
  for iDay=1:length(daysToPredict)
    history = fantasypoint(:, 1:daysToPredict(iDay)-1);
    minHist = minutes(:, 1:daysToPredict(iDay)-1);
    opts = struct;
    opts.method = 'regression';
    opts.windowSize = windowSize;
    predicted(:,iDay) = project(history, minHist, opts);
  end
  
  % top 100
  errorDay = zeros(length(daysToPredict), 1);
  for iDay=1:length(daysToPredict)
    gtDay = gt(:,iDay);
    avail = ~isnan(gtDay);
    predDay = predicted(:,iDay);
    gtDay = gtDay(avail);
    predDay = predDay(avail);
    [~,sortedindeces] = sort(gtDay, 'descend');
    top50 = sortedindeces(1:50);
    d = sum(abs(gtDay(top50) - predDay(top50)))/50;
    errorDay(iDay) = d;
  end
  errorsTop50(windowSize) = mean(errorDay);
  
  diff = gt - predicted;
  unavail = isnan(gt);
  diff(unavail) = 0;
  errors = sum(abs(diff));
  playerCount = sum(~unavail);
  avgErrorPerDay = errors./playerCount;
  errorsAll(windowSize) = mean(avgErrorPerDay);
end

plot(1:6, errorsTop50(1:6), '-o', 'LineWidth', 2); hold on;
plot(1:6, errorsAll(1:6), '-x', 'LineWidth', 2);
xlabel('WindowSize');
ylabel('Average Error');
legend({'top50error', 'allerror'});
grid on
export_fig('regression_error', '-png', '-m2', '-painters', '-transparent');