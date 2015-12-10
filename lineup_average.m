function res=lineup_average(info, history, salary, pfp, avail, opts)
% with the provided information, return the average lineup
% strategy: get the average salary, B/8, get the guys with the best project
% fantasy points at the price salary
res = cell(8, 1);

salaryPerPlayer = opts.salarycap/8;

names = info.names(avail);
positions = info.positions(avail);
playerAvailable = avail(avail);

pfp = pfp(avail);
salary = salary(avail);

for iPos = 1:length(opts.positions)
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
  fitsalary = salary <= salaryPerPlayer;
  fitIndeces = find(fitpos & fitsalary);
  [~, imax] = max(pfp(fitIndeces));
  bestfit = fitIndeces(imax);
  playerAvailable(bestfit) = false; % take the player out
  res{iPos} = names{bestfit};
end
end