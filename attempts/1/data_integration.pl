:- use_module(library(odbc)).
:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/free-life-planner/lib/util/util.pl').
:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/data-integration/attempts/1/freekbs2_swipl.pl').

%% /home/andrewdo/.odbc.ini

run :-
	listContexts([contexts(Contexts)]),
	view([contexts,Contexts]).
