function results=lineup(varargin)
% the valid results must have a PG, SG, SF, PF, C, G, F, Util.
opts.strategy = 'SA';
opts.projectionMethod = 'average';
opts.startTestDay = 10;
opts.salarycap = 50000.00;
opts.positions = {'PG', 'SG', 'SF', 'PF', 'C', 'G', 'F', 'Util'};
opts.debug = true;
opts.dataset = 'fanduel';
opts = vl_argparse(opts, varargin);

% -------
% loading the player stats
% -------

dataname = sprintf('data.%s.formatted.scsv', opts.dataset);
fid = fopen(dataname);
fmt = repmat('%s', [1, 117]);
output = textscan(fid, fmt, 'delimiter', ';');
info = {};
info.names = output{1};
info.teams = output{2};
info.positions = output{3};
salary = cat(2, output{4:3:end});
fp = cat(2, output{5:3:end});
minutes = cat(2, output{6:3:end});
salary = cell2mat(cellfun(@(x) str2double(x(2:end)), salary, 'UniformOutput', false));
fantasypoint = cell2mat(cellfun(@(x) str2double(x), fp, 'UniformOutput', false));
minutes = cell2mat(cellfun(@(x) str2double(x), minutes, 'UniformOutput', false));

nDay = size(salary, 2);

% picking the line up
dayToTest = opts.startTestDay:nDay;
nTestDay = length(dayToTest);
line_all = cell(nTestDay, 1);
pfp_all = zeros(nTestDay, 1); % projected fp
afp_all = zeros(nTestDay, 1); % actual fp
totalsalary_all = zeros(nTestDay, 1);
parfor iDay=1:length(dayToTest)
  day= dayToTest(iDay);
  avail = ~isnan(salary(:,day)) & ~isnan(fantasypoint(:,day));
  history = {};
  history.salary = salary(:, 1:day);
  history.fantasypoint = fantasypoint(:, 1:day-1);
  history.minutes = minutes(:, 1:day-1);
  projopts = struct;
  projopts.method = opts.projectionMethod;
  fp_projection = project(history.fantasypoint, history.minutes, projopts);
  switch opts.strategy
    case 'average'
      res = lineup_average(info, history, salary(:,day), fp_projection, avail, opts);
    case 'big3'
      res = lineup_big3(info, history, salary(:,day), fp_projection, avail, opts);
    case 'adhoc'
      res = lineup_adhoc(info, history, salary(:,day), fp_projection, avail, opts);
    case 'SA'
      res = lineup_SA(info, history, salary(:,day), fp_projection, avail, opts);
  end

  % TODO: check to see if lineup is valid
  line_all{iDay} = res;
  indeces = cellfun(@(x) find(strcmp(x, info.names)), res);
  totalsalary_all(iDay) = sum(salary(indeces, day));
  pfp_all(iDay) = sum(fp_projection(indeces));
  afp_all(iDay) = sum(fantasypoint(indeces, day));
end

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
