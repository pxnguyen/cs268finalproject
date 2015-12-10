%% comparing the methods
projectionMethods = {'average', 'last', 'regression'};
pickingStrategy = {'average', 'big3', 'adhoc', 'SA'};

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
for iStrat = 1:length(pickingStrategy)
  iStrat
  for iProj=1:length(projectionMethods)
    resname = sprintf('results/draftkings-%s-%s.mat', projectionMethods{iProj}, pickingStrategy{iStrat});
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
    fprintf('%s-%s', projectionMethods{iProj}, pickingStrategy{iStrat})
    a = load(sprintf('results/fanduel-%s-%s.mat', projectionMethods{iProj}, pickingStrategy{iStrat}));
    a = a.res;
    mean(a.afp_all)
  end
end

%%
for iStrat = 1:length(pickingStrategy)
  for iProj=1:length(projectionMethods)
    fprintf('%s-%s', projectionMethods{iProj}, pickingStrategy{iStrat})
    a = load(sprintf('results/%s-%s.mat', projectionMethods{iProj}, pickingStrategy{iStrat}));
    a = a.res;
    mean(a.afp_all)
  end
end