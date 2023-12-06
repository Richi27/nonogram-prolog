nonogram(RowsHint, ColumnsHint, UserInput):-
    get_lengths(RowsHint, ColumnsHint, R, C),
    empty_grid(Grid, R, C),
    print_puzzle(Grid,RowsHint, ColumnsHint),
    (UserInput ->
       user_input(Grid, RowsHint, ColumnsHint);

       solve(Grid, RowsHint, ColumnsHint),
       print_puzzle(Grid, RowsHint, ColumnsHint)
    ).

user_input(Grid, RowsHint, ColumnsHint) :-
    writeln('Enter grid cell (Col,Row):'),
    read_cell(Col, Row),
    (valid_input(Col, Row, RowsHint, ColumnsHint) ->
       mark_cell(Grid, Row, Col, 'X', NewGrid),
       print_puzzle(NewGrid, RowsHint, ColumnsHint),
       write('Continue or undo last move? y/u/n'),
       read(Continue),
       continue(Continue, NewGrid, RowsHint, ColumnsHint);

       write('Invalid input. '),
       user_input(Grid, RowsHint, ColumnsHint)
    ).

continue('y', Grid, RowsHint, ColumnsHint) :-
    user_input(Grid, RowsHint, ColumnsHint).

continue('u', Grid, RowsHint, ColumnsHint) :-
    writeln('Enter the cell you want to clear (Col,Row):'),
    read_cell(Col, Row),
    (valid_input(Col, Row, RowsHint, ColumnsHint) ->
       mark_cell(Grid, Row, Col, '_', NewGrid),
       print_puzzle(NewGrid, RowsHint, ColumnsHint),
       user_input(NewGrid, RowsHint, ColumnsHint);
       write('Invalid input. '),
       continue('u', Grid, RowsHint, ColumnsHint)
    ).

continue(_, Grid, RowsHint, ColumnsHint) :-
    get_lengths(RowsHint, ColumnsHint, R, C),
    empty_grid(CorrectGrid, R, C),
    solve(CorrectGrid, RowsHint, ColumnsHint),
    (maplist(x_at_same_position, Grid, CorrectGrid) ->
             write('Correct solution. You win!');
             writeln('Wrong solution. Game Over!'),
             grid_diff(Grid, CorrectGrid, DiffGrid),
             print_puzzle(DiffGrid, RowsHint, ColumnsHint)
    ).

x_at_same_position([], []).
x_at_same_position([CellGrid|RestGrid], [CellCorrect|RestCorrect]) :-
    (CellGrid == 'X', CellCorrect == 'X' ;
     CellGrid \== 'X', CellCorrect \== 'X'), %Grid uses anon. vars and CorrectGrid "_" strings so a direct comp with == is not possible
    x_at_same_position(RestGrid, RestCorrect).


grid_diff([], [], []).
grid_diff([RowGrid|RestGrid], [RowCorrect|RestCorrect], [RowDiff|RestDiff]) :-
    maplist(compare_cell, RowGrid, RowCorrect, RowDiff),
    grid_diff(RestGrid, RestCorrect, RestDiff).

compare_cell(CellGrid, CellCorrect, CellDiff) :-
    (CellGrid == CellCorrect ->
        CellDiff = '\e[32mX\e[0m';
        (CellGrid == 'X' ->
           CellDiff = '\e[31mX\e[0m';
           (CellCorrect == 'X' ->
              CellDiff = '\e[90mX\e[0m';
              CellDiff = '_'
           )
        )
     ).


get_lengths(RowsHint, ColumnsHint, R, C) :-
    length(RowsHint, R),
    R > 0,
    length(ColumnsHint, C),
    C > 0.

read_cell(Col, Row) :-
    write('Enter Col:'),
    read(Col),
    write('Enter Row:'),
    read(Row).

valid_input(Col, Row, RowsHint, ColumnsHint) :-
    get_lengths(RowsHint, ColumnsHint, R, C),
    number(Col), number(Row),
    Col >= 0, Col < C,
    Row >= 0, Row < R.

mark_cell(Grid, R, C, Symbol, NewGrid) :-
    find_element_at(R, Grid, Row),
    replace_at_pos(Row, C, Symbol, NewRow),
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
    print_columns(ColumnsHint),nl.

print_rows([], []).
print_rows([Head|RestRows], [Hints|RestHints]) :-
    print_list(Head, '|'),
    print_list(Hints,' '), nl,
    print_rows(RestRows,RestHints).

print_list([],_).
print_list([Head|Tail], Seperator) :-
    print_element(Head, Seperator),
    write(Seperator),
    print_list(Tail, Seperator).

print_element(E, Sep) :- var(E) ->
                          (Sep == ' ' -> write(' ');write('_'));
                          write(E).

print_columns([]).
print_columns([[]|Tail]) :- write(' '), write(' '),print_columns(Tail). % in case of empty list, add whitespace
print_columns(Cols) :-
    maplist(first_elements, Cols, Firsts, Rest),
    print_list(Firsts, ' '), nl,
    print_columns(Rest).

first_elements([], _, []).
first_elements([Head|Rest],Head, Rest).

solve(Grid, RowsHint, ColumnsHint) :-
    transpose(Grid, Columns),!,
    maplist(valid_row, Grid, RowsHint),
    maplist(valid_row, Columns, ColumnsHint).

trim([],[]).
trim(List, List).
trim(['_'|List], Result) :- trim(List, Result).

transpose([],[]).
transpose([[]|Tail],Result) :- transpose(Tail, Result).
transpose(Grid, [Firsts|Result]) :-
    maplist(first_elements, Grid, Firsts, Rest),
    transpose(Rest, Result).

valid_row([],[]) :- !.
valid_row(Row, [BlockLen|[]]) :-
    trim(Row,Row2),
    valid_block(Row2, Row3, BlockLen),
    trim(Row3,Row4),
    valid_row(Row4, []).

valid_row(Row, [BlockLen|Hints]) :-
    trim(Row,Row2),
    valid_block(Row2, Row3, BlockLen),
    space(Row3, Row4),
    valid_row(Row4, Hints).

space(['_'|Row], Row).

valid_block(Row, Row, 0).
valid_block(['X'|Row], Rest, N) :-
    N > 0,
    N1 is N - 1,
    valid_block(Row, Rest, N1).

test(N) :- random_puzzle(N, R, C), nonogram(R, C, false).

user(N) :- random_puzzle(N, R, C), nonogram(R, C, true).


random_puzzle(N, R, C) :-
    findall(puzzle(N, _, R,  C), puzzle(N, _, R,  C), Puzzles),
    random_member(puzzle(N, _, R, C), Puzzles).

% Complexity 1
% This test should produce the following output:
%  x   x
%  x x
%    x
puzzle(1, 1, R, C) :-
    R = [[1,1],[2],[1]],
    C = [[2],[2],[1]].

puzzle(1, 2, R, C) :-
    R = [[2],[2],[1]],
    C = [[1,1],[2],[1]].

puzzle(1, 3, R, C) :-
    R = [[3],[1],[1]],
    C = [[1],[1, 1],[2]].


%Complexity 2
puzzle(2, 1, R, C) :-
    R = [[4],[2,1],[2],[2],[2]],
    C = [[1,1],[2,1],[1],[3,1],[1,1,1]].

puzzle(2, 2, R, C) :-
    R = [[3],[1,1,1],[3],[1,1],[1,1]],
    C = [[1,1],[1,2],[3],[1,2],[1,1]].

puzzle(2, 3, R, C) :-
    R = [[2,1],[1,3],[1,2],[3],[4], [1]],
    C = [[1],[5],[2],[5],[2,1],[2]].




% TODO: optimize solution as bigger puzzles will require more
% computation time, the program already struggles with this puzzle(9x8)
%
puzzle(3, 1, R, C) :-
    R = [[3],[2,1],[3,2],[2,2],[6],[1,5],[6],[1],[2]],
    C = [[1,2],[3,1],[1,5],[7,1],[5],[3],[4],[3]].

% TODO: define further puzzles for complexity 1 to 5

