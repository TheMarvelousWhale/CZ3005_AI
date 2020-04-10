/****************Helper function********************/
/*len is used to find len of a list, we use it as a counter*/
len([],Res):- Res is 0.
len([H|T],Res):-len(T,L), Res is L +1.

/**there was complication with abolish and assert in the first vs subsequent rounds things, let's just do this although it is not clean**/
chosen(nothing).
property(nothing).
turn(0).

/** Init function, initialize round function counter, init the game of all game predicate in the KB**/
/*It is an inital wrapper for startNewRound**/
init:- 
	/***Set game counter by making a list of length 1, we will increment the list slowly to indicate the round***/
	length(ROUND,1),
	assert(round(ROUND)),
	/***find all games in KB using setof/3, add this into KB for subsequent usage of choosing a random game each round***/		
	setof(Game, X^game(Game,X),GameList),
	assert(gameList(GameList)),
	startNewRound.

startNewRound:-
	/***Every time the round starts, we reset the game (chosen/1), its properties (property/1)***/
	abolish(chosen/1),
	abolish(property/1),


	/*** Get the round number, length of list (round(R)) into N***/
	round(R),
	len(R,N),
	
	/***If it is 6,i.e we have played 5 games, then abort***/ 
	(N==6->(writeln('End Of Game.'),abort);
	/***Else, we do the necessary initialization for this round, and some beauty printing***/
	print('Round '),	print(N), 	writeln(''),
	append(R,[_],NR),   %increase the round counter by append it with some random var
	abolish(round/1),	%do an abolish of old predicate
	assert(round(NR)),  %assert the new value into the KB
	
	/***Init the new turn counter  to 1***/
	abolish(turn/1),
	length(TurnCounter,1),
	assert(turn(TurnCounter)),
	
	/**Chose a random game, and some logging, assert the game name and its property into KB**/
	gameList(L),
	random_member(ChosenGame,L),
	assert(chosen(ChosenGame))),
	writeln('We have chosen a game. Make your guess!'),
	game(ChosenGame,Prop),
	assert(property(Prop)).
	
/**We need to keep check of how many turns has passed. 
It is assumed that if an user wins before this rule is matched, then a new round will start
Thus this rule will only check and fail at turn == 10,
we also assume this rule is evoked after the parent rule has been evoked and completed, so we do post conditional checking only
**/
checkTurn:-
	turn(T),
	len(T,N),
	(N==10->(writeln('You ran out of turns. You lost. End of Round'),startNewRound);  /*If it is 10 rounds, end*/
	
	/*Else, pritn something and increment the counter, same as how we do rounds*/
	print('Turn '),
	print(N),
	append(T,[_],NT),
	abolish(turn/1),
	assert(turn(NT))).

/*****************************************FINALLY HERE ARE OUR FACTS*******************************************/
keyword([teamsize,fieldtype,equipment]).    %This is really just for clean coding purpose
/**dependency:-
	all the facts below this predicate,
	has/2.
**/
%The property arg of game (the 2nd one) must follow the order stated in keyword predicate%
game(badminton,[2,field,racket]).
game(soccer,[11,field,ball]).
game(floorball,[6,court,stick]).
game(badminton,[1,field,racket]).
game(basketboll,[5,court,ball]).

/***
Check if a game has certain property
has/1
Check against the property of the chosen game by match it to property(L) and check for membership

has/2
same thing but we match by indexing out the correct property we want to check using nth0/3
some beauty logging.
***/
has(X):-
	property(L),
	member(X,L)->(writeln('YES YOU ARE RIGHT'),checkTurn);
	writeln('NO YOU ARE WRONG'),	
	checkTurn.

has(X,N):-
	
	property(L),
	(
		(	/**If they are correct**/
			(X==teamsize,nth0(0,L,Elem),Elem==N);
			(X==fieldtype,nth0(1,L,Elem),Elem==N);
			(X==equipment,nth0(2,L,Elem),Elem==N)
		)->(writeln('YES YOU ARE RIGHT'));
	/*Or they key in the word not inside the supported list*/
	(keyword(K),not(member(X,K))->(writeln('Supported keywords are: '),print(K),writeln('You are still counted as wrong though.'))	);
	writeln('NO YOU ARE WRONG')   /*Or they are just wrong*/
	),
	checkTurn.

/**This rule is really just a chosen/1 wrapper with beatuty print and some condition matching**/
is(X):- 
	chosen(X)->(writeln('Great Job mtfker'),startNewRound);
	writeln("Nice try but No. Try again."),
	checkTurn.
