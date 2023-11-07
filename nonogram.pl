nonogram(Rows, Columns):-
    length(Rows, R),
    R > 0,
    length(Columns, C),
    C > 0,
    printPuzzle(Rows, Columns, C).

printPuzzle(Rows, Columns, C) :-
    printEachRow(Rows, C),
    printEachColumn(Columns).

printEachRow([],_).
printEachRow([Head|Rest], C) :-
    printCell(C),
    printBlockList(Head), nl,
    printEachRow(Rest,C).

printBlockList([]).
printBlockList([Head|Rest]) :- 
    write(' '),
    write(Head),
    printBlockList(Rest).

printCell(0) :- write('|').
printCell(C) :- 
    write('|_'),
    Cnew is C-1,
    printCell(Cnew).

printEachColumn([]).
printEachColumn([[]|Rest]) :- printEachColumn(Rest).
printEachColumn(Cols) :- 
    firstElements(Cols, L, R), 
    printBlockList(L), nl,
    printEachColumn(R).

firstElements([], [], []).
firstElements([[First|RestSub]|Rest], [First|Firsts], [RestSub|Leftover]) :- firstElements(Rest, Firsts, Leftover).


test(N) :- puzzle(N, R, C), nonogram(R,C).

puzzle(1, R, C) :- 
    R = [[3],[2,1],[3,2],[2,2],[6],[1,5],[6],[1],[2]], 
    C = [[1,2],[3,1],[1,5],[7,1],[5,0],[3,0],[4,0],[3,0]]. % TODO: fix recursion issue when sublists are of unequal length