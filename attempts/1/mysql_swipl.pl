getVar(UserName,DBName,VarName,Var) :-
	atomic_list_concat([UserName,DBName,VarName],'-',Var).

connectToMySQL(UserName,DBName,MySQLConnection) :-
	getVar(UserName,DBName,'name',Var),
	catch(nb_getval(Var,MySQLConnection),_,openConnectionToMySQL(UserName,DBName,MySQLConnection)).

openConnectionToMySQL(UserName,DBName,MySQLConnection) :-
	odbc_connect(test, MySQLConnection, [user(root), password('<PASSWORD>')]),
	getVar(UserName,DBName,'name',Var),
	nb_setval(Var,MySQLConnection).
openConnectionToMySQL(_,_,MySQLConnection) :-
	MySQLConnection = nil,
	write('ERROR: Cannot connect to MySQL.'),nl.
