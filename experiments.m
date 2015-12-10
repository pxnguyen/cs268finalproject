%% comparing the methods
<<<<<<< HEAD
projectionMethods = {'average', 'last', 'regression'};
pickingStrategy = {'big3'};
=======
projectionMethods = {'average', 'last'};
pickingStrategy = {'average', 'big3','lineup_adhoc'};
>>>>>>> c43dedbebf7c2303fb5305a546ddb96d6f9f4d51

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