function res=lineup_SA(info, history, salary, avail, opts)
% with the provided information, return the average lineup
% strategy: get the big 3 players, share the average
    res = cell(8, 1);
    names = info.names(avail);
    
    pkg.positions = info.positions(avail);
    %a=unique(pkg.positions,'stable')
    %b=cellfun(@(x) sum(ismember(pkg.positions,x)),a,'un',0)
    fp_projection = history.fantasypoint;
    fp_projection(isnan(fp_projection)) = 0;
    total = sum(fp_projection, 2);
    playCount = sum(fp_projection~=0, 2);
    fp_projection = total ./ (playCount +eps);
    pfp = fp_projection(avail);
    % fp_projection = fp_projection(:,end); % average projection
    
    pkg.salaryA = salary(avail);
    pkg.setCost = opts.salarycap;
    values = (pfp * 1000) ./ (pkg.salaryA+eps);
    pkg.pfp_avg = mean(pfp, 2); % average projection
    
    tmp_pfp = sort(pkg.pfp_avg);
    
    pkg.maxFP = sum(tmp_pfp(end-7:end));
    
    pkg.availN = length(avail);

    pkg.coolRate = 0.95;
    
    initial_indices = 1:1:8;
    xRes = sA(initial_indices, pkg.maxFP, 1, 0, pkg);
    res = names(xRes);
end

function [xNew] = sA(xOld, Tmax, epsDeltaT, Tmin,  pkg)
    T = Tmax;
    step = 0;
    delta = 10;
    counter = 0;
    while (delta > epsDeltaT && T > Tmin && counter<10)
        counter = counter + 1
        energyVal(xOld, pkg)
        xNew = acceptN(xOld, T, 10, pkg);
        T = T * pkg.coolRate;
        step = step + 1;
        
        delta = abs(energyVal(xOld, pkg)-energyVal(xNew, pkg));
        xOld = xNew;
        
    end
end

function [xNew] = flip(xOld, pkg)
   isOK = false;
   while(~isOK)
      xNew = flipOne(xOld, pkg);
      
        totalCost = sum(pkg.salaryA(xNew));
        costOK = totalCost < pkg.setCost;
%         costOK

        tmpPos = pkg.positions(xNew);
        pgCnt = 0;
        sgCnt = 0;
        pfCnt = 0;
        sfCnt = 0;
        cCnt = 0;
        for i=1:length(tmpPos)
            
            switch tmpPos{i}
                case 'PG'
                    pgCnt = pgCnt+1;
                case 'SG'
                    sgCnt = sgCnt+1;
                case 'PF'
                    pfCnt = pfCnt+1;
                case 'SF'
                    sfCnt = sfCnt+1;
                otherwise
                    cCnt = cCnt+1;
            end
        end
        gCnt = pgCnt+sgCnt;
        fCnt = pfCnt+sfCnt;

        posOK = (pgCnt>=1 && sgCnt>=1 && pfCnt>=1 && sfCnt>=1 && cCnt>=1 && gCnt>=3 && fCnt>=3);
%         posOK
        
        %fprintf('------\n');
        isOK = posOK && costOK;
        
   end
end


function [xNew] = flipOne(xOld, pkg)
   steps = ceil( (pkg.availN-8) * rand(1));
   candInd = ceil(8*rand(1));
   for i=1:length(pkg.pfp_avg)
      if (ismember(i, xOld)==0) 
          steps = steps-1;
      end
      if (steps == 0)
          xOld(candInd) = i;
          break;
      end
   end
   xNew = xOld;
end
function [x] = acceptN(xOld, T, innerIter, pkg)
    for k = 1:innerIter
        xNew = flip(xOld, pkg);
        deltaE = energyVal(xOld, pkg) - energyVal(xNew, pkg);
        if (deltaE > 0)
            xOld = xNew;
        else
            if (exp(deltaE/T) > rand(1))
                xOld = xNew;
            end
        end
    end
    x = xOld;
end

function [v] = energyVal(x, pkg)
%UNTITLED Summary of this function goes here
    %coloring;
    v = 0;
    for i = 1:length(x)
        v = v + pkg.pfp_avg(x(i));
    end
    v = pkg.maxFP - v;
end


