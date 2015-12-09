% function newplayerIndex = switchPlayer(oldplayerposition,oldplayersalary,myavail,fantasy_project,positions,sal)
%  
%  availablePositions=positions(myavail);
%  a=find(strcmp(availablePositions,oldplayerposition)); % shortlisted players with same position
%  newArray(:,1)=fantasy_project(myavail(a));
%  newArray(:,2)=sal(myavail(a));
%  
% [~,id]=sort(newArray(:,1),'descend');
%  
% newplayerIndex=0;           % just to initialize it and check
% for i=1:length(id)
%    if(newArray(id(i),2)<=oldplayersalary)
%       newplayerIndex = myavail(a(id(i)));
%       break;
%    end
% end
% 
% end
% 
% function newplayerIndex = switchPlayer(oldplayerposition,oldplayersalary,myavail,fantasy_project,positions,sal)
%  
% if(strcmp(oldplayerposition,'PG') || strcmp(oldplayerposition,'SG') || strcmp(oldplayerposition,'SF') ||...
%         strcmp(oldplayerposition,'SG') || strcmp(oldplayerposition,'C'))
%  availablePositions=positions(myavail);
%  a=find(strcmp(availablePositions,oldplayerposition)); % shortlisted players with same position
%  newArray(:,1)=fantasy_project(myavail(a));
%  newArray(:,2)=sal(myavail(a));
%  
% [~,id]=sort(newArray(:,1),'descend');
%  
% newplayerIndex=0;           % just to initialize it and check
% for i=1:length(id)
%    if(newArray(id(i),2)<=oldplayersalary)
%       newplayerIndex = myavail(a(id(i)));
%       break;
%    end
% end
% 
% else
%     availablePositions=positions(myavail); 
%     newplayerIndex=0; 
%     
%     switch oldplayerposition
%         case 'G'
%             a=find(strcmp(availablePositions,'PG') | strcmp(availablePositions,'SG'));
%             newArray(:,1)=fantasy_project(myavail(a));
%             newArray(:,2)=sal(myavail(a));
%             
%             [~,id]=sort(newArray(:,1),'descend');
%             
%             for i=1:length(id)
%                 if(newArray(id(i),2)<=oldplayersalary)
%                     newplayerIndex = myavail(a(id(i)));
%                     break;
%                 end
%             end
%         case 'F'
%             a=find(strcmp(availablePositions,'PF') | strcmp(availablePositions,'SF'));
%             newArray(:,1)=fantasy_project(myavail(a));
%             newArray(:,2)=sal(myavail(a));
%             
%             [~,id]=sort(newArray(:,1),'descend');
%             
%             for i=1:length(id)
%                 if(newArray(id(i),2)<=oldplayersalary)
%                     newplayerIndex = myavail(a(id(i)));
%                     break;
%                 end
%             end
%         case 'Util'
%             newArray(:,1)=fantasy_project(myavail);
%             newArray(:,2)=sal(myavail);
%             
%             [~,id]=sort(newArray(:,1),'descend');
%             
%             for i=1:length(id)
%                 if(newArray(id(i),2)<=oldplayersalary)
%                     newplayerIndex = myavail(id(i));
%                     break;
%                 end
%             end
%     end
%     
% end
% 
% end


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