function res=lineup_big3(info, history, salary, avail, opts)
% with the provided information, return the average lineup
% strategy: get the big 3 players, share the average
res = cell(8, 1);
names = info.names(avail);
positions = info.positions(avail);
playerAvailable = avail(avail);

fp_projection = history.fantasypoint;
fp_projection(isnan(fp_projection)) = 0;
total = sum(fp_projection, 2);
playCount = sum(fp_projection~=0, 2);
fp_projection = total ./ (playCount +eps);
pfp = fp_projection(avail);
% fp_projection = fp_projection(:,end); % average projection
salary = salary(avail);
values = (pfp * 1000) ./ (salary+eps);
% fp_projection = mean(fp_projection, 2); % average projection

% get the top-10 projected points
[~, indeces_pfp] = sort(pfp, 'descend');
[~, indeces_values] = sort(values(indeces_pfp(1:10)), 'descend');
top3indeces = indeces_pfp(indeces_values);
top3indeces = top3indeces(1:3); % select 3
playerAvailable(top3indeces) = false;

big3names = names(top3indeces);
big3salary = salary(top3indeces);
salaryLeft = opts.salarycap - sum(big3salary);
salaryLeftPerPlayer = salaryLeft / 5;

% adding the top 3
for iName = 1:length(big3names)
  n = big3names{iName};
  pos = positions{strcmp(n, names)};
  res = add2lineup(res, n, pos, opts);
end
for iPos = 1:length(opts.positions)
  isFilled = ~isempty(res{iPos});
  if isFilled; continue; end;
  tofill = opts.positions{iPos};
  switch tofill
    case 'G'
      fitpg = strcmp('PG', positions);
      fitsg = strcmp('SG', positions);
      fitpos = fitpg | fitsg;
    case 'F'
      fitsf = strcmp('SF', positions);
      fitpf = strcmp('PF', positions);
      fitpos = fitsf | fitpf;
    case 'Util'
      fitpos = true(length(positions), 1);
    otherwise
      fitpos = strcmp(tofill, positions);
  end
  fitsalary = salary <= salaryLeftPerPlayer;
  fitIndeces = find(fitpos & fitsalary & playerAvailable);
  [~, imax] = max(salary(fitIndeces));
  bestfit = fitIndeces(imax);
  playerAvailable(bestfit) = false; % take the player out
  res{iPos} = names{bestfit};
end
function newlineup = add2lineup(lineup, name, position, opts)
newlineup = lineup;
% find a position to add the player
pos_rules = opts.positions;
slot = find(strcmp(position, pos_rules));
% that position empty, add it
if isempty(lineup{slot})
  newlineup{slot} = name;
  return
end

% try slot G or F
if any(strcmp(position, {'PG', 'SG'}))
  slot = 6;
elseif any(strcmp(position, {'SF', 'PF'}))
  slot = 7;
end

if isempty(lineup{slot})
  newlineup{slot} = name;
  return
end

% try slot UTIL
slot = 8;

if isempty(lineup{slot})
  newlineup{slot} = name;
  return
end

fprintf('Something wrong. Cannot add this player %s %s\n', name, position);