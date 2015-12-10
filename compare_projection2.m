function compare_projection2
fid = fopen('data.fanduel.formatted.scsv');
fmt = repmat('%s', [1, 53]);
output = textscan(fid, fmt, 'delimiter', ';');
info = {};
info.names = output{1};
info.teams = output{2};
info.positions = output{3};
fp = cat(2, output{5:2:end});
fantasypoint = cell2mat(cellfun(@(x) str2double(x), fp, 'UniformOutput', false));

methodName = 'curvefit';
weightType = {'uniform', 'linear', 'quadratic'};

maxDay = size(fantasypoint, 2);
daysToTest = 16:maxDay;
gt = fantasypoint(:,daysToTest);

daysToPredict = daysToTest;
errorsTotal = cell(length(weightType), 1);
methodPrediction = cell(length(weightType), 1);

for iType = 1:length(weightType)
  predicted = zeros(size(gt));
  type = weightType{iType};
  for iDay=1:length(daysToPredict)
    history = fantasypoint(:, 1:daysToPredict(iDay)-1);
    predicted(:,iDay) = project(history, methodName, type);
  end
  
  methodPrediction{iType} = predicted;

  diff = gt - predicted;
  unavail = isnan(diff);
  diff(unavail) = 0;
  errors = sum(abs(diff));
  playerCount = sum(~unavail);
  avgError = errors./playerCount;
  errorsTotal{iType} = avgError;
end

if true
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

    legend({'gt', 'uniform', 'linear', 'quadratic'});
  end
end