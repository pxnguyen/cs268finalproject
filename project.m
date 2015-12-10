function projected=project(history, minutes, varargin)
% method: 'average', 'last', 'curvefit', 'logistic regression'
% % history: array of fantasy points
opts.weightType = 'uniform';
opts.method = 'average';
opts.windowSize = 2;
opts = vl_argparse(opts, varargin);

if nargin < 3
  weightType = 'uniform';
end
nPlayer = size(history, 1);
nDay = size(history,2);
projected = zeros(nPlayer, 1);
switch opts.method
  case 'average'
    valid = ~isnan(history);
    dayplays = sum(valid, 2);
    history(isnan(history)) = 0;
    projected = sum(history, 2)./(dayplays+eps);
  case 'last'
    for iPlayer = 1:nPlayer
      playerHist = history(iPlayer, :);
      playerHist(isnan(playerHist)) = [];
      if isempty(playerHist)
        projected(iPlayer) = 0;
        continue;
      end
      projected(iPlayer) = playerHist(end);
    end
  case 'regression'
    windowSize = opts.windowSize;
    features = zeros(1e5, windowSize + windowSize + 1 + 1); % 5 days history + avg + bias
    feat4pred = zeros(nPlayer, windowSize + windowSize + 1 + 1); % 2 days history + day + bias
    target = zeros(1e5, 1);
    index = 1;
    for iPlayer = 1:nPlayer
      playerHist = history(iPlayer, :);
      playerMinutes = minutes(iPlayer, :);
      avail = ~isnan(playerHist);
      nAvail = sum(avail);
      X = 1:length(playerHist); X = X(avail)';
      playerHist = playerHist(avail);
      playerMinutes = playerMinutes(avail);
      if length(playerHist) < windowSize+1 % not enough data to predict
        feat4pred(iPlayer, :) = nan(1, 2*windowSize + 1 + 1);
      else
        for iDay = windowSize+1:nAvail-1
          avg = mean(playerHist(1:iDay-1));
          features(index, :) = [playerHist(iDay-windowSize:iDay-1)...
            playerMinutes(iDay-windowSize:iDay-1) avg 1];
          target(index) = playerHist(end);
          index = index + 1;
        end
        avg = mean(playerHist);
        feat4pred(iPlayer, :) = [playerHist(end-windowSize+1:end)...
          playerMinutes(end-windowSize+1:end) avg 1];
      end
    end
    
    features = features(1:index-1,:);
    target = target(1:index-1,:);
    weights = features\target;
    projected = feat4pred*weights;
    projected(isnan(projected)) = 0;
  case 'curvefit'
    for iPlayer = 1:nPlayer
      X = 1:nDay;
      playerHist = history(iPlayer, :);
      DNP = isnan(playerHist);
      switch weightType
        case 'uniform'
          W = ones(length(playerHist), 1);
        case 'linear'
          W = (1:nDay);
        case 'quadratic'
          W = X.^2;
        otherwise
          W = ones(length(playerHist), 1);
      end
      W(DNP) = []; W = W./sum(W);
      X(DNP) = [];
      playerHist(DNP) = [];
      if isempty(X); projected(iPlayer) = NaN; continue; end
      if length(X) == 1; projected(iPlayer) = playerHist(1); continue; end
      s = csaps(X,playerHist, [], [], W);
      g = fnxtr(s);
      v = ppual(g, nDay+1);
      projected(iPlayer) = v;
    end
  case 'logistic regression'
  otherwise
    fprintf('Something is wrong\n');
end