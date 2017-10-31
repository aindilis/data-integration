assertFormula([parentFormulaID(),argumentID(),formula(),useSayer(),context(),asserter()]) :-
	%% "update formulae set ArgumentID='".$argumentid."' where ID='".$subformulaid."';"
	true.

getContextID([context()]) :-
	%% (   Statement => "select * from contexts where Context=$quotedcontext");
	true.


getContextFromID([context(),contextID()]) :-
	%% Statement => "select * from contexts where ID=$quotedcontextid",
	true.

getAsserterID([asserter()]) :-
	%% (   Statement => "select * from asserters where Asserter=$quotedasserter");
	true.

allAssertedKnowledge([context(),asserter(),date(),search(),idsOnly()]) :-
	%% $statement = "select distinct ContextID,FormulaID from metadata where ".join(" and ",@conditions);
	%% $statement = "select distinct ContextID,FormulaID from metadata";
	true.

retrieve([id()]) :-
	%% my $r2 = $self->MyMySQL->Do(Statement => "select * from arguments where ParentFormulaID=$args{ID}");
	true.

remove([id(),removeSubformula()]) :-
	%%   my $statement = "select * from arguments where ParentFormulaID = $args{ID}";

	%% $self->MyMySQL->Do(Statement => "delete from arguments where ID=$argumentid");

	%% $self->MyMySQL->Do(Statement => "delete from formulae where ID=$args{ID}");

	%% $self->MyMySQL->Do(Statement => "delete from metadata where FormulaID=$args{ID}");
	true.

getRootFormula([id(),]) :-
	%% Statement => "select ParentFormulaID from formulae where ID=$id",	
	true.


clean() :-
	%% $self->MyMySQL->Do(Statement => "truncate $table;");
	true.

renameContext([context(),newContext()]) :-
	%% Statement => "update contexts set Context = ".
	%% $self->MyMySQL->Quote($args{NewContext})." where Context = ".
	%% $self->MyMySQL->Quote($args{Context}),
	true.

removeContext([context(Context)) :-
	     %% Statement => "delete from contexts where Context=".
	     true.

getIDForFormula([wheres(),subroutine(),context(),parentFormulaVar(),formulaVars(),formulaVarsIndex(),argumentVars(),argumentVarsIndex(),formula()]) :-
	%% Statement => "select ID from contexts where Context=".$self->MyMySQL->Quote($args{Context}),

	%% my $statement = "select f1.ID from ".join(", ",@vars)." where ".join(" and ",sort keys %$wheres);
	true.

listContexts([]) :-
	%% Statement => "select DISTINCT Context from contexts");
	true.