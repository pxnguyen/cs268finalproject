function results=lineup(varargin)
% the valid results must have a PG, SG, SF, PF, C, G, F, Util.
opts.strategy = 'SA';
opts.salarycap = 50000.00;
opts.positions = {'PG', 'SG', 'SF', 'PF', 'C', 'G', 'F', 'Util'};
opts.debug = true;
opts = vl_argparse(opts, varargin);

% -------
% loading the player stats
% -------

fid = fopen('data.fanduel.formatted.scsv');
fmt = repmat('%s', [1, 23]);
output = textscan(fid, fmt, 'delimiter', ';');
info = {};
info.names = output{1};
info.teams = output{2};
info.positions = output{3};
unique(info.positions)
salary = cat(2, output{4:2:end});
salary = cell2mat(cellfun(@(x) str2double(x(2:end)), salary, 'UniformOutput', false));
fp = cat(2, output{5:2:end});
fantasypoint = cell2mat(cellfun(@(x) str2double(x), fp, 'UniformOutput', false));


nDay = size(salary, 2);

% picking the line up
line_all = cell(nDay-1, 1);
pfp_all = zeros(nDay-1, 1); % projected fp
afp_all = zeros(nDay-1, 1); % actual fp
totalsalary_all = zeros(nDay-1, 1);
for day=2:nDay
  avail = ~isnan(salary(:,day)) & ~isnan(fantasypoint(:,day));
  history = {};
  history.salary = salary(:, 1:day);
  history.fantasypoint = fantasypoint(:, 1:day-1);
  switch opts.strategy
    case 'average'
      res = lineup_average(info, history, salary(:,day), avail, opts);
    case 'big3'
      res = lineup_big3(info, history, salary(:,day), avail, opts);
    case 'SA'
      res = lineup_SA(info, history, salary(:,day), avail, opts);
  end
  
  % TODO: check to see if lineup is valid
  line_all{day} = res;
  fp_projection = history.fantasypoint;
  fp_projection(isnan(fp_projection)) = 0;
  fp_projection = mean(fp_projection, 2);
  indeces = cellfun(@(x) find(strcmp(x, info.names)), res);
  totalsalary_all(day-1) = sum(salary(indeces, day));
  pfp_all(day-1) = sum(fp_projection(indeces));
  afp_all(day-1) = sum(fantasypoint(indeces, day));
end
line_all
results = {};
results.totalsalary_all = totalsalary_all;
results.pfp_all = pfp_all;
results.afp_all = afp_all;
results.line_all = line_all;

% plotting
if opts.debug
  close all;
  plot(results.pfp_all, 'LineWidth', 5); hold on;
  plot(results.afp_all, 'LineWidth', 5);
  grid on;
  legend('projected', 'actual');
end