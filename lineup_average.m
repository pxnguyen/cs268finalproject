function res=lineup_average(info, history, salary, avail, opts)
% with the provided information, return the average lineup
% strategy: get the average salary, B/8, get the guys with the best project
% fantasy points at the price salary
% predicted_values: the predicted total fantasy points for this team
names = info.names;
positions = info.positions;
% salary = history.salary(:, end);
% fantasypoint = history.fantasypoint;
% fp_projection = history.fantasypoint;
% fp_projection(isnan(fp_projection)) = 0;
% fp_projection = mean(fp_projection, 2);
salaryPerPlayer = opts.salarycap/8;
res = cell(8, 1);
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
  fitIndeces = find(fitpos & fitsalary & avail);
  [~, imax] = max(salary(fitIndeces));
  bestfit = fitIndeces(imax);
  avail(bestfit) = false; % take the player out
  res{iPos} = names{bestfit};
end
end