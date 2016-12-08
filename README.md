# MATLAB Fall 2016 – Research Plan

> * Group Name: (be creative!)
> * Group participants names: Maicol FABBRI, Cheuk Wing Edmond LAM
> * Project Title: Equal Headway Instability

## General Introduction

Efficient public transport is crucial to a city. An effective and punctual public transport system minimizes enormous economic costs brought by delays, and helps reduce traffic jam as citizens are more likely to switch to public transport with confidence. However, maintaining such a system is not trivial. Random factors may destabilize the system, making it operate below the optimal level. This project will look into one particular issue, equal headway instability.

Equal headway instability refers to the ideal condition that vehicles (e.g. tram, bus, train) arrive at regular intervals. Maintaining equal headway is not an easy task, however. Even there is no other traffic between stations, tram or bus services may not achieve equal headway because of the random arrival of passengers. The following simple example illustrates this.

At any time instant, the number of passengers at one station (station A) may be more than another. Consequently, a tram (tram A) at station A takes longer time to load the passengers than the tram behind (tram B) loading passengers at the station before (station B). Tram A is then delayed, and the distance between tram A and tram B is reduced. When tram B arrives at station A, there are fewer passengers to load than average (because tram A has just left not long ago) and tram B finishes loading earlier than average (because there are fewer passengers to load than average). An instability is thus triggered. If the next station tram A arrives has also a larger number of passengers than average, the instability grows. This is described as platooning, which can be characterized by the reduction in distance between tram A and tram B. Note that the tram behind tram B (tram C), because tram B has finished loading and left earlier than average, has more passengers to load than average at its next station. This will create another similar tram A - tram B platoon in tram C - tram D, for example. It is as well worth noting that tram B may not be fully utilized, whereas tram A is full. This indicates inefficiency of the transport of passengers created by this instability.

Various strategies have been proposed in literature to increase the stability of the system (Gershenson & Pineda, 2009). However, the proposed strategies mostly are responsibilities of the service provider while strategies relying on the responsibility of passengers are limited. This project aims to introduce effective and applicable rules on passenger behaviour that increase the stability of the system, so that it self-stabilizes and allows for less uniformity and more randomness in the arrival of passengers. The project focuses on a typical generalized tram service system.

## Fundamental Questions

This project aims to answer the question of whether the stability of the system can be increased if passengers follow the instructions of willfully skipping a tram. The instruction is issued by the incoming tram if:

1) the incoming tram is delayed; and
2) there is another tram closely behind; and
3) the previous tram at this station was not skipped

This report will refer the case of passengers following the instructions as “passenger behaviour”.

## The Model

The model of the simulation is based on what is presented in Gershenson and Pineda (2009), with modifications.

A cyclic track is assumed and the number of trams is equal to the number of stations.

The relative scale of different parameters (e.g. size of a time instant, capacity of a tram) is of importance in the simulation. For a realistic scaling, reasonable values are taken from real-life situations. The following describes the model and the choice of several important parameters and scales.

a. Time

A time instant in the simulation is set to have a length of 30 seconds, and the total duration of the simulation is 3 hours. Therefore, the number of time instants simulated for is 360.

b. Length

The track is discretized into a number of cells. In the simulation, the “length” of a cell equals the length of a tram coach and the length of a station for simplicity. A full cycle of a tram trip has a length of 50 cells.

c. Trams

There are in total 5 trams in the system. At the beginning of the simulation, they are equally spaced across the track (i.e. they are separated by 9 cells from each other), and they are not at any stations (i.e. they are moving). Each tram has a capacity of 60 passengers, which is a realistic number of a typical urban tram coach. Initially they are set to be half-full, so that each tram has 30 passengers on board.

For simplicity, each tram has one coach only. It can be easily changed if necessary, however.

Trams have a speed of 1 cell/time instant. They are assumed to be able to accelerate to this speed in no time, that is, a tram departs a station and moves to the next cell in one time instant. If there is a tram in front, the tram stops until the next cell is empty again. In each time instant a tram can move, remain position and/or load and unload passengers.

d. Stations

Similar to trams, the 5 stations are equally spaced in the system with 9 cells separating every two stations. Stations have an infinite capacity so that there is no limit on the number of passengers waiting at the stations.

e. Passengers boarding and getting off

The addition of passengers into the system follow the Poisson distribution and occurs every time instant. In each time instant, a number of passengers is generated following the Poisson distribution with a preset mean. Then a random station from the 5 stations is chosen and the generated number of passengers are all assigned to that station in this time instant. This process repeats until the end of the simulation.

If a tram arrives at a station, passengers can get off the tram during a time instant. If there are people waiting at the station, boarding begins after every passenger who wants to get off the tram has got off. Boarding only begins if the conditions for boarding are satisfied. This is not to be detailed in this proposal. In general, passengers can board if the tram is not full. If passenger behaviour is enabled, passengers may board if the tram did not issue a “not to board” instruction. The conditions of the issuance of the instruction has been described in Section 2.

It is possible for both boarding and getting off the tram to occur in one time instant. A limit on the number of people that can board or get off the tram per tram per time instant is imposed. For example, if the limit is 20, and there are 17 passengers who want to get off the tram, then in this time instant 17 passengers will get off the tram while 3 passengers waiting at the station will board the tram (if there are 3 or more passengers waiting at the station and boarding is allowed by other conditions). The limit is termed the “movement limit”.

f. Schedule and delays

The trams in the system follow a schedule. The schedule specifies at which time instant the tram should leave the station. If a tram leaves a station at a time later than that specified by the schedule, it is delayed and the extent of the delay is recorded in the system. Whenever a tram leaves a station at a time later than that specified by the schedule, the extent of the delay is recorded and accumulated as a property of that specific tram, and is termed the “accumulated delay”. At the beginning of the simulation, the accumulated delay for all trams is zero.

A realistic schedule has to be set so that trams mostly depart on time for an average passenger load. To achieve this, each tram, after arriving at a station, has to stay for a minimum number of time instants before it can depart, even if there are no passengers who want to get off the tram and there are no passengers at the station who want to board the tram. This minimum number of time instants is set to be 3, which equals 1.5 minutes, and is termed the “minimum waiting time”. In setting the schedule, a tram is said to be on time if the number of time instants the tram takes from one departure at a station to the next departure at the next station equals the number of time instants a tram should take to travel from one station to the next station plus the minimum waiting time. For example, every two stations are separated by 9 cells. Thus it takes a tram 10 time instants to travel from one station to the next (speed = 1 cell/instant). Assuming the minimum waiting time of 3 time instants can accommodate the passenger load (passengers can complete boarding and getting off in 3 time instants), the tram should leave this station 10 + 3 = 13 instants after the departure of the previous station. It is worth noting that, for a low passenger load, maintaining a minimum waiting time optimal for an average load decreases the efficiency of the system. Yet, maintaining a minimum waiting time optimal for an average load when there is a high passenger load inevitably creates delays. The search for an optimal minimum waiting time is not the main focus of this project.

g. Implementation of the model

The implementation of the model in MATLAB is straightforward. A “current” matrix is defined which contains the current status of the system, e.g. positions of the trams, number of passengers onboard each tram and waiting at the stations, delays of the trams, etc. During each time instant iteration, a series of commands are computed to define a “transition” matrix. The “transition” matrix is of the same structure as the “current” matrix, but the information it contains represents the status of the system at the next time instant. At the end of each time instant iteration, the information in the “transition” matrix is simply copied to the “current” matrix.


## Expected Results

It is expected that the system will become more stable if passengers follow the instructions to skip a tram under the correct conditions. Equal headway will be maintained for less uniformity (higher randomness) in the arrival of passengers at different stations. However, it is possible that the number of passengers waiting at the stations may increase as from time to time they may have to wait for the next tram.


## References 

Gershenson, C., & Pineda, L. A. (2009). Why Does Public Transport Not Arrive on Time? The Pervasiveness of Equal Headway Instability. PLoS ONE, 4(10), e7292. http://doi.org/10.1371/journal.pone.0007292


## Research Methods

The MATLAB code will generate two parameters for comparison between the two scenarios, namely, with and without passenger behaviour.

The values for comparison include:
1) the average number of people waiting at the stations at the end of the simulation; and
2) the mean delay of trams at the end of the simulation

A number of simulations will be carried out with different mean values for the Poisson distribution that the arrival of passengers follow. It is expected to give insights to how the passenger behaviour strategy reacts to an increasing passenger load, compared to that without passenger behaviour strategy.


## Other

