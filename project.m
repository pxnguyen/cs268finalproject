function projected=project(history, method, weightType)
% method: 'average', 'last', 'curvefit', 'logistic regression'
% % history: array of fantasy points

nPlayer = size(history, 1);
nDay = size(history,2);
projected = zeros(nPlayer, 1);
switch method
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
        projected(iPlayer) = NaN;
        continue;
      end
      projected(iPlayer) = playerHist(end);
    end
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