/*****************************************FINALLY HERE ARE OUR FACTS*******************************************/
keyword([teamsize,numOfTeam,fieldtype,equipment,gamemode]).    %This is really just for clean coding purpose
/**dependency:-
	all the facts below this predicate,
	has/2.
**/
%The property arg of game (the 2nd one) must follow the order stated in keyword predicate%
game(archery, [1,many,field,bow,score]).
game(badminton, [2,2,court,racquet,score]).
game(basketball, [5,2,court,ball,score]).
game(volleyball, [6,2,court,ball,score]).
game(boxing, [1,2,ring,gloves, knockout]).   		%5th game
game(canoeing, [1,many, water, paddle,timed]).
game(cycling, [1,many,track,bicycle,timed]).
game(fencing, [1,2,ring,sword,knockout]).
game(hockey, [6,2,court,stick,score]).
game(handball, [7,2,court,ball,score]).		%10th game
game(judo, [1,2,ring,none,knockout]).
game(rugby, [15,2,field,ball,score]).
game(soccer, [11,2,field,ball,score]).
game(tabletennis, [1,2,table, bat,score]).
game(tennis, [1,2,field,racquet,score]).		%15th game
game(waterpolo, [7,2, pool, ball, score]).
game(weightlifting, [1,many, stage,barbell,score]).