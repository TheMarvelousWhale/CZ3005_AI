html_finale:-
	reply_html_page(
	[title('Demo Server')],
	[	br([]),br([]),br([]),
		center([style='font-size: 30pt', title='Desc'],'Thank you, that\'s all!'),%for center
		br([]),br([]),	
		center([style='font-size: 30pt', title='Desc'],'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
	]
	).


html_form(M,R,T):-


atom_concat('Round ',R,NR),
atom_concat('Turn ',T,NT),


reply_html_page(
	[title('Demo Server')],
	[

	br([]),
	center([style='font-size: 36pt', title='tooltip text'],'INSTRUCTIONS -- READ CAREFULLY'),
	br([]),
	br([]),
	center([style='font-size: 18pt', title='Desc'],'Welcome to 10 Questions! - A game built on Prolog.'),
	center([style='font-size: 18pt', title='Desc'],'In this game, your role is a Questioner and the program acts as a Answerer. The Answerer has come up with a Summer Olympic Game. Your job is to find out which game it is within 10 questions.'),

	center([style='font-size: 18pt', title='Desc'],'There will be 5 rounds in total. All the best!'),
	br([]),
	center([style='font-size: 18pt', title='Desc'],'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'),
		br([]),
		center([style='font-size: 36pt', title='tooltip text'],'Ten Question Game'),
		br([]),br([]),br([]),
		center([style='font-size:20pt',title= 'answer'], M),
		center([style='font-size:20pt',title= 'answer'], NR),
		center([style='font-size:20pt',title= 'answer'], NT),
		center([
			form(
				[action='/', method='post'],
				[ %form 2nd arg	
				br([]),br([]),
				center([style='font-size:20pt'],'Choose Your Query Type'),
				br([]),
				br([]),br([]),
				'Query has/2 input: ',
				label([for='keys'],[]),
				select([id('keys'),name('keys')],
				[   
					option([value="teamsize"],teamsize),
					option([value="numOfTeam"],numOfTeam),
					option([value="fieldtype"],fieldtype),
					option([value="equipment"],equipment),
					option([value="gamemode"],gamemode)
				]),
				label([for='answer_has2'], []),
				input([type='text',id='answerhas2',name='answerhas2'],[]),
				button([type='submit_is1'],['Submit']),
				br([]),br([]),
				'Query has/1 input: ',
				label([for='answer_has1'],[]),
				input([type='text',id='answerhas1',name='answerhas1'],[]),
				button([type='submit_has1'],['Submit']),
				br([]),br([]),
				'Query is/1 input: ',
				label([for='answer_is1'],[]),
				input([type='text',id='answeris1',name='answeris1'],[]),
				button([type='submit_is1'],['Submit']),
				br([]),br([])
				] %form 2nd arg
			) %for the form1

			
		])  %for the center
		
	]
).


html_reveal_right:-
	reply_html_page(
	[title('Demo Server')],
	[	br([]),br([]),br([]),
		center([style='font-size: 30pt', title='Desc'],'Congratulation, you have guessed the correct game.'),%for center
		br([]),br([]),
		center([style='font-size: 30pt', title='Desc'],'On to the next Round'),%for center
		br([]),br([]),
		center([
			form([action='/', method='post'],[
							button([type='submit_is1'],['Click Here For Next Round'])    
							]
			)
		]),
		center([style='font-size: 30pt', title='Desc'],'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'),
		br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([])
	]
	).

html_reveal_wrong(CorrectGame):-
	atom_concat('The Game AI thought of was: ',CorrectGame,NG),
	reply_html_page(
	[title('Demo Server')],
	[	br([]),br([]),br([]),
		center([style='font-size: 30pt', title='Desc'],'Sorry, you have not guessed the correct game.'),%for center
		br([]),br([]),		
		center([style='font-size: 30pt', title='Desc'],NG),%for center
		br([]),br([]),		
		center([style='font-size: 30pt', title='Desc'],'On to the next Round'),%for center
		br([]),br([]),
		center([
			form([action='/', method='post'],[
							button([type='submit_is1'],['Click Here For Next Round'])    
							]
			)
		]),
		center([style='font-size: 30pt', title='Desc'],'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'),
		br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([]),br([])
	]
	).

