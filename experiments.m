%% comparing the methods
projectionMethods = {'average', 'last', 'regression'};
pickingStrategy = {'adhoc', 'SA'};
%pickingStrategy = {'average', 'big3', 'adhoc', 'SA'};

opts = struct;
opts.startTestDay = 20;

%% fanduel
resultsSet = cell(length(pickingStrategy), length(projectionMethods));
for iStrat = 1:length(pickingStrategy)
  iStrat
  for iProj=1:length(projectionMethods)
    resname = sprintf('results/fanduel-%s-%s.mat', projectionMethods{iProj}, pickingStrategy{iStrat});
    if exist(resname, 'file')
      continue;
    end
    opts.strategy = pickingStrategy{iStrat};
    opts.projectionMethod = projectionMethods{iProj};
    res = lineup(opts);
    resultsSet{iStrat, iProj} = res;
    save(resname, 'res');
  end
end

%% Draft kings
resultsSet = cell(length(pickingStrategy), length(projectionMethods));
opts.dataset = 'draftkings';
for iStrat = 1:length(pickingStrategy)
  for iProj=1:length(projectionMethods)
    resname = sprintf('results/%s-%s-%s.mat', opts.dataset, projectionMethods{iProj}, pickingStrategy{iStrat});
    if exist(resname, 'file')
      continue;
    end
    opts.strategy = pickingStrategy{iStrat};
    opts.projectionMethod = projectionMethods{iProj};
    res = lineup(opts);
    resultsSet{iStrat, iProj} = res;
    save(resname, 'res');
  end
end

%% plotting

for iStrat = 1:length(pickingStrategy)
  for iProj=1:length(projectionMethods)
    a = load(sprintf('results/fanduel-%s-%s.mat', projectionMethods{iProj}, pickingStrategy{iStrat}));
    a = a.res;
    fprintf('%s-%s, projected: %0.2f actual: %0.2f\n', projectionMethods{iProj}, pickingStrategy{iStrat},...
      mean(a.pfp_all), mean(a.afp_all));
  end
end

%%
for iStrat = 1:length(pickingStrategy)
  for iProj=1:length(projectionMethods)
    resname = sprintf('results/%s-%s-%s.mat', opts.dataset, projectionMethods{iProj}, pickingStrategy{iStrat});
    a = load(resname);
    a = a.res;
    fprintf('%s-%s, projected: %0.2f actual: %0.2f\n', projectionMethods{iProj}, pickingStrategy{iStrat},...
      mean(a.pfp_all), mean(a.afp_all));
  end
end