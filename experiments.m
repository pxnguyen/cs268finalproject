%% comparing the methods
projectionMethods = {'average', 'last', 'regression'};
pickingStrategy = {'big3'};

resultsSet = cell(length(pickingStrategy), length(projectionMethods));
for iStrat = 1:length(pickingStrategy)
  for iProj=1:length(projectionMethods)
    opts = struct;
    opts.strategy = pickingStrategy{iStrat};
    opts.projectionMethod = projectionMethods{iProj};
    res = lineup(opts);
    resultsSet{iStrat, iProj} = res;
  end
end

%% plotting