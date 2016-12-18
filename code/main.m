%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Modeling and Simulating Social Systems with MATLAB
% Autumn Semester 2016
% ETH Zurich
% Maicol FABBRI, Cheuk Wing Edmond LAM

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
clear all
close all

%

%% A. Inputs for the simulation

tracklength = 50;                   % length of the track

initpostram = [ 10 20 30 40 50];     % initial position of trams
inittrampass = [30 30 30 30 30];    % initial number of tram passengers
posstat = [5 15 25 35 45];          % position of the stations

minwaitingtime=3;                   % if a tram is not delayed, the minimum
                                    % number of waiting time instants of
                                    % the tram at a station

pb=20;                              % movement limit
cap=60;                             % tram capacity

duration_simulation = 180;          % duration of the simulation in minutes
ntimeinstant=duration_simulation*2;

% behaviour=true;                     % whether a tram can skip the station if the tram is delayed and
% another tram is close behind

peoplerate=1:40;                    % Maximum number of people arriving at a random station for each instant of time

display=false;                      % whether to display the simulation instant-by-instant visually

%% average results calculation

nsimulation=50;                     % number of simulations - the results are averaged over the results from each simulation
                                    % from experience, it is recommended to run at least 50

pw1_sum=0;
td1_sum=0;
ts1_sum=0;
pw2_sum=0;
td2_sum=0;
ts2_sum=0;

% for i=1:nsimulation
% This for loop is suitable for parallel computing so parfor is used to speed up the simulation.
% If error occurs, switch back to the regular for loop

parfor i=1:nsimulation 
    
    %% Simulation without behaviour
    
    behaviour=false;
    
    [pw1,td1,ts1,~]=simulation( tracklength,initpostram,inittrampass,posstat,minwaitingtime,pb,cap,duration_simulation,behaviour,peoplerate,display);
    
    pw1_sum=pw1_sum+pw1;
    td1_sum=td1_sum+td1;
    ts1_sum=ts1_sum+ts1;
    
    
    %% Simulation with behaviour
    
    behaviour=true;
    
    [pw2,td2,ts2,~]=simulation( tracklength,initpostram,inittrampass,posstat,minwaitingtime,pb,cap,duration_simulation,behaviour,peoplerate,display);
    
    pw2_sum=pw2_sum+pw2;
    td2_sum=td2_sum+td2;
    ts2_sum=ts2_sum+ts2;
    
end

%% average results calculation

pw1=pw1_sum/nsimulation;
td1=td1_sum/nsimulation;
ts1=ts1_sum/nsimulation;

pw2=pw2_sum/nsimulation;
td2=td2_sum/nsimulation;
ts2=ts2_sum/nsimulation;

%% Analysis of the results


figure()
hold on
plot(pw1(:,1),pw1(:,2),'linewidth',3)
plot(pw2(:,1),pw2(:,2),'linewidth',3)
grid on
box on
xlabel('Number of people arriving at stations per instant of time (on average)')
ylabel('People waiting at the stations')
title(sprintf('Average number of peole waiting at the stations after %d instants (%d minutes)',ntimeinstant,duration_simulation))
legend('Without passenger behaviour','With passenger behaviour')
ax = gca; % current axes
ax.FontSize = 20;

figure()
hold on
plot(td1(:,1),td1(:,2),'linewidth',3)
plot(td2(:,1),td2(:,2),'linewidth',3)
grid on
box on
xlabel('Number of people arriving at stations per instant of time (on average)')
ylabel('Mean delay (time instants)')
title(sprintf('Mean delay of trams after %d instants (%d minutes)',ntimeinstant,duration_simulation))
legend('Without passenger behaviour','With passenger behaviour')
ax = gca; % current axes
ax.FontSize = 20;

figure()
hold on
scatter(ts1(:,1),ts1(:,2),100,'filled')
scatter(ts2(:,1),ts2(:,2),100,'filled')
ylim([0 max(ts2(:,2))+10])
grid on
box on
xlabel('Number of people arriving at stations per instant of time (on average)')
ylabel('Number of trams skipped')
title(sprintf('Number of skipping occurred after %d instants (%d minutes)',ntimeinstant,duration_simulation))
legend('Without passenger behaviour','With passenger behaviour')
ax = gca; % current axes
ax.FontSize = 20;

%% video recording



% recvideo=true;

recvideo=false;


if recvideo
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SET SETTINGS FOR THE VIDEO RECORDING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


duration_simulation = 120;          % duration of the simulation in minutes
ntimeinstant=duration_simulation*2;

peoplerate=25:25;                    % Maximum number of people arriving at a random station for each instant of time

display=false; 

behaviour=false;
    
    
h=figure();

vidObj=VideoWriter('video.avi');
open(vidObj);

[~,~,~,cell1]=simulation( tracklength,initpostram,inittrampass,posstat,minwaitingtime,pb,cap,duration_simulation,behaviour,peoplerate,display);
% [~,~,~,cell1]=simulation( tracklength,initpostram,inittrampass,posstat,minwaitingtime,pb,cap,duration_simulation,behaviour,peoplerate,display);

rep=8; %since video are 30fps, repeate the same frame (rep times) makes the visualization more comfortable

for i=220*rep:size(cell1,1)*rep   %we are interested in a window of time
    a=cell1{ceil(i/rep),25};       %cell1{ceil(i/rep),pr} pr is the people rate we want to record
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% plot development
    
    
positions1 = [find(a(1,:))] ;
positions2 = [find(a(2,:))] ;
p1=2*ones(length(positions1),1)';
p2=ones(length(positions2),1)';
c1=a(1,positions1);
c2=a(3,positions2)+1; %not to have a zero
c3=[1:1:cap+1];



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
ax.XLim =[0 51];
ax.YTickLabel = {[],'Stations',[],'Trams',[]};
title('Trams dynamic')
set(gca,'xtick',[]);

    
    currFrame=getframe(h);
    writeVideo(vidObj, currFrame);
end

close(vidObj);

end