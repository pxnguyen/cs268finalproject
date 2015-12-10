function compare_projection
fid = fopen('data.fanduel.formatted.scsv');
fmt = repmat('%s', [1, 117]);
output = textscan(fid, fmt, 'delimiter', ';');
info = {};
info.names = output{1};
info.teams = output{2};
info.positions = output{3};
fp = cat(2, output{5:3:end});
minutes = cat(2, output{6:3:end});
fantasypoint = cell2mat(cellfun(@(x) str2double(x), fp, 'UniformOutput', false));
minutes = cell2mat(cellfun(@(x) str2double(x), minutes, 'UniformOutput', false));

methods = {'average', 'last', 'regression'};
errorsTop50 = zeros(length(methods), 1);
errorsAll = zeros(length(methods), 1);
methodPrediction = cell(length(methods), 1);

maxDay = size(fantasypoint, 2);
daysToTest = 20:maxDay;
gt = fantasypoint(:,daysToTest);

for iMethod = 1:length(methods)
  methodName = methods{iMethod};
  opts.method = methodName;
  predicted = zeros(size(gt));
  daysToPredict = daysToTest;
  for iDay=1:length(daysToPredict)
    history = fantasypoint(:, 1:daysToPredict(iDay)-1);
    minHist = minutes(:, 1:daysToPredict(iDay)-1);
    predicted(:,iDay) = project(history, minHist, opts);
  end
  
%   plot(daysToTest, predicted(180,:), 'r-x');
  methodPrediction{iMethod} = predicted;
  
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
  errorsTop50(iMethod) = mean(errorDay);
  
  diff = gt - predicted;
  unavail = isnan(gt);
  diff(unavail) = 0;
  errors = sum(abs(diff));
  playerCount = sum(~unavail);
  avgErrorPerDay = errors./playerCount;
  errorsAll(iMethod) = mean(avgErrorPerDay);
end

if false
  for playerID = 1:20
    hold off;
    playerGT = gt(playerID, :);
    dayNotPlay = isnan(playerGT);
    if sum(~dayNotPlay) == 0
      continue
    end
    dt = daysToTest;
    dt = dt(~dayNotPlay);
    playerGT(dayNotPlay) = [];
    plot(dt, playerGT, 'r-x'); hold on;
    plot(dt, methodPrediction{1}(playerID, ~dayNotPlay), 'g-x');
    plot(dt, methodPrediction{2}(playerID, ~dayNotPlay), 'b-x');
    plot(dt, methodPrediction{3}(playerID, ~dayNotPlay), 'c-x');
    grid on

    legend([{'gt'}, methods]);
  end
end

fprintf('Results\n');
errorsAll
errorsTop50