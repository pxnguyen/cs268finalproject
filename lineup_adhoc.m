 function res=lineup_adhoc(info, history, salary, avail, opts)
% with the provided information, return the lineup wrt to first baseline
% stratergy: Solve the optimization prb and then use adhoc (manually) correct
% for wrong for correct position. This uses interior point method
% optimization
% 
% by Nitin Agarwal  CS 228
% 7th Dec 2015

res=cell(8,1); % THE ACTUAL LINEUP

sal=salary;      % last day salary of all players

% computing the projected fatansy (using average)
% fantasy_project=zeros(size(history.fantasypoint,1),1);
% for i=1:size(history.fantasypoint,1)
% ids=find(~isnan(history.fantasypoint(i,:)));
% fantasy_project(i)=mean(history.fantasypoint(i,ids));  % projected fantasy point of all players
% end
fantasy_project=project(history.fantasypoint,opts.projectionMethod,'quadratic');

fantasy_project(isnan(fantasy_project))=0;  % removing all the Nan values if any
sal(isnan(sal))=0;                          % removing all the Nan values if any

myavail=find(avail==1); % the available players from which to select

%optimization
% trying to find the global minimum by restarting with different intial point.
for k=1:5
fun = @(x)-(fantasy_project(myavail(floor(x(1))))+fantasy_project(myavail(floor(x(2))))+fantasy_project(myavail(floor(x(3))))...
    +fantasy_project(myavail(floor(x(4))))+fantasy_project(myavail(floor(x(5))))+fantasy_project(myavail(floor(x(6))))...
    +fantasy_project(myavail(floor(x(7))))+fantasy_project(myavail(floor(x(8))))); % obj function

A = [-1,1,0,0,0,0,0,0;0,0,-1,1,0,0,0,0;0,0,0,0,-1,1,0,0;0,0,0,0,0,0,-1,1];
b = [-50;-50;-50;-50];
x0 = randi(length(myavail),[8,1])'; % intial points
lb = ones(1,8);                     % lower bounds
ub = length(myavail)*ones(1,8);     % upper bounds
    
options = optimoptions('fmincon','InitBarrierParam',50,'Hessian','lbfgs'); % setting options
[x,fval] = fmincon(fun,x0,A,b,[],[],lb,ub,[],options);

% options = optimoptions('fmincon','Display','iter','InitBarrierParam',50,'Hessian','lbfgs'); % setting options

while(sum(sal(myavail(floor(x))))>opts.salarycap)
    x0=x;
    options = optimoptions('fmincon','InitBarrierParam',50,'Hessian','lbfgs'); % setting options
    [x,fval] = fmincon(fun,x0,A,b,[],[],lb,ub,[],options);
end

iter(k,:)=[abs(fval),x(1:8)]; % different intial point
end

[~,indices]=sort(iter(:,1),'descend');
x=floor(iter(indices(1),2:end));        % final selection wrt to available players to get kind of global max


% ---checking the lineup and chosing the best from the above optimization--
% checking for valid positions in x. This is computed wrt to available players.

[~,b]=sort(fantasy_project(myavail(x)),'descend');
k=1; % number of repeat players

for j=1:8
    position=info.positions(myavail(x(b(j))));
    emptycell=cellfun(@isempty,res);
    switch position{1}
        case 'PG'
            if(emptycell(1)==1)
                res{1}=info.names(myavail(x(b(j))));
            else
                extra{k} = x(b(j));
                k=k+1;
            end
        case 'SG'
            if(emptycell(2)==1)
                res{2}=info.names(myavail(x(b(j))));
            else
                extra{k} = x(b(j));
                k=k+1;
            end
        case 'SF'
            if(emptycell(3)==1)
                res{3}=info.names(myavail(x(b(j))));
            else
                extra{k} = x(b(j));
                k=k+1;
            end
        case 'PF'
            if(emptycell(4)==1)
                res{4}=info.names(myavail(x(b(j))));
            else
                extra{k} = x(b(j));
                k=k+1;
            end
        case 'C'
            if(emptycell(5)==1)
                res{5}=info.names(myavail(x(b(j))));
            else
                extra{k} = x(b(j));
                k=k+1;
            end
    end
end

%------adding missing players in lineup using same salary-----------------
emptycell=cellfun(@isempty,res);             
idx=find(emptycell==1);
for j=1:length(idx)      % replacing the repeating players
   it=1;
   for k=1:8
       if(~isempty(res{k}))
           val(it)=find(strcmp(res{k},info.names)==1); % current lineuup in indices
           it=it+1;
       end
   end
   positions=info.positions;
   newplayer=switchPlayer(opts.positions{idx(j)},sal(myavail(extra{j})),myavail,fantasy_project,positions,sal,val);
   if(newplayer==0)
       res{idx(j)}={'No player at that position playing today'};
   else
   res{idx(j)}=info.names(newplayer);
   end
end

 
%-------- cross checking the total projected fantasy points and salary------
% totalfantasy_project=0;
% totalsalary=0;
% for i=1:8
% val=strcmp(res{i},info.names);
% totalfantasy_project=totalfantasy_project+fantasy_project(val);
% totalsalary=totalsalary+sal(val);
% finalposition{i}=info.positions(val);
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