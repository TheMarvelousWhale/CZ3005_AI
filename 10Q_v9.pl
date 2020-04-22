:- style_check(-singleton).   %remove singleton variable warnings in the helper function.
:-['KB_facts.pl'].


/**there was complication with abolish and assert in the first vs subsequent rounds things, let's just do this although it is not clean**/
chosen(nothing).
property(nothing).
turn(0).

/**************************************************Helper function******************************************************/
/**len is used to find len of a list, we use it as a counter**/
len([],Res):- Res is 0.
len([H|T],Res):-len(T,L), Res is L +1.


printMenu:-
/*
	This is to print out the instruction for the user
*/
	writeln('Welcome to 10 Questions! - A game built on Prolog.'),
	writeln('\n'),
	writeln('In this game, your role is a Questioner and the program acts as a Answerer.'),
	writeln('The Answerer has come up with a Summer Olympic Game. Your job is to find out which game it is within 10 questions.'),
	writeln('You are to use Prolog queries to ask the questions. The queries available:'),
	writeln('\t1. has(value), for e.g: has(ball), has(12), has(racquet), etc. We allow ambiguity so as to give you more room'),
	writeln('\t2. has(keyword,value), for e.g: has(equipment, ball), has(fieldtype,court). There is supported keyword list you will find out if you use the wrong keyword. \'many\' can be used as a value if you need to.'),
	writeln('\t3. is(X), for e.g: is(Tennis). This is the only decision query to be made. It also counts as a turn.\n'),
	writeln('Do note that we lowercase the game name - tabletennis, waterpolo. Some game has double version, but for ease we don\'t include double as game here for simplicity. There are total of 17 games in the database in order to ensure each game is uniquely identifiable by its 5 attributes.'),
	writeln('There will be 5 rounds in total.'),
	writeln('All the best~\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n').

/********************************************************END OF HELPER SECTION****************************************/








/*********************************GAME MECHANICS SECTION****************************************************/
/***************These rules define the turn, round, initialization and clean up after each round of the game******************/

init:- 
/** 
	Initialize round to a list of 0 length
	Collect all the game_name from KB_facts.pl into a list
	Assert this list
	Start the first round
**/

	/**Set game counter by making a list of length 1, we will increment the list slowly to indicate the round**/
	length(ROUND,1),
	assert(round(ROUND)),

	/**find all games in KB using setof/3, add this into KB for subsequent usage of choosing a random game each round**/		
	setof(Game, X^game(Game,X),GameList),
	assert(gameList(GameList)),
	printMenu,
	startNewRound.

restart:-
/**
	Start the game after 5 rounds
**/
	abolish(round/1),
	init.

startNewRound:-
/*
	This function is the core of many other, and it does many things:
	1. Increment the round
	2. Reinitialize list counter to 1
	3. Choose a random game for this round. Make sure it is not any game already chosen previously by deleting off previous game off the gameList/1 
	4. Abolish the old chosen/1 and property/1, update KB with new values to these predicate using assert
*/

	/*****1. increment the round. We print before increment, so init/0 can initialize round/1 to list of length 1 *****/
	round(R),
	len(R,N),
			%%%If it is 6,i.e we have played 5 games, then abort%%%
	(N==6->(writeln('End Of Game. If you want to play somemore, type restart.'),abort);
			%%%Else, we do the necessary initialization for this round, and some beauty printing%%%
	writeln(''),
	write('~~~~~~~~~~~~~~~~~~~~   Round '),	write(N), 	writeln('   ~~~~~~~~~~~~~~~~~~~~'),
	append(R,[_],NR),   %increase the round counter by append it with some random var
	abolish(round/1),	%do an abolish of old predicate
	assert(round(NR)),  %assert the new value into the KB
	
	/*****2. Reinitialize the list counter to 1*****/
	abolish(turn/1),
	length(TurnCounter,1),
	assert(	turn(TurnCounter)),
	
	/*****3. Handle the game choosing*****/
	%%%remove the previously chosen game from gameList, then choose a new game , to make sure each round is a diff game%%%
	gameList(L),
	chosen(X),
	(X\=nothing->(delete(L,X,NL),abolish(gameList/1),assert(gameList(NL)));gameList(NL)),        
										
	
	random_member(ChosenGame,NL),
	
	/**4. We reset the game (chosen/1), its properties (property/1)**/
	abolish(chosen/1),
	abolish(property/1),
	assert(chosen(ChosenGame)),
	game(ChosenGame,Prop),
	assert(property(Prop)),
	writeln('We have chosen a game. Make your guess!')
	).



checkTurn:-
/**
	We need to keep check of how many turns has passed. 
	It is assumed that if an user wins before this rule is matched, then a new round will start
	Thus this rule will only check and fail at turn == 10,
	We also assume this rule is evoked after the Q-Handler rule has been evoked and completed, so we do post conditional checking only
**/
	turn(T),
	len(T,N),
	chosen(X),
	(N==10->(writeln('You ran out of turns. You lost.'),write('The chosen game was: '),writeln(X),writeln('End of Round'),startNewRound);  		%%If it is 10 rounds, end%%
	
		%%Else, pritn something and increment the counter, same as how we do rounds%%
	write('Turn '),
	write(N),
	append(T,[_],NT),
	abolish(turn/1),
	assert(turn(NT))).
/************************************END OF MECHANICS SECTION*********************************************/






/***************************************Q-HANDLER RULES****************************************************/
/************These rules are the main query types supported and the main driver of the 10 Question game*****************/
has(X):-
/**
	check against the property of the chosen game by match it to property(L) and check for membership
	assert the response to KB via answer/1
	invoke checkTurn/0
**/

	property(L),						%%get the property of the chosen game
	member(X,L)->(writeln('YES YOU ARE RIGHT'),checkTurn);		%%check if the query key is in the chosen game
	write('No this game does not have '),write(X),writeln(' . Try something else.'),	
	checkTurn.						%%inrement turn

has(X,N):-
/**
	check against the property of the chosen game by index it to property(L) and check for equality
	assert the response to KB via answer/1
	invoke checkTurn/0
**/	
	/**get the property of the chosen game**/
	property(L),
	(
		(	
/**If they are correct, aka X is a keyword and N is the correct value - - 1st OR BRANCH**/
/**check if X is correct keyword and with that keyword, index into L and see if the value is correct**/

			(X==teamsize,nth0(0,L,Elem),Elem==N);
			(X==numOfTeam,nth0(1,L,Elem),Elem==N);
			(X==fieldtype,nth0(2,L,Elem),Elem==N);
			(X==equipment,nth0(3,L,Elem),Elem==N);
			(X==gamemode,nth0(4,L,Elem),Elem==N)
		)->(writeln('YES YOU ARE RIGHT'));

/**Or they key in the word not inside the supported list keyword([teamsize,numOfTeam,fieldtype,equipment,gameMode]) -- 2nd OR BRANCH**/
	(keyword(K),not(member(X,K))->(writeln('Supported keywords are: '),write(K),writeln('. You are still counted as wrong though.'))	);

/**Right keyword, wrong value -- 3rd OR BRANCH**/
	writeln('No this is not the case for our game.')   /*Or they are just wrong*/
	),
	
	
	/**perform a turn increment**/
	checkTurn.


is(X):- 
/**
	chosen(X) can be used as the decision rule
	assert the response to KB via answer/1
	invoke checkTurn/0 if answer wrongly, else invoke reveal
**/
	/**if they guess correctly, immediately abolish this round and startNewRound**/
	chosen(X)->(writeln('Great Job! You guessed the game!'),startNewRound); 

	
	/**perform a turn increment**/
	write("Nice try but no it is not "),write(X),writeln(". Try again."),
	checkTurn.
/***************************************************END OF Q-HANDLER RULES******************************************/


:-init.   %Start the game right after consult/1 is invoked.
