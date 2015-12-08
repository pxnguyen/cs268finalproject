function res=lineup_SA(info, history, salary, avail, opts)
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
    global salaryA
    salaryA = salary(avail);
    global setCost
    setCost = opts.salarycap;
    values = (pfp * 1000) ./ (salaryA+eps);
    pfp_avg = mean(pfp, 2); % average projection
    
    tmp_pfp = sort(pfp_avg);
    global maxFP
    maxFP = sum(tmp_pfp(end-7:end));
    
    global availN
    availN = length(avail);

    global coolRate
    coolRate = 0.95;
    
    initial_indices = 1:1:8
    xRes = sA(initial_indices, maxFP, 1, 0,  pfp_avg)
    res = names(xRes);
end

function [xNew] = sA(xOld, Tmax, epsDeltaT, Tmin,  pfp_avg)
    T = Tmax;
    step = 0;
    delta = 10;
    counter = 0;
    while (delta > epsDeltaT && T > Tmin && counter<100)
        counter = counter + 1
        energyVal(xOld, pfp_avg)
        xNew = acceptN(xOld, T, 10, pfp_avg);
        global coolRate;
        T = T * coolRate;
        step = step + 1;
        
        delta = abs(energyVal(xOld, pfp_avg)-energyVal(xNew, pfp_avg));
        xOld = xNew;
        
    end
end

function [xNew] = flip(xOld, pfp_avg)
   isOK = false;
   while(~isOK)
      xNew = flipOne(xOld, pfp_avg);
      
    global salaryA
      totalCost = sum(salaryA(xNew));
      
    global setCost
      isOK = totalCost < setCost;
   end
end


function [xNew] = flipOne(xOld, pfp_avg)
   global availN
   steps = ceil( (availN-8) * rand(1));
   candInd = ceil(8*rand(1));
   for i=1:length(pfp_avg)
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
function [x] = acceptN(xOld, T, innerIter, pfp_avg)
    for k = 1:innerIter
        xNew = flip(xOld, pfp_avg);
        deltaE = energyVal(xOld, pfp_avg) - energyVal(xNew, pfp_avg);
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

function [v] = energyVal(x, pfp_avg)
%UNTITLED Summary of this function goes here
    %coloring;
    v = 0;
    for i = 1:length(x)
        v = v + pfp_avg(x(i));
    end
    global maxFP
    v = maxFP - v;
end

