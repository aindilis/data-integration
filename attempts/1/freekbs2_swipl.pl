:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/iem/frdcsa/sys/flp/autoload/args.pl').
:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/data-integration/attempts/1/mysql_swipl.pl').
:- dynamic listValues/3, i/1.


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
	connectToMySQL('root','freekbs2_dev',C).

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
	%% insert into contexts values (NULL,'Org::FRDCSA::SAFE::ProjectManagement');
	%% insert into asserters values (NULL,'guest');

	getContextID([context('Org::FRDCSA::SAFE::ProjectManagement'),contextID(ContextID)]),
	view(contextid(ContextID)),
	getContextFromID([context(Context),contextID(1)]),
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
	argt(Arguments,[parentFormulaID(ParentFormulaID),argumentID(ArgumentID),formula(FormulaTmp),context(Context),asserter(Asserter),useSayer(UseSayer),retval(Retval)]),
	connectToMySQL(C),
	FormulaTmp =.. [Pred|Args],
	append([[Pred],Args],Formula),

	length(Formula,Arity),
	(   nonvar(ArgumentID) -> true ; ArgumentID = 'NULL'),

	odbc_prepare(C,'INSERT INTO formulae (ID,ParentFormulaID,ArgumentID,Arity) VALUES (NULL, ?, ?, ?)',[integer,integer,integer],Statement1,[]),
	odbc_execute(Statement1,[ParentFormulaID,ArgumentID,Arity],Retval1),
	view([retval1(Retval1)]),

	lastInsertID(FormulaID),

	assert(i(0)),
	forall(member(Arg,Formula),
		(   
		    view([arg,Arg]),
		    not(atomic(Arg)) ->
		    (	
			view([2]),
			assertFormula([
				       parentFormulaID(FormulaID),
				       argumentID('$null$'),
				       formula(Arg),
				       context(Context),
				       asserter(Asserter),
				       useSayer(UseSayer),
				       retval(Retval2)
				      ]),
			view([retval2,Retval2]),
			argt(Retval2,[subformulaID(SubformulaID)]),

			view([i1,I1]),
			incrI(I1,I2),
			insert(arguments,
			       [
				['ID','ParentFormulaID','ValueType','KeyID','Value'],
				['NULL', ?, ?, ?, ?],
				[ParentFormulaID,formula,I1,SubformulaID],
				[integer,default,integer,integer]
			       ],
			       Retval4),
			
			lastInsertID(ArgumentID),

			PreStatement = 'UPDATE formulae set ArgumentID=? where ID=?',
			RecordTypes = [integer,integer],
			odbc_prepare(C,PreStatement,RecordTypes,FinalStatement,[]),
			odbc_execute(FinalStatement,[ArgumentID,SubformulaID],Retval6),
			view([prepare1(PreStatement,RecordTypes,FinalStatement),retval6(Retval6)])
		    ) ;
		    (	
			not(nonvar(Arg)) ->
			(   
			    view([a]),
			    view([i3,I3]),
			    incrI(I3,I4),
			    insert(arguments,
				   [
				    ['ID','ParentFormulaID','ValueType','KeyID','Value'],
				    ['NULL', ?, ?, ?, ?],
				    [FormulaID,variable,I3,var(Arg)],
				    [integer,default,integer,default]
				   ],
				   Retval7)
			    ) ;
			(   
			    view([i5,I5]),
			    incrI(I5,I6),
			    view([b1]),
			    insert(arguments,
				   [
				    ['ID','ParentFormulaID','ValueType','KeyID','Value'],
				    ['NULL', ?, ?, ?, ?],
				    [FormulaID,string,I5,Arg],
				    [integer,default,integer,default]
				   ],
				   Retval8),
			    view([b2])
			)
		    ),
		    view([9])
		)
	       ),

	(   ParentFormulaID = -1 ->
	    (
	     getContextID([context(Context),contextID(ContextID)]),
	     getAsserterID([asserter(Asserter),asserterID(AsserterID)]),
	     insert(arguments,
		    [
		     ['ID','FormulaID','ContextID','AssertedID','Date'],
		     ['NULL', ?, ?, ?, ?],
		     [FormulaID,ContextID,AsserterID,'Now()'],
		     [integer,integer,integer,default]
		    ],
		    Retval9)
	    ) ; true ),
	view([finished]),
	Arguments = [parentFormulaID(ParentFormulaID),argumentID(ArgumentID),formula(FormulaTmp),context(Context),asserter(Asserter),useSayer(UseSayer),retval([subformulaID(FormulaID)])],
	view([finished2]),
	resetI,
	true.

dev :-
	resetI,
	Context = 'Org::FRDCSA::DataIntegration::Debug',
	assertFormula([parentFormulaID(-1),argumentID(-1),formula(thisIsA(test,of(the,emergency(broadcasting,system)))),context(Context),asserter(Asserter),useSayer(UseSayer),retval(Retval)]),
	allAssertedKnowledge(Context).

resetI :-
	retractall(i(_)),
	assert(i(0)).

lastInsertID(ID) :-
	connectToMySQL(C),
	odbc_prepare(C,'SELECT last_insert_id()',[],Statement,[]),
	odbc_execute(Statement,[],row(ID)),
	view(id(ID)).

incrI(I1,I2) :-
	%% view([item]),
	findall(X0,i(X0),Z0),
	%% view([z0,Z0]),
	i(I1),
	%% view([item]),
	%% view([i1,I1]),
	%% view([a1]),
	I2 is I1 + 1,
	%% view([a2]),
	findall(X1,i(X1),Z1),
	%% view([z1,Z1]),
	retractall(i(_)),
	%% view([a3]),
	findall(X2,i(X2),Z2),
	%% view([z2,Z2]),
	%% view([item]),
	assert(i(I2)),
	%% view([item]),
	%% view([i2,I2]),
	true.

%% truncate arguments; truncate asserters; truncate contexts; truncate formulae; truncate metadata;
%% select * from arguments; select * from asserters; select * from contexts; select * from formulae; select * from metadata;

%% forall(between(1,10,X),writeln(x=X))

%% RecordNames = ['ID','ParentFormulaID','ValueType','KeyID','Value']
%% RecordReferences = ['NULL', ?, ?, ?, ?],
%% RecordValues = [FormulaID,string,I5,Arg]
%% RecordTypes = [integer,default,integer,default]

insert(TableName,[RecordNames,RecordReferences,RecordValues,RecordTypes],Retval) :-
	view([recordValues,RecordValues]),
	atomic_list_concat(RecordNames,',',RecordNamesString),
	atomic_list_concat(RecordReferences,',',RecordReferencesString),
	atomic_list_concat(['INSERT INTO ',TableName,' (',RecordNamesString,') VALUES (',RecordReferencesString,')'],'',PreStatement),
	connectToMySQL(C),
	odbc_prepare(C,PreStatement,RecordTypes,FinalStatement,[]),
	odbc_execute(FinalStatement,RecordValues,Retval),
	view([prepare2(PreStatement,RecordTypes,FinalStatement),retval(Retval)]).

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
