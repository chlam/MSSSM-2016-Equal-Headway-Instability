function [ avgpeoplewaiting, meandelay, ntramskipped, cell1] = simulation( tracklength,initpostram,inittrampass,posstat,minwaitingtime,pb,cap,duration_simulation,behaviour,peoplerate,display)
%Simulation simulate the dynamic of the trams, returning mean delay e
%people waiting at the station according to the input parameters.
%EXAMPLE:% 
%tracklength = 50;                   % length of the track
% 
% initpostram = [10 20 30 40 50];     % initial position of trams
% inittrampass = [30 30 30 30 30];    % initial number of tram passengers
% posstat = [5 15 25 35 45];          % position of the stations
% 
% minwaitingtime=5;                   % if a tram is not delayed, the minimum
%                                     % number of waiting time instants of
%                                     % the tram at a station
% 
% 
%                                     
% pb=20;
% cap=60;                             % tram capacity
% 
% duration_simulation = 180;                  % duration of the simulation in minutes
% 
% behaviour=true;                     % whether a tram can skip the station if the tram is delayed and
%                                     % another tram is close behind
%                                     
% peoplerate=30;                       % Maximum number of people arriving at a random station for each instant of time
%                                     
% display=false;                      % whether to display the simulation instant-by-instant visually
            


% Matrix "a" contains all the information necessary for the simulation. The
% length of each row is the length of the track. Each row contains a
% certain type of information.

% The first row contains the positions of the trams and the number of
% passengers in each tram. A non-zero value indicates the presence of a
% tram in that cell. The value of that cell minus 1 equals the number of
% passengers of the tram, i.e. a value of 1 indicates an empty tram.

% The second row contains the positions of the stations. A value of 1
% indicates a station at that cell.

% The third row contains the number of people at a station who are waiting
% to board. It is a property of each station, hence non-zero entries in this
% row are located at the non-zero entries in the second row.

% The fourth row contains the number of people who will be getting off the
% tram. It is a property of each tram, hence the non-zero entries in this
% row follow the positions and movements of the trams in the first row.

% The fifth row is empty.

% The sixth row contains the "delay counter" of a tram. It is a property of
% each tram, hence the non-zero entries in this row follow the positions
% and movements of the trams in the first row. Essentially, it represents
% the number of time instants a tram has taken to move to the current
% location, if it had started from the first cell, i.e. a(1,1), initially.

% The seventh row contains the "station time". It is a property of each
% station, hence the non-zero entries in this row are located at the
% non-zero entries in the second row. It represents the time instant at
% which the next departure from this station should take place. Comparing
% with the values in the sixth row, the delays of the trams can be
% computed.

% The eighth row contains the "accumulated delay". It is a property of each
% tram, hence the non-zero entries in this row follow the positions and
% movements of the trams in the first row. It represents the total delay of
% each tram. If a tram departs from a station later than it should (from
% the information from the sixth and the seventh row), the delay is counted
% into this row. Thus in an ideal equal headway scenario, the trams should
% have zero entries in this row. In the simulation, there are mechanisms to
% reduce the accumulated delay.

%we assume that the vehicle can move of a cell for each instant of time
%it's natural to assume that this instant of time is large, i.e. we can
%board (or get down) more than a person for each instant of time
%this value will be put equal to pb [People Boarding]


%% B. Declaration of constants

% Variables that will not be changed in the simulation are declared here.

ntram = length(initpostram);        % number of trams
nstat = length(posstat);            % number of stations
ntimeinstant=duration_simulation*2;  

cell1=cell(ntimeinstant,max(peoplerate));

%% C. Simulation initialization

a = zeros(8,tracklength);           % generation of the track

for i=1:length(initpostram)         % assign the trams with passengers
    a(1,initpostram(i))=inittrampass(i)+1;
end

for i=1:length(posstat)             % generation of stations
    a(2,posstat(i))=1;
end

%% C1. Generation of the initial delay counter

% It is assumed that no trams are delayed initially.

% 1. Generate the number of stations behind each tram

stationsbehind = zeros(1,ntram);

for i=1:length(initpostram)
    for j=1:length(posstat)
        if posstat(j)<initpostram(i)
            stationsbehind(i)=stationsbehind(i)+1;
        end
    end
end

% 2. Generate the initial delay counter value

initdelaycount=zeros(1,5);

for i=1:length(initpostram)
    initdelaycount(i)=initpostram(i)+(stationsbehind(i)*minwaitingtime);
end

% 3. Put the initial delay counter values into a(6,:)

for i=1:length(initpostram)
    a(6,initpostram(i))=initdelaycount(i);
end

%% C2. Generation of station time in a(7,:)

inittimestat=zeros(1,nstat);

for i=1:nstat
    inittimestat(i)=posstat(i)+(stationsbehind(i)*minwaitingtime);
    a(7,posstat(i))=inittimestat(i);
end


totalpathtime = length(a) + minwaitingtime * nstat;

%% C3. Variable initialization

% Variables used in the simulation are declared and initialized here

% Matrix "b" is for transition from the current time instant to the next
% time instant. At the beginning of the iteration of each time instant, "b"
% is identical to "a". The code will update the values in "b" according to
% different conditions, so that "b" at the end of the iteration represents
% all the changes that should be made to "a" in this time instant. The
% values in "b" will be copied to "a" so that "a" is updated and ready for
% the next iteration.

b=a;

arr=0;
bcd=0;

skiptram=false;
previous_tram_skipped=zeros(1,length(a));

round=1;    % start at first round

[leadtramtime,posleadtram]=max(a(6,:));

% in the initial condition, if the leading tram is past the last
% station

if round==1 && (posleadtram>posstat(length(posstat)) || posleadtram==posstat(length(posstat))+1)
    
    round = round + 1;      % increase the round number
    
    if posleadtram==length(a)
        if max(a(1,1:posstat(1)-1))==0
            a(7,posstat(1))=inittimestat(1)+(round-1)*totalpathtime;
        end
    elseif posleadtram<length(a)
        if max(a(1,1:posstat(1)-1))==0 && max(a(1,posleadtram+1:length(a)))==0
            a(7,posstat(1))=inittimestat(1)+(round-1)*totalpathtime;
        end
    end
    
end

if display==true
    
    a
    plotgraphics2(a,cap)                % plot the position of the bus with the number of people on board
    [distram, maxdistram, maxreldistram, stddistram] = finddistram(a)
    
end

[distram, maxdistram, maxreldistram, stddistram] = finddistram(a);

%% D. Simulation

for j=peoplerate
    
    % ntramskipped is the number of trams skipped for a specific j
    ntramskipped(j,1)=j;
    ntramskipped(j,2)=0;
    
    peoplearriving=j;
    
    for t=1:ntimeinstant % instant of times
        
        [leadtramtime,posleadtram]=max(a(6,:));
        
        if arr>0
            arr=arr-1;
            
        elseif arr==0
            % generate a passenger
            posgen=random('Discrete Uniform',nstat);
            b(3,posstat(posgen))=a(3,posstat(posgen))+random('Poisson',peoplearriving);
            
            % generate a new arr
            arr=1; %random('Poisson',3);
            
        end
        
        %% Scanning of all cells
        
        for i=1:length(a)

            skiptram=false;
            
            if a(6,i)>0
                b(6,i)=a(6,i)+1;
            end
            
            %% Case I: There is no tram at i
            
            if a(1,i)==0
                continue            % exit the current i
            end
            
            %% Case II: There are two trams at i and i+1, the tram at i has to wait

            if i==length(a)
                if a(1,i)>0 && a(1,1)>0
                    b(1,i)=a(1,i);
                    continue
                end
            elseif i~=length(a)
                if a(1,i)>0 && a(1,i+1)>0
                    b(1,i)=a(1,i);
                    continue
                end
            end

            if i==posleadtram       % the position of i is at the leading tram
                
                % find the next station of the leading tram
                
                if (posleadtram>posstat(nstat) && posleadtram<=length(a)) || (posleadtram>=1 && posleadtram<posstat(1))
                    leadtram_nextstat=1;
                elseif posleadtram<posstat(nstat) && posleadtram>posstat(1)
                    leadtram_nextstat=find(posleadtram<posstat,1);
                end
                
                if posleadtram==length(a)
                    if max(a(1,1:posstat(1)))==0
                        b(7,posstat(leadtram_nextstat))=inittimestat(leadtram_nextstat)+(round-1)*totalpathtime;
                    end
                elseif posleadtram<length(a)
                    if max(a(1,posleadtram+1:posstat(leadtram_nextstat)))==0
                        b(7,posstat(leadtram_nextstat))=inittimestat(leadtram_nextstat)+(round-1)*totalpathtime;
                    end
                end
                
            end
            
            %% Case III: There is a tram at i and the tram can move at this step

            % If the tram is at a station, and it is the scheduled time to
            % depart or the tram is already delayed, the tram can move
            % (i.e. depart from the station) if any of the following
            % conditions is satisfied:
            %
            %   1.  The tram satisfies the conditions to skip the station
            %       if passenger behaviour is enabled.
            %   2.  There are no people to board or get off.
            %   3.  The tram is full and there are no people to get off.
            
            % If the tram is not at a station, the tram can move. The case
            % of presence of another tram in front so the current tram
            % cannot move has already be dealt with in Case II.
            
            
            
            % if passenger behaviour is enabled and the tram is at a
            % station, determine if the tram will skip the station
            
            if behaviour==true && (a(1,i)>0 && a(2,i)>0)

                    dis_from_tram_behind = find_dis_from_tram_behind(a,i);
                    
                    % IF the tram is delayed when it arrives at the station
                    % AND there are no people to get off AND there is a
                    % tram behind arriving in 5 instants (distance of the
                    % tram from the tram behind <= 4) AND the previous tram
                    % at this station was not skipped
                    
                    if a(8,i)>0 && a(4,i)==0 && dis_from_tram_behind<=4 && previous_tram_skipped(i)==0
                        skiptram=true;                      % this tram will be skipped
                        ntramskipped(j,2)=ntramskipped(j,2)+1;
                        previous_tram_skipped(i)=1;         % make a record that one tram is already skipped at this station - cannot skip next tram
                    end 

            end
            
            % IF (the tram is at a station) AND (it is the scheduled time
            % to leave or delayed) AND (this tram will skip the station OR
            % (there are no people to board or get off) OR (the tram is
            % full AND there are no people to get off))
            
            if (a(1,i)>0 && a(2,i)>0) && (a(6,i)>=a(7,i)) && ((skiptram && a(4,i)==0)|| (a(3,i)==0 && a(4,i)==0) || (a(1,i)==cap+1 && a(4,i)==0))
                
                % if the tram leaving this station is not due to skipping,
                % then reset previous_tram_skipped(i) - so that the next
                % tram can be skipped
                
                if skiptram==false
                    previous_tram_skipped(i)=0;
                end
                
                if i==length(a)         % return to the leftmost position if the tram is at the rightmost end
                    b(1,1)=a(1,i);
                    b(1,i)=0;
                    b(4,1)=random('Discrete Uniform',a(1,i))-1;     % generate the number of people to get off
                    %                 b(5,1)=a(5,i);
                    b(6,1)=b(6,i);
                    b(6,i)=0;
                    if a(6,i)>a(7,i)
                        b(8,1)=a(8,i)+(a(8,i)-a(7,i));
                        b(8,i)=0;
                    end
                    
                elseif i~=length(a)
                    b(1,i+1)=a(1,i);    % move the tram to the next cell
                    b(1,i)=0;
                    b(4,i+1)=random('Discrete Uniform',a(1,i))-1;   % generate the number of people to get off
                    
                    b(6,i+1)=b(6,i);
                    b(6,i)=0;
                    if a(6,i)>a(7,i)
                        b(8,i+1)=(a(6,i)-a(7,i));
                        b(8,i)=0;
                    else
                        b(8,i)=0;
                        b(8,i+1)=0;
                    end
                    %                 if b(8,i+1)<minwaitingtime;
                    %                     b(5,i+1)=minwaitingtime-b(8,i+1);
                    %                 else
                    %                     b(5,i+1)=0;
                    %                 end
                end
                
                if i==posleadtram                                   % the position of i is at the leading tram
                    
                    leadtram_departstat=find(posstat==i);           % leadtram_departstat is the number of the station
                                                                    % the leading tram is going to depart from
                    
                    if leadtram_departstat==nstat                   % if the leading tram is departing from the last station
                        leadtram_nextstat=1;                        % the next station of the leading tram is the first station
                        round=round+1;                              % define the start of the next round
                    end
                    
                end

                continue
                
            end
            
            % IF the tram is not at a station
            
            if a(1,i)>0 && a(2,i)==0
                if i==length(a)         % return to the leftmost position if the tram is at the rightmost end
                    b(1,1)=a(1,i);
                    b(1,i)=0;
                    b(4,1)=a(4,i);
                    b(4,i)=0;
                    b(6,1)=b(6,i);
                    b(6,i)=0;
                    b(8,1)=a(8,i);
                    b(8,i)=0;
                    
                elseif i~=length(a)
                    b(1,i+1)=a(1,i);    % move the tram to the next cell
                    b(1,i)=0;
                    b(4,i+1)=a(4,i);    % move the number of people to get off to the next cell as well   ** DOUBLE CHECK **
                    b(4,i)=0;
                    b(6,i+1)=b(6,i);
                    b(6,i)=0;
                    b(8,i+1)=a(8,i);
                    b(8,i)=0;
                end
                continue
                
            end
            
            %% Case IV: There is a tram and a station at i and there are people who want to get off

            if a(1,i)>0 && a(2,i)>0 && a(4,i)>0
                
                if a(4,i)>pb                % one time instant is not enough to unload the passengers
                    b(1,i)=a(1,i)-pb;       % pb passengers get off
                    b(4,i)=a(4,i)-pb;
                    continue
                    
                elseif a(4,i)<=pb           % one time instant is enough to unload the passengers
                    b(1,i)=a(1,i)-a(4,i);   % all the people who want to get off get off
                    bcd=pb-a(4,i);          % [Boarding Capacity Difference] we still can move people for this instant of time (boarding)
                    b(4,i)=0;
                    
                    % boarding (allowed by bcd) begins after the people have
                    % left the vehicle, if there are people who want to board
                    
                    % IF there are people who want to board AND the tram
                    % capacity is enough to board bcd passengers
                    
                    if a(3,i)>0 && b(1,i)+bcd<=cap+1
                        
                        if bcd<a(3,i)
                            b(3,i)=a(3,i)-bcd;
                            b(1,i)=b(1,i)+bcd;
                            bcd=0;
                            
                        elseif bcd>a(3,i)
                            b(3,i)=0;
                            b(1,i)=b(1,i)+a(3,i);
                            bcd=0;
                        end
                        
                        % IF there are people who want to board AND the tram
                        % capacity is not enough to board bcd passengers
                        
                    elseif a(3,i)>0 && b(1,i)+bcd>cap+1
                        if (cap+1-b(1,i))<a(3,i)
                            b(3,i)=a(3,i)-(cap+1-b(1,i));
                            b(1,i)=cap+1;
                        else
                            b(3,i)=0;
                            b(1,i)=b(1,i)+a(3,i);
                        end
                        
                    elseif a(3,i)==0
                        % if there are no people who want to board, end the
                        % current iteration and go to the next i
                        continue
                        
                    end
                    
                end
                
            end
            
            %% Case V: There is a tram and a station at i. There are no people who want to get off but there are people who want to board.

            % IF (the tram is at a station) AND there are people who want to
            % board AND there are no people who want to get off.
            
            if (a(1,i)>0 && a(2,i)>0) && a(3,i)>0 && a(4,i)==0
                
                % IF the tram capacity is enough to board pb passengers
                
                if (cap+1)-a(1,i)>=pb
                    
                    if a(3,i)>pb                % one time instant is not enough to board the passengers
                        b(1,i)=a(1,i)+pb;
                        b(3,i)=a(3,i)-pb;
                        continue
                        
                    elseif a(3,i)<=pb           % one time instant is enough to board the passengers
                        b(1,i)=a(1,i)+a(3,i);
                        b(3,i)=0;
                    end
                    
                    % IF the tram capacity is not enough to board pb passengers
                    
                elseif (cap+1)-a(1,i)<pb
                    if a(3,i)>=(cap+1-a(1,i))
                        b(3,i)=a(3,i)-(cap+1-a(1,i));
                        b(1,i)=cap+1;
                        
                    else
                        b(3,i)=0;
                        b(1,i)=cap+1;
                    end
                end
                
            end
            
        end
        
        

        a=b;

        if display==true
            
%             a
            pause(0.8)
            plotgraphics2(a,cap)
%             [distram, maxdistram, maxreldistram, stddistram] = finddistram(a);
            
        end
        
        [distram, maxdistram, maxreldistram, stddistram] = finddistram(a);
        
        dist_histogram(t,1)=maxreldistram;
        maxdelay(t,1)=max(a(8,:));
        cell1{t,j}=a;
    end
    
    % figure()
    % histogram(dist_histogram)
    % figure()
    % histogram(maxdelay)
    
%     figure()
%     plot(maxdelay)
%     grid on
%     xlabel('Time instant')
%     ylabel('Max Delay')
%     title(sprintf('Max delay (peoplearriving = %d)',peoplearriving))
    
    avgpeoplewaiting(j,1)=j;
    avgpeoplewaiting(j,2)=sum(a(3,:))/nstat;
    
    meandelay(j,1)=j;
    meandelay(j,2)=sum(a(8,:))/ntram;
     
end
end




function [distram, maxdistram, maxreldistram, stddistram] = finddistram(a)

% disttram is a vector containing the distances between tram 1 and tram 2,
% tram 2 and tram 3, tram 3 and tram 4, etc. The distance is defined as the
% number of empty cells between two trams. For example, two trams X are
% separated by 4 spaces in ---X----X--- rather than 5. The distance between
% the two trams in this case is 4. The first entry of disttram is the
% distance between the leftmost tram and its next tram on the right. The
% last entry of disttram is the distance between the rightmost tram and the
% leftmost tram (since it is a circular track).


postram=find(a(1,:));

% preallocate vector
distram=zeros(1,length(postram));

for i=1:length(postram)
    if i==length(postram)
        % compute the last entry of disttram (the distance between the
        % rightmost tram and the leftmost tram)
        distram(end)=(length(a)-postram(end))+(postram(1)-1);       
    
    elseif i~=length(postram)
        % compute the other entries of disttram
        distram(i)=postram(i+1)-postram(i)-1;       
    
    end
end

maxdistram=max(distram);

maxreldistram=maxdistram/(length(a)-length(find(a(1,:))))*length(find(a(1,:)));

stddistram=std(distram);
end


function dis_from_tram_behind = find_dis_from_tram_behind(a,i)

% postram is a vector containing the positions of all trams
postram = find(a(1,:));

% tramnumber is the position of the tram relative to the other trams.
% For example, if A-E indicates five trams in
% ----E----A------B------C----D----, A is the second tram and has a
% tramnumber of 2
tramnumber = find(postram==i);

if tramnumber==1
    dis_from_tram_behind=(length(a)-postram(end))+(postram(tramnumber)-1);
elseif tramnumber~=1
    dis_from_tram_behind=postram(tramnumber)-postram(tramnumber-1);
end
end

function [] = plotgraphics2(a,cap)
%creates a plot visualizing the dynamic of trams and stations

positions1 = [find(a(1,:))] ;
positions2 = [find(a(2,:))] ;
p1=2*ones(length(positions1),1)';
p2=ones(length(positions2),1)';
c1=a(1,positions1);
c2=a(3,positions2)+1; %not to have a zero
c3=[1:1:cap+1];


figure(1)
scatter(c3,zeros(length(c3),1),1,c3)
hold on
box on
scatter(positions1,p1,10*c1,c1,'filled')
scatter(positions2,p2,20*c2,'filled')
hold off
c=colorbar;
c.Limits = [0 cap];
c.Label.String = 'Number of people';
c.Ticks= [1:5:cap];
ax.FontSize = 20;
ax = gca; % current axes
ax.FontSize = 20;
ax.YLim = [0.5 2.5];
ax.XLim =[0 tracklength+1];
ax.YTickLabel = {[],'Stations',[],'Trams',[]};
title('Trams dynamic')
set(gca,'xtick',[]);


pause(0.2)
end