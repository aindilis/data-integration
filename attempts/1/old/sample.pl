%% insert_child(Child, Mother, Father, Affected) :-
%% 	odbc_query(parents,
%% 		   'INSERT INTO parents (name,mother,father) \
%% 		  VALUES (\'mary\', \'christine\', \'bob\')',
%% 		   affected(Affected)).

%% all_asserted_knowledge(Context, Knowledge) :-
%% 	odbc_query(parents,
%% 		   'select * FROM  (name,mother,father) \
%% 		  VALUES (\'mary\', \'christine\', \'bob\')',
%% 		   affected(Affected)).

%% lemma(Contexts) :-
%% 	%% myodbc_connect_db('freekbs2', 1000, '<PASSWORD>', Cn),
%% 	%% open_freekbs2,
%% 	odbc_query(freekbs2_odbc,
%% 		   'SELECT (Context) FROM contexts',
%% 		   row(Contexts)),
%% 	view([contexts,Contexts]).
