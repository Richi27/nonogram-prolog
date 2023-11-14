nonogram(RowsHint, ColumnsHint):-
    length(RowsHint, R),
    R > 0,
    length(ColumnsHint, C),
    C > 0,
    empty_grid(Grid, R, C),
    print_puzzle(Grid,RowsHint, ColumnsHint).

nonogram_user(RowsHint, ColumnsHint) :-
    length(RowsHint, R),
    R > 0,
    length(ColumnsHint, C),
    C > 0,
    empty_grid(Grid, R, C),
    print_puzzle(Grid,RowsHint, ColumnsHint),
    user_input(Grid, RowsHint, ColumnsHint).

% TODO: rework user input to check for valid input and retry if not, also implement a stop word 
user_input(Grid, RowsHint, ColumnsHint) :- 
    writeln('Enter grid cell (Col,Row):'),
    write('Enter Col:'),
    read(Col), 
    Col >= 0, 
    write('Enter Row:'),
    read(Row), 
    Row >= 0,
    mark_cell(Grid, Row, Col, NewGrid),
    print_puzzle(NewGrid, RowsHint, ColumnsHint),
    write('Continue? y/n'),
    read(Continue),
    (continue(Continue) ->
    user_input(NewGrid, RowsHint, ColumnsHint); write('Game Over!')).

continue('y').

% TODO: implement unmark_cell

mark_cell(Grid, R, C, NewGrid) :- 
    find_element_at(R, Grid, Row),
    replace_at_pos(Row, C, 'X',NewRow),
    replace_at_pos(Grid, R, NewRow, NewGrid).

find_element_at(0, [Head|_], Head).
find_element_at(Pos,[_|Tail], Element) :-
    Pos > 0,
    Pos1 is Pos-1,
    find_element_at(Pos1, Tail, Element).

% create new list with old element and new element at specified position
replace_at_pos([], _, _, []).
replace_at_pos([_|Tail], 0, Element, [Element|Tail]) :-
    !. % Cut to stop backtracking, we found the position.
replace_at_pos([Head|Tail], Pos, Element, [Head|Result]) :-
    Pos > 0,
    Pos1 is Pos - 1,
    replace_at_pos(Tail, Pos1, Element, Result).

empty_grid([], 0, _).
empty_grid([Row|Rest], R, C) :-
    R > 0,
    R1 is R-1,
    empty_row(Row, C),
    empty_grid(Rest, R1, C).

empty_row([], 0).
empty_row([_|Tail], N) :- 
    N > 0,
    N1 is N-1,
    empty_row(Tail, N1).

print_puzzle(Grid, RowsHint, ColumnsHint) :-
    print_rows(Grid,RowsHint), 
    print_columns(ColumnsHint).

print_rows([], []).
print_rows([Head|RestRows], [Hints|RestHints]) :-
    print_list(Head, '|'),
    print_list(Hints,' '), nl,
    print_rows(RestRows,RestHints).

print_list([],_).
print_list([Head|Tail], Seperator) :- 
    print_element(Head),
    write(Seperator),
    print_list(Tail, Seperator).

print_element(E) :- var(E), !, write('_').
print_element(E) :- write(E).

print_columns([]).
print_columns([[]|Tail]) :- print_columns(Tail).
print_columns(Cols) :- 
    first_elements(Cols, L, R), 
    print_list(L, ' '), nl,
    print_columns(R).

first_elements([], [], []).
first_elements([[First|RestSub]|Rest], [First|Firsts], [RestSub|Leftover]) :- first_elements(Rest, Firsts, Leftover).

test(N) :- puzzle(N, R, C), nonogram(R,C).

user(N) :- puzzle(N,R,C), nonogram_user(R,C).

puzzle(1, R, C) :- 
    R = [[3],[2,1],[3,2],[2,2],[6],[1,5],[6],[1],[2]], 
    C = [[1,2],[3,1],[1,5],[7,1],[5,0],[3,0],[4,0],[3,0]]. % TODO: fix recursion issue when sublists are of unequal length

% TODO: define further puzzles
% TODO: 
