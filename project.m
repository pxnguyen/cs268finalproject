function projected=project(history, method)
% method: 'average', 'last', 'curvefit', 'logistic regression'
% % history: array of fantasy points

nPlayer = size(history, 1);
nDay = size(history,2);
projected = zeros(nPlayer, 1);
switch method
  case 'average'
    valid = isnan(history);
    dayplays = sum(valid, 2);
    history(isnan(history)) = 0;
    projected = sum(history, 2)./(dayplays);
  case 'last'
    projected = history(:,end);
  case 'curvefit'
    for iPlayer = 1:nPlayer
      X = 1:nDay;
      playerHist = history(iPlayer, :);
      X(isnan(playerHist)) = [];
      playerHist(isnan(playerHist)) = [];
      if isempty(X)
        projected(iPlayer) = NaN;
        continue
      end
      
      if length(X) == 1
        projected(iPlayer) = playerHist(1);
        continue;
      end
      s = csaps(X,playerHist);
      v = ppual(s, nDay+1);
      projected(iPlayer) = v;
    end
  case 'logistic regression'
  otherwise
    fprintf('Something is wrong\n');
end