len([],Res):- Res is 0.
len([H|T],Res):-len(T,L), Res is L +1.

init:- 
	length(ROUND,1),
	assert(round(ROUND)).

startNewRound:-
	round(R),
	len(R,N),
	(N==4->(writeln('End Of Game.'),abort);
	print('Round '),
	print(N),
	writeln(''),
	append(R,[_],NR),
	abolish(round/1),
	assert(round(NR)),
	length(TurnCounter,1),
	assert(turn(TurnCounter))).

checkTurn:-
	turn(T),
	len(T,N),
	(N==4->(writeln('End of Round'),abolish(turn/1),startNewRound);
	print('Turn '),
	print(N),
	append(T,[_],NT),
	abolish(turn/1),
	assert(turn(NT))).
	
	
