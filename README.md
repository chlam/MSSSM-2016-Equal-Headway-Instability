# MATLAB Fall 2016 – Research Plan

> * Group Name: (be creative!)
> * Group participants names: Maicol FABBRI, Cheuk Wing Edmond LAM
> * Project Title: Train Platform Dynamics

## General Introduction

Nowadays, public transport is a crucial element of all the big cities and not. In this category, one of the most important is without any doubts the train.

Our group aims to simulate the dynamics of a train platform. In particular, we are going to focus in the moment of a train arrival, when people alight the train and other people board. When a platform is really crowded or not sufficiently big, this can lead to unpleasant congestions, since different groups of people are moving in opposite directions (one towards the exits on the platform, the other to the train doors). The main question we want to investigate is which one is the relation between the density of people on the platform and the formation of congestions/bottlenecks.

(States your motivation clearly: why is it important / interesting to solve this problem?)
(Add real-world examples, if any)
(Put the problem into a historical context, from what does it originate? Are there already some proposed solutions?)

## The Model

The platform is assumed to be periodic and thus can be divided into several identical segments. A simulation MATLAB code will be written for one of the segments. This division simplifies the problem and allows a lower computational cost.

As a preliminary setting, 4 coaches will park at a platform segment and each coach will have 2 doors. A platform segment will consist of two set of staircases. The passengers waiting on the platform (i.e. boarding passengers) will be randomly distributed on the platform. They react when the train arrives. The exact dimensions of the coaches, train doors, and the staircases are to be set at a later stage.

The basic principle of the simulation is to divide the platform segment into a two-dimensional grid of cells. A passenger, either boarding or alighting, will occupy one cell. The size of each cell is scaled such that it matches a predetermined limit of packing of people. For example, a person could be predetermined to occupy at least a 0.5m x 0.5m space, so that for a train door of width, say, 1 m, will allow 2 people who are next to each other right in front of the door. In this case, the size of each cell will be 0.5m x 0.5m, and each train door will have 2 cells across it. The exact value of maximum density will be determined at a later stage.

The two-dimensional grid of cells will be represented by a matrix in MATLAB. Cells which are occupied by a passenger will have a non-zero value in the corresponding entry of the matrix. Cells which are not occupied will have a zero value. The code iterates the matrix through a number of time steps, until all passengers have reached their destination and left the domain, either by leaving through the stairs or boarding the train. It is noted that in this study the relationship between the total number of time steps and several selected parameters, namely platform width and passenger density, is investigated. With this relationship, the total number of time steps can be minimized by adjusting the parameters. Although the total time required for this process of boarding/alighting is proportional to the total number of time steps required, the exact time required in such a process is not to be determined.

The MATLAB code iterates the matrix through the time steps. During each iteration, a set of rules will determine the position of the passengers at the next time step according to their current positions. In actual implementation, the code will first read the positions of the passengers, and then define a “change” matrix to be applied to the current platform matrix according to the rules. After performing the arithmetic, the positions are updated. The procedure is then repeated.


There will be three major types of rules which will determine the entries in the change matrix, thus the movement of passengers. The first is a pseudo-gravitational force which points from the destination of the passengers to the passengers. This will control the main direction the passengers intend to go if there are no other obstacles. The second type controls the speed of the movement. The speed of movement depends on the presence of obstacles within a certain radius of the passenger. The third type is the decision when a conflict occurs. This include 1) when two passengers are moving to the same cell in the next time step; and that 2) passengers want to keep a certain distance from each other when available. Other rules may be added at a later stage.

It is worth noting that various attributes can be set to individual passengers. If time is sufficient, it can be implemented that some passengers carry luggages so that they occupy more than 1 grid cell and they move slower than others. Such luggage-carrying passengers can be set as randomly distributed among all passengers.

(Define dependent and independent variables you want to study. Say how you want to measure them.) (Why is your model a good abtraction of the problem you want to study?) (Are you capturing all the relevant aspects of the problem?)


## Fundamental Questions

This study will focus on the situation right after a train arrives at a platform, when all of the onboard passengers alight and the passengers of the next train, who are already on the platform, try to board the train. The platform will be the simulation domain. The main objective is to minimize the total time T_tot for the entire process to complete, i.e. all onboard passengers have exited the domain through the exits (e.g. stairs) on the platform and that all passengers for the next train have boarded the train.

1. What is the relationship between the total time T_tot and the platform width? Is there a critical width such that T_tot in-/decreases significantly?
2. What is the relationship between the total time T_tot and the density of the passengers on the platform waiting for the next train? Is there a critical density such that T_tot in-/decreases significantly?
3. Is it possible to describe the total time T_tot as a function of width of the platform and density of the people?

Further questions, if the time is enough, could be:
1. What happen if the people waiting for the train are not randomly distributed?
2. Is the optimum way to sort the waiting people to minimize the time?

(At the end of the project you want to find the answer to these questions)
(Formulate a few, clear questions. Articulate them in sub-questions, from the more general to the more specific. )


## Expected Results

It is expected that a larger width of the platform and/or a lower density of people on the platform will decrease the total train alighting and boarding time. However, it is expected that the relationship will not be linear and there is an optimal setting with the lowest total time. Increasing the width of the platform indefinitely, for example, will increase the average walking distance of the passengers.

(What are the answers to the above questions that you expect to find before starting your research?)


## References 

The inspiration for this study comes from a previous project as well on train boarding:

Hänni Dominic, Manser Patrick, Zoller Stefan. (2012). Pedestrian dynamics - Train platform dynamics. Retrieved from https://github.com/manserpa/pedestrian_dynamics_BlueMen

(Add the bibliographic references you intend to use)
(Explain possible extension to the above models)
(Code / Projects Reports of the previous year)


## Research Methods

This study employs an agent-based model such that each person is an agent and they interact with each other. In actual implementation, the platform is modelled as a grid consisting of a sufficient number of cells. These cells will interact with each other.

(Cellular Automata, Agent-Based Model, Continuous Modeling...) (If you are not sure here: 1. Consult your colleagues, 2. ask the teachers, 3. remember that you can change it afterwards)


## Other

(mention datasets you are going to use)
