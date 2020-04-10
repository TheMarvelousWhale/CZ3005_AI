
init:- 
	setof(Game, X^game(Game,X),GameList),
	assert(gameList(GameList)).
	length(RoundCounter,5).
	length(TurnCounter,10).
	assert(round(RoundCounter)).
	assert(turn(TurnCounter)).
	
reset:-
	game(X,Prop),
	retractall(chosen(X)),
	retractall(property(Prop)).

startNewRound:-
	gameList(L),
	random_member(ChosenGame,L),
	assert(chosen(ChosenGame)),
	%print(ChosenGame),
	game(ChosenGame,Prop),
	%print(Prop),
	writeln('We have chosen a game. Make your guess!'),
	assert(property(Prop)).	
%define the list as follow (teamsize,	field type, equipment).	
game(badminton,[2,field,racket]).
game(soccer,[11,field,ball]).
game(floorball,[6,court,stick]).
game(badminton,[1,field,racket]).
game(basketboll,[5,court,ball]).


has(X):-
	property(L),
	member(X,L).
has(X,N):-
	property(L),
	(
	(X==teamsize,nth0(0,L,Elem),Elem==N);
	(X==fieldtype,nth0(1,L,Elem),Elem==N);
	(X==equipment,nth0(2,L,Elem),Elem==N)
	).
is(X):- 
	chosen(X),
	writeln('Great Job mtfker'),
	reset,
	startNewRound.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%HELPER FUNCTIONS%%%%%%%%%%%%%%%%%%%
len([],Res):- Res is 0.
len([H|T],Res):-len(T,L), Res is L +1.

delFirstElem(L,NL):-
	nth0(0,L,Elem),
	select(Elem,L,NL),

