:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/iem/frdcsa/sys/flp/autoload/args.pl').
:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/data-integration/attempts/1/mysql_swipl.pl').
:- dynamic listValues/3.


%%%%%%%%%%%%%%%%%%%%%%%%%

%% FIXME:

%% 1. We need to do better than this, but to pull everything in as a list

%% findall(Row,odbc_query(C, 'SELECT ID FROM CONTEXTS WHERE Context=?', Row),Rows)


%% 2. We need to fix retrieve to not use assert / retractall

%%%%%%%%%%%%%%%%%%%%%%%%%

flpFlag(none).

viewIf(Item) :-
 	(   flpFlag(debug) -> 
	    view(Item) ;
	    true).

%%%%%%%%%%%%%%%%%%%%%%%%%

connectToMySQL(C) :-
	connectToMySQL('root','freekbs2',C).

%%%%%%%%%%%%%%%%%%%%%%%%%

listContexts(Arguments) :-
	argt(Arguments,[contexts(Contexts)]),

	connectToMySQL(C),
	findall(Row,odbc_query(C, 'SELECT DISTINCT Context FROM contexts', row(Row)),Contexts),

	Arguments = [contexts(Contexts)].

getContextID(Arguments) :-
	argt(Arguments,[context(Context),contextID(ContextID)]),

	connectToMySQL(C),
	odbc_prepare(C,'SELECT * FROM contexts WHERE Context=?',[default],Statement,[]),
	odbc_execute(Statement,[Context],row(ContextID,_)),

	Arguments = [context(Context),contextID(ContextID)].

%% test getContextID([context('Org::FRDCSA::SAFE::ProjectManagement'),contextID(ContextID)]).

getContextFromID(Arguments) :-
	argt(Arguments,[context(Context),contextID(ContextID)]),

	connectToMySQL(C),
	odbc_prepare(C,'SELECT * FROM contexts WHERE ID=?',[integer],Statement,[]),
	odbc_execute(Statement,[ContextID],row(_,Context)),

	Arguments = [context(Context),contextID(ContextID)].

%% test getContextFromID([context(Context),contextID(191)]).

getAsserterID(Arguments) :-
	argt(Arguments,[asserter(Asserter),asserterID(AsserterID)]),

	connectToMySQL(C),
	odbc_prepare(C,'SELECT * FROM asserters WHERE Asserter=?',[default],Statement,[]),
	odbc_execute(Statement,[Asserter],row(AsserterID,_)),

	Arguments = [asserter(Asserter),asserterID(AsserterID)].

%% test getAsserterID([asserter('guest'),asserterID(AsserterID)]).

retrieve(Arguments) :-
	retrieveUsingAssert(Arguments),
	retractall(listValues(_,_,_)).

retrieveUsingAssert(Arguments) :-
	argt(Arguments,[parentFormulaID(ParentFormulaID),formula(Formula)]),

	connectToMySQL(C),
	odbc_prepare(C,'SELECT * FROM arguments WHERE ParentFormulaID=?',[integer],Statement,[]),
	findall(Result,odbc_execute(Statement,[ParentFormulaID],Result),Results),

	forall(member(row(ID,ParentFormulaID,ValueType,KeyID,Value),Results),
	       (   viewIf(row(ID,ParentFormulaID,ValueType,KeyID,Value)),
		   (   ValueType = formula ->
		       (   
			   viewIf([a]),
			   atom_number(Value,Number),
			   retrieveUsingAssert([parentFormulaID(Number),formula(SubFormula)]),
			   viewIf([number,Number,subformula,SubFormula]),
			   assert(listValues(ParentFormulaID,KeyID,SubFormula))) ;   
		       (   
			   viewIf([b]),
			   ValueType = variable ->
			   (   viewIf([c,Value]),
			       convertKIFToPrologVar(Value,Var),
			       viewIf(listValues(ParentFormulaID,KeyID,Var)),
			       assert(listValues(ParentFormulaID,KeyID,Var))) ;
			   (   viewIf([d]),
			       viewIf(listValues(ParentFormulaID,KeyID,Value)),
			       assert(listValues(ParentFormulaID,KeyID,Value)))
		       )
		   ))),

	findall(listValues(ParentFormulaID,I,Value),listValues(ParentFormulaID,I,Value),Values),
	viewIf([values,Values]),
	predsort(sortIndex,Values,SortedValues),
	viewIf([sortedvalues,SortedValues]),
	findall(Item,member(listValues(ParentFormulaID,_,Item),SortedValues),FormulaList),
	Formula =.. FormulaList,
	viewIf([formula,Formula]),
	Arguments = [parentFormulaID(ParentFormulaID),formula(Formula)].

convertKIFToPrologVar(KIFVariable,PrologVariable) :-
	atom_concat('?',TmpVar1,KIFVariable),
	viewIf([tmp,TmpVar1]),
	capitalize(TmpVar1,Var),
	PrologVariable = '$VAR'(Var).

sortIndex(Compare,listValues(_,I1,_),listValues(_,I2,_)) :-
	compare(Compare,I1,I2).

%% test retrieve([parentFormulaID(1),formula(Formula)]).

allAssertedKnowledge(Arguments) :-
	argt(Arguments,[context(Context),asserter(Asserter),date(Date),search(Search),idsOnly(IdsOnly),formulae(Formulae)]),

	(   Context = 'all-contexts' ->
	    (	getContextID([context('extended-wordnet'),contextID(ContextID)]) ,
		atomic_list_concat(['ContextID != ',ContextID],Condition),
		Conditions = [Condition]) ;
	    (	getContextID([context(Context),contextID(ContextID)]),
		atomic_list_concat(['ContextID = ',ContextID],Condition),
		Conditions = [Condition])),

	(   nonvar(Asserter) ->
	    (	getAsserterID([asserter(Asserter),asserterID(AsserterID)]),
		atomic_list_concat(['AsserterID = ',AsserterID],Condition),
		Conditions = [Condition]) ; true),
	
	(   nonvar(Date) ->
	    (	atomic_list_concat(['Date ',Date],Condition),
		Conditions = [Condition]) ; true),

	length(Conditions,Length),
	(   Length > 0 ->
	    (	atomic_list_concat(Conditions,' AND ',Clause),
		atomic_list_concat(['SELECT DISTINCT ContextID,FormulaID FROM metadata WHERE',Clause],' ',Statement)) ;
	    Statement = 'SELECT DISTINCT ContextID,FormulaID FROM metadata'),

	connectToMySQL(C),
	findall(FormulaID,odbc_query(C, Statement, row(_,FormulaID)),FormulaIDs),
	%% view([formulaids,FormulaIDs]),
	%% FIXME: add missing parts for this function from KBS2::Store::MySQL
	findall(Formula,(member(FormulaID,FormulaIDs),retrieve([parentFormulaID(FormulaID),formula(Formula)])),Formulae),

	Arguments = [context(Context),asserter(Asserter),date(Date),search(Search),idsOnly(IdsOnly),formulae(Formulae)].

tests :-
	getContextID([context('Org::FRDCSA::SAFE::ProjectManagement'),contextID(ContextID)]),
	view(contextid(ContextID)),
	getContextFromID([context(Context),contextID(191)]),
	view(context(Context)),
	getAsserterID([asserter('guest'),asserterID(AsserterID)]),
	view(asserterID(AsserterID)),
	retrieve([parentFormulaID(1),formula(Formula)]),
	view(formula(Formula)),
	allAssertedKnowledge([context('Purchases'),asserter(Asserter),date(Date),search(Search),idsOnly(IdsOnly),formulae(Formulae1)]),
	view(formulae(Formulae1)),
	allAssertedKnowledge([context('Org::FRDCSA::Clear::DocData'),asserter(Asserter),date(Date),search(Search),idsOnly(IdsOnly),formulae(Formulae2)]),
	view(formulae(Formulae2)).

	%% assertFormula([parentFormulaID(-1),argumentID(-1),formula(Formula),context(Context),asserter(Asserter),useSayer(UseSayer),retval(Retval)]),
	%% view(retval(Retval)),
	%% assertFormula([parentFormulaID(-1),argumentID(-1),formula(Formula),context(Context),asserter(Asserter),useSayer(UseSayer),retval(Retval)]),
	%% view(retval(Retval)).


%% getRootFormula(Arguments) :-
%% 	argt(Arguments,[id(ID)]),

%% 	connectToMySQL(C),
%% 	%% ['SELECT ParentFormulaID FROM formulae WHERE ID=?',ID]
%% 	findall(Row,odbc_query(C, '', Row),Rows),

%% 	Arguments =[rows(Rows)].

%% getIDForFormula(Arguments) :-
%% 	argt(Arguments,[wheres(Wheres),subroutine(Subroutine),context(Context),parentFormulaVar(ParentFormulaVar),formulaVars(FormulaVars),formulaVarsIndex(FormulaVarsIndex),argumentVars(ArgumentVars),argumentVarsIndex(ArgumentVarsIndex),formula(Formula)]),

%% 	connectToMySQL(C),
%% 	%% ['SELECT ID FROM CONTEXTS WHERE Context=?',Context]
%% 	%% ['SELECT f1.ID FROM ? WHERE ?',Vars,Wheres] %% join(", ",@vars), [sort keys %$wheres]
%% 	findall(Row,odbc_query(C, 'SELECT ID FROM CONTEXTS WHERE Context=?', Row),Rows),

%% 	Arguments =[rows1(Rows1),rows2(Rows2)].

%% test allAssertedKnowledge([context('Purchases'),asserter(Asserter),date(Date),search(Search),idsOnly(IdsOnly),formulae(Formulae)]).
%% test allAssertedKnowledge([context('Org::FRDCSA::Clear::DocData'),asserter(Asserter),date(Date),search(Search),idsOnly(IdsOnly),formulae(Formulae)]).

%%% <-

%% assert(Arguments) :-
%% 	assertFormula(Arguments).

assertFormula(Arguments) :-
	argt(Arguments,[parentFormulaID(ParentFormulaID),argumentID(ArgumentID),formula(Formula),context(Context),asserter(Asserter),useSayer(UseSayer),retval(Retval)]),

	not(atomic(Formula)) ->
	(   
	    Formula =.. [Pred|Args],

	    length(Args,Arity),
	    (	nonvar(ArgumentID) -> true ; ArgumentID = 'NULL'),

	    connectToMySQL(C),

	    odbc_prepare(C,'INSERT INTO formulae (ID,ParentFormulaID,ArgumentID,Arity) VALUES (NULL, ?, ?, ?)',[integer,integer,integer],Statement1,[]),
	    odbc_execute(Statement1,[ParentFormulaID,ArgumentID,Arity],Retval1),
	    view([retval1(Retval1)]),

	    odbc_prepare(C,'SELECT last_insert_id()',[],Statement,[]),
	    odbc_execute(Statement,[],row(FormulaID)),
	    view([formulaID(FormulaID)]),
	    
	    foreach(member(Arg,Args),
		    (	
			view([arg,Arg]),
			not(atomic(Arg)) ->
			assertFormula([
				       parentFormulaID(FormulaID),
				       argumentID('$null$'),
				       formula(Arg),
				       context(Context),
				       asserter(Asserter),
				       useSayer(UseSayer),
				       retval(Retval3)
				      ]) ;

			,
			view([retval3,Retval3])
		    )),
	    ) ;
	(   ),

	Arguments = [parentFormulaID(ParentFormulaID),argumentID(ArgumentID),formula(Formula),useSayer(UseSayer),context(Context),asserter(Asserter),retval([Retval1,Retval2])].

%% assertFormula([parentFormulaID(-1),argumentID(-1),formula(thisIsA(test,of(the,emergency(broadcasting)))),context('Org::FRDCSA::DataIntegration::Debug'),asserter(Asserter),useSayer(UseSayer),retval(Retval)]).

%% test assertFormula([parentFormulaID(-1),argumentID(-1),formula(thisIsA(test)),context('Org::FRDCSA::DataIntegration::Debug'),asserter(Asserter),useSayer(UseSayer),retval(Retval)]).
%% test assertFormula([parentFormulaID(-1),argumentID(-1),formula(Formula),context(Context),asserter(Asserter),useSayer(UseSayer),retval(Retval)]).

%% clean out the KB maybe with this: select ID,ParentFormulaID from formulae where ParentFormulaID not in (select ParentFormulaID from arguments);


%% remove(Arguments) :-
%% 	argt(Arguments,[id(ID),removeSubformula(RemoveSubFormula),retval(Retval)]),
	
%% 	connectToMySQL(C),
%% 	%% ['SELECT * FROM arguments WHERE ParentFormulaID=?',ID]
%% 	%% ['DELETE FROM arguments WHERE ID=?',ArgumentID]
%% 	%% ['DELETE FROM formulae WHERE ID=?',ID]
%% 	%% ['DELETE FROM metadata WHERE FormulaID=?',ID]
%% 	%% ['SELECT ParentFormulaID FROM formulae where ID=?',ID]
%% 	findall(Row,odbc_query(C, '', Row),Rows),

%% 	Arguments = [id(ID),removeSubformula(RemoveSubFormula),retval(Retval)].




%%%%%%%%%%%%%%%%%%%%%%%%%

%% retrieve(Arguments) :-
%% 	argt(Arguments,[parentFormulaID(ParentFormulaID),formula(Formula)]),

%% 	connectToMySQL(C),
%% 	odbc_prepare(C,'SELECT * FROM arguments WHERE ParentFormulaID=?',[integer],Statement,[]),
%% 	findall(Result,odbc_execute(Statement,[ParentFormulaID],Result),Results),

%% 	member(row(ID,ParentFormulaID,ValueType,KeyID,Value),Results),
%% 	(   viewIf(row(ID,ParentFormulaID,ValueType,KeyID,Value)),
%% 	    (	ValueType = formula ->
%% 		(   viewIf([a]),
%% 		    atom_number(Value,Number),
%% 		    retrieve([parentFormulaID(Number),formula(SubFormula)]),
%% 		    viewIf([number,Number,subformula,SubFormula]),
%% 		    nth0(KeyID,Formula,SubFormula)) ;
%% 		(   
%% 		    viewIf([b]),
%% 		    ValueType = variable ->
%% 		    (	viewIf([c]),
%% 			viewIf(nth(KeyID,Formula,Value)),
%% 			nth0(KeyID,Formula,Var)) ;
%% 		    (	viewIf([d]),
%% 			viewIf(nth(KeyID,Formula,Value)),
%% 			nth0(KeyID,Formula,Value))
%% 		))),

%% 	Arguments = [parentFormulaID(ParentFormulaID),formula(Formula)].

