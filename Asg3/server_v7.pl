:-debug.
:- style_check(-singleton).   %remove singleton variable warnings in the helper function.


:- use_module(library(http/thread_httpd)).	%the 4 main server libraries
:- use_module(library(http/http_dispatch)).	%
:- use_module(library(http/html_write)).	%
:- use_module(library(http/http_client)).	
:- use_module(library(http/http_error)).	%for error
:- use_module(library(http/http_parameters)).   %extract POST parameteers

:-['KB_facts.pl'].				%retrieve all the facts from this file
:-['html_form_v3.pl'].				%retrieve all the html from this file


answer('').				%These are empty place holder, so abolish/1 can work on all iteration
chosen(nothing).				%without having to implement a condition check using current_predicate/1
property(nothing).				%That asides, answer/1 stores the true/false value of previous query
					%chosen/1 stores the current game, property/1 stores its property





/**************************************SERVER SECTION***************************************************/
/************These rules pertains mainly on how to server the API between the core of the program to the web**********/

server(Port) :-					%starting server
	gameinit,					%%might as well do some initiliazation (init/0) rule in CLI ver
	http_server(http_dispatch, [port(Port)]).	%at the sport specified

:- http_handler(/, home_page, []).			%home_page is the rule that handles all request coming to root
:- http_handler(root(home),home_page,[]).		%just incase people like to type /home OR choose port 8080


gather(_Request):-	
/*
	Rule to handle POST request
	It does so by extracting all the parameters value and pass it through the various Q-handler rule (has/1, has/2,is/1)
	These Q-handler rules will assert answer/1 into KB
	Take the value stored inside answer/1 and pass it to the HTML rule, along with the turn and round info
*/		
	(current_predicate(pdebug/1)->abolish(pdebug/1);print('meow')),	
	http_parameters(_Request, 					%Param extraction
		[
		%%%%%%%query(Q,[optional(true), default(none)]), 
		keys(K,[optional(true), default(none)]),  
		answerhas2(AH2,[optional(true),default(none)]),
		answerhas1(AH1,[optional(true), default(none)]), 
		answeris1(AI1,[optional(true), default(none)])
		]
		),
	(
		(AH2\='none'->has(K,AH2),atom_concat('AH2 Params recv-ed:',AH2,DAH2),assert(pdebug(DAH2))           );
		(AH1\='none'->has(AH1 ),atom_concat('AH1 Params recv-ed:',AH1,DAH1),assert(pdebug(DAH1))            );
		(AI1\='none'->is(AI1 ),atom_concat('AI1 Params recv-ed:',AH1,DAI1),assert(pdebug(DAI1))               );
		current_predicate(gameList/1)   
	),						%Forward to HTML rule
	answer(M),    			
	turn(T),	len(T,NT),
	round(R),	len(R,NR),
	html_form(M,NR,NT).


display:-							%This is the same as forward to html part of gather/1
	answer(M),
	turn(T),	len(T,NT),					%It is for the first request, which is not a POST				
	round(R),	len(R,NR),
	html_form(M,NR,NT).	

home_page(_Request) :-					
/**
	essentially this is saying:
	If it is a POST, let gather/1 handle
	Else, let display/0 handle
**/
   	member(method(post), _Request)->gather(_Request);display.		
 /*************************************END OF SERVER SECTION**********************************************/






/***************************************Q-HANDLER RULES****************************************************/
/************These rules are the main query types supported and the main driver of the 10 Question game*****************/
has(X):-
/**
	clear any answer/1 - we delegate this responsibility to the Q-handler rule
	check against the property of the chosen game by match it to property(L) and check for membership
	assert the response to KB via answer/1
	invoke checkTurn/0
**/
	property(L),
	(current_predicate(answer/1)->abolish(answer/1);print('meow')),
	(member(X,L)->assert(answer('That is correct.'));assert(answer('That is incorrect'))),
	checkTurn.   	

has(X,N):-
/**
	clear any answer/1 - we delegate this responsibility to the Q-handler rule
	check against the property of the chosen game by index it to property(L) and check for equality
	assert the response to KB via answer/1
	invoke checkTurn/0
**/
	property(L),
	(current_predicate(answer/1)->abolish(answer/1);print('meow')),
	assert(has2x(X)),assert(has2n(N)),
	(
		(
			(X==teamsize,nth0(0,L,Elem),atom_number(N,NewN),Elem==NewN);
			(X==numOfTeam,nth0(1,L,Elem),atom_number(N,NewN),Elem==NewN);
			(X==fieldtype,nth0(2,L,Elem),Elem==N);
			(X==equipment,nth0(3,L,Elem),Elem==N);
			(X==gamemode,nth0(4,L,Elem),Elem==N)
	)->(assert(answer('That is correct')    ) ,checkTurn) );
	assert(answer('You are wrongggggg.')),
	checkTurn.

is(X):-
/**
	clear any answer/1 - we delegate this responsibility to the Q-handler rule
	chosen(X) can be used as the decision rule
	assert the response to KB via answer/1
	invoke checkTurn/0 if answer wrongly, else invoke reveal
**/
	(current_predicate(answer/1)->abolish(answer/1);print('meow')),
	chosen(X)->(	reveal


		);
	(
			assert(answer('Nice try, but not correct')),
			checkTurn
	).

/**********************************END OF Q_HELPER SECTION**************************************************/





/*********************************GAME MECHANICS SECTION****************************************************/
/***************These rules define the turn, round, initialization and clean up after each round of the game******************/
gameinit:-				
/**
	Initialize round to a list of 0 length
	Collect all the game_name from KB_facts.pl into a list
	Assert this list
	Start the first round
**/
	length(ROUND,0),
	assert(round(ROUND)),
	setof(Game, X^game(Game,X),GameList),
	assert(gameList(GameList)),
	startNewRound.

reveal:-
/**
	This rule will start every subsequent round
	We define it as such so every round-terminating condition can invoke this rule to start the next round
	Case 1: Turn 10 and user still not guessed 
	Case 2: The user guessed correctly 
	Clean up the previous round response (answer/1)
	Let StartNewRound do the round initialization
**/
	turn(T),
	len(T,NT),
	chosen(CorrectGame),
	(current_predicate(answer/1)->abolish(answer/1);print('')),
	(NT==10->html_reveal_wrong(CorrectGame);html_reveal_right),
	assert(answer('')),
	startNewRound.

checkTurn:-
/*
	This function increment the turn by add a singleton variable to the current turn/1
	As turn is indicated by the length of the list in turn/1
*/
	turn(T),
	len(T,N),
	chosen(X),
	(N==10->(reveal    );  		%If it is 10 rounds, end
	
					%%%%Else, print something and increment the counter
	append(T,[_],NT),
	abolish(turn/1),
	assert(turn(NT))).

startNewRound:-
/*
	This function is the core of many other, and it does many things:
	1. Abolish any answer/1  , just sanity check if reveal/0 hasn't done so for some hiccups
	2. Increment the round
	3. Reinitialize list counter to 1
	4. Choose a random game for this round. Make sure it is not any game already chosen previously by deleting off previous game off the gameList/1 
	5. Abolish the old chosen/1 and property/1, update KB with new values to these predicate using assert
*/
	/*****1. Sanity Check*****/
	(current_predicate(answer/1)->abolish(answer/1),assert(answer(''));print('meow')),

	/*****2. increment the round. Because this is invoked right after init, init should assert a list len 0 into round/1 *****/
	round(R),
	len(R,N),
	append(R,[_],NR),   %increase the round counter by append it with some random var
	abolish(round/1),	%do an abolish of old predicate
	assert(round(NR)),  %assert the new value into the KB
	
	/*****3. Reinitialize the list counter to 1*****/
	(current_predicate(turn/1)->abolish(turn/1);print('meow') ),
	length(TurnCounter,1),
	assert(	turn(TurnCounter)),
	
	/*****4. Handle the game choosing*****/
	gameList(L),
	chosen(X),
	(
	X\=nothing->(  	delete(L,X,NL),
			abolish(gameList/1),
			assert(gameList(NL))
		     );
	gameList(NL)
	),       
	random_member(ChosenGame,NL),
	
	/**5. We reset the game (chosen/1), its properties (property/1)**/
	abolish(chosen/1),
	abolish(property/1),
	assert(chosen(ChosenGame)),
	game(ChosenGame,Prop),
	assert(property(Prop)).

/**************************END OF MECHANICS RULES********************************************************/






/*************************************Helper function******************************************************/
/**len is used to find len of a list, we use list length as a counter, hence need a function to do this**/
len([],Res):- Res is 0.
len([H|T],Res):-len(T,L), Res is L +1.

/*************************************DEVELOPER COMMAND LINES******************************************/
please_stop:- http_stop_server(8000,[]),abort.				%stop the system
peek:-chosen(X),property(L).						%see which game at the current round
:-server(8000).							%start the server immediately