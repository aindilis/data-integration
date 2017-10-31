:- use_module(library(odbc)).
%% :- import(odbc).

%% /home/andrewdo/.odbc.ini

:- consult('/var/lib/myfrdcsa/codebases/minor/free-life-planner/lib/util/util.pl').

%% open_freekbs2 :-
%% 	odbc_connect('freekbs2', _,
%% 		     [
%% 		      user(root),
%% 		      password('<PASSWORD>'),
%% 		      alias(freekbs2),
%% 		      open(once)
%% 		     ]).

%% open_freekbs2 :-
%% 	odbc_connect('mysql:dbname=freekbs2;host=localhost', _,
%% 		     [
%% 		      user(root),
%% 		      password('<PASSWORD>'),
%% 		      alias(freekbs2),
%% 		      open(once)
%% 		     ]).

%% open_freekbs2 :-
%%         odbc_connect(freekbs2_odbc, _,
%%                      [ user('root'),
%%                        password('<PASSWORD>'),
%%                        alias(freekbs2),
%%                        open(once)
%%                      ]).

%% myodbc_connect_db(Db, Uid, Pwd, Cn) :-                                                                                                          
%% 	format(atom(S), 'driver=mysql;db=~w;uid=~w;pwd=~w', [Db, Uid, Pwd]),                                                                        
%% 	odbc_driver_connect(S, Cn, [encoding(utf8)]).                                                                                               

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

run :-
	%% open_freekbs2,
	%% lemma(Contexts).
	odbc_connect(test, C, [user(root), password('<PASSWORD>')]),
	odbc_query(C, 'SELECT * FROM contexts', Rows),
	view([rows,Rows]).
