 function res=lineup_adhoc(info, history, salary, fantasy_project, avail, opts)
% with the provided information, return the lineup wrt to first baseline
% stratergy: Solve the optimization prb and then use adhoc (manually) correct
% for wrong for correct position. This uses interior point method
% optimization
% 
% by Nitin Agarwal  CS 228
% 7th Dec 2015

res=cell(8,1); % THE ACTUAL LINEUP

pfp = fantasy_project(avail);
salary = salary(avail);
names = info.names(avail);
positions = info.positions(avail);

myavail=find(avail==1); % the available players from which to select
nPlayer = length(myavail);
playerAvailable = avail(avail);

%optimization
nRestart = 1;
candidateCell = cell(nRestart, 1);
vals = zeros(nRestart, 1);
for iRestart = 1:nRestart
  iRestart
  fun = -pfp;

  A = salary';
  b = opts.salarycap;

  Aeq = ones(1, nPlayer);
  beq = 8;

  lb = zeros(nPlayer, 1);                     % lower bounds
  ub = ones(nPlayer, 1);                     % lower bounds

  intcon = 1:nPlayer;

  candidates = intlinprog(fun,intcon,A,b,Aeq,beq,lb,ub);
  candidateCell{iRestart} = candidates;
  

  names(candidates > 0) % names of the players
  vals(iRestart) = sum(pfp(candidates > 0)); % current total
end

[~, imax] = max(vals);
candidates = candidateCell{imax};

% ---checking the lineup and chosing the best from the above optimization--
% checking for valid positions in x. This is computed wrt to available players.

x = find(candidates);
[~,b]=sort(pfp(x),'descend');
sortedPlayers = x(b);
filled = false(length(sortedPlayers), 1);
for i=1:length(sortedPlayers)
  player = sortedPlayers(i);
  
  % try to put this player into the lineup
  pos = positions{player};
  switch pos
    case 'PG'
      potential = [1 6 8];
    case 'SG'
      potential = [2 6 8];
    case 'SF'
      potential = [3 7 8];
    case 'PF'
      potential = [4 7 8];
    case 'C'
      potential = [5 8];
  end
  
  for pot = potential
    if isempty(res{pot})
      res{pot} = names{player};
      filled(i) = true;
      playerAvailable(i) = false;
      break
    end
  end
end

leftover = sortedPlayers(~filled);
positions2fill = find(cellfun(@isempty, res));

for iPos = 1:length(positions2fill)
  tofillIndex = positions2fill(iPos);
  tofillName = opts.positions{tofillIndex};
  
  switch tofillName
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
      fitpos = strcmp(tofillName, positions);
  end
  
  toberemoved = leftover(1);
  oldsalary = salary(toberemoved);
  
  newguy = salary <= oldsalary & fitpos & playerAvailable;
  newguy = find(newguy);
  [~,imax] = max(pfp(newguy));
  newguy = newguy(imax);
  res{tofillIndex} = names{newguy};
  playerAvailable(newguy) = false;
  
  % take the old guy out of the leftover
  leftover(1) = [];
end


% for j=1:8
%   position=positions(x(b(j)));
%   emptycell=cellfun(@isempty,res);
%   p = x(b(j));
%   switch position{1}
%     case 'PG'
%         if(emptycell(1)==1)
%             res{1}=names(p);
%         else
%             extra{k} = x(b(j));
%             k=k+1;
%         end
%     case 'SG'
%         if(emptycell(2)==1)
%             res{2}=names(p);
%         else
%             extra{k} = x(b(j));
%             k=k+1;
%         end
%     case 'SF'
%         if(emptycell(3)==1)
%             res{3}=names(p);
%         else
%             extra{k} = x(b(j));
%             k=k+1;
%         end
%     case 'PF'
%         if(emptycell(4)==1)
%             res{4}=names(p);
%         else
%             extra{k} = x(b(j));
%             k=k+1;
%         end
%     case 'C'
%         if(emptycell(5)==1)
%             res{5}=names(p);
%         else
%             extra{k} = x(b(j));
%             k=k+1;
%         end
%   end
% end
% 
% %------adding missing players in lineup using same salary-----------------
% emptycell=cellfun(@isempty,res);             
% idx=find(emptycell==1);
% for j=1:length(idx)      % replacing the repeating players
%   it=1;
%   for k=1:8
%    if(~isempty(res{k}))
%        val(it)=find(strcmp(res{k},names)==1); % current lineuup in indices
%        it=it+1;
%    end
%   end
%   
%   oldplayer = extra{j};
%   
%   newplayer = switchPlayer(opts.positions{idx(j)}, sal(extra{j}),...
%     pfp, positions, sal, val);
%   
%   res{idx(j)} = names(newplayer);
%   
% %   if(newplayer==0)
% %      b=find(strcmp(opts.positions{idx(j)}, info.positions(myavail)));
% %      res{idx(j)} = names(myavail(randi(length(b),1)));
% %   else
%   
% end
 
end
 
 
function newplayerIndex = switchPlayer(oldplayerposition,oldplayersalary,myavail,fantasy_project,positions,sal,val)
 
if(strcmp(oldplayerposition,'PG') || strcmp(oldplayerposition,'SG') || strcmp(oldplayerposition,'SF') ||...
        strcmp(oldplayerposition,'SG') || strcmp(oldplayerposition,'C'))
    
 availablePositions=positions(myavail);
 a=find(strcmp(availablePositions,oldplayerposition)); % shortlisted players with same position
 newArray(:,1)=fantasy_project(myavail(a));
 newArray(:,2)=sal(myavail(a));
 
[~,id]=sort(newArray(:,1),'descend');
 
newplayerIndex=0;           % just to initialize it and check
for i=1:length(id)
  if(newArray(id(i),2)<=oldplayersalary)
    newplayerIndex = myavail(a(id(i)));
    break;
  end
end

else
    availablePositions=positions(myavail); 
    newplayerIndex=0; 
    
    switch oldplayerposition
        case 'G'
            a=find(strcmp(availablePositions,'PG') | strcmp(availablePositions,'SG'));
            newArray(:,1)=fantasy_project(myavail(a));
            newArray(:,2)=sal(myavail(a));
            
            [~,id]=sort(newArray(:,1),'descend');
            
            for i=1:length(id)
                if(newArray(id(i),2)<=oldplayersalary & myavail(a(id(i)))~=val)
                    newplayerIndex = myavail(a(id(i)));
                    break;
                end
            end
        case 'F'
            a=find(strcmp(availablePositions,'PF') | strcmp(availablePositions,'SF'));
            newArray(:,1)=fantasy_project(myavail(a));
            newArray(:,2)=sal(myavail(a));
            
            [~,id]=sort(newArray(:,1),'descend');
            
            for i=1:length(id)
                if(newArray(id(i),2)<=oldplayersalary & myavail(a(id(i)))~=val)
                    newplayerIndex = myavail(a(id(i)));
                    break;
                end
            end
        case 'Util'
            newArray(:,1)=fantasy_project(myavail);
            newArray(:,2)=sal(myavail);
            
            [~,id]=sort(newArray(:,1),'descend');
            
            for i=1:length(id)
                if(newArray(id(i),2)<=oldplayersalary & myavail(id(i))~=val)
                    newplayerIndex = myavail(id(i));
                    break;
                end
            end
    end
    
end

end
