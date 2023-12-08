/**
 * @program: prolog programm that solves nonogram puzzles
 * @date: 09.12.2023
 * @authors: - Richard Hoang (k12007790)
 *           - Sebastian Windsperger  (k12021114)
 *           - Julia Weißenbrunner (k12005535)
 */

% Solve the nonogram with according Rows- and Colum Hints either with User Input or automatically
nonogram(RowsHint, ColumnsHint, UserInput):-
    get_lengths(RowsHint, ColumnsHint, R, C),
    create_grid(R, C, '_', EmptyGrid),
    print_puzzle(EmptyGrid, RowsHint, ColumnsHint),
    (UserInput ->
       user_input(EmptyGrid, RowsHint, ColumnsHint, 'X');

       create_grid(R, C, Grid),
       solve(Grid, RowsHint, ColumnsHint, true),
       print_puzzle(Grid, RowsHint, ColumnsHint)
    ).

% ----- Control and process the user input -----
user_input(Grid, RowsHint, ColumnsHint, MarkSymbol) :-
    writeln('Enter grid cell (Col,Row):'),
    read_cell(Col, Row),
    valid_input(Col, Row, RowsHint, ColumnsHint),
    mark_cell(Grid, Row, Col, MarkSymbol, NewGrid),
    print_puzzle(NewGrid, RowsHint, ColumnsHint),
    write('Continue or undo a move? y/u/n'),
    read(Continue),
    continue_or_undo(Continue, NewGrid, RowsHint, ColumnsHint).

user_input(Grid, RowsHint, ColumnsHint, MarkSymbol) :-
    writeln('Invalid input.'),
    user_input(Grid, RowsHint, ColumnsHint, MarkSymbol).

% continue solving
continue_or_undo('y', Grid, RowsHint, ColumnsHint) :-
    user_input(Grid, RowsHint, ColumnsHint, 'X').

% clear cell
continue_or_undo('u', Grid, RowsHint, ColumnsHint) :-
    user_input(Grid, RowsHint, ColumnsHint, '_').

% User is finished - check if its correct
continue_or_undo(_, Grid, RowsHint, ColumnsHint) :-
    get_lengths(RowsHint, ColumnsHint, R, C),
    create_grid(R, C, CorrectGrid),
    solve(CorrectGrid, RowsHint, ColumnsHint, false),
    ((Grid == CorrectGrid) ->
        write('Correct solution. You win!');

        writeln('Wrong solution. Game Over!'),
        grid_diff(Grid, CorrectGrid, DiffGrid),
        print_puzzle(DiffGrid, RowsHint, ColumnsHint)
    ).

% calculate grid differences to enable printig grid with informations about which cell was wrong and which was correct and which was missing
grid_diff([], [], []).
grid_diff([RowGrid|RestGrid], [RowCorrect|RestCorrect], [RowDiff|RestDiff]) :-
    maplist(compare_cell, RowGrid, RowCorrect, RowDiff),
    grid_diff(RestGrid, RestCorrect, RestDiff).

compare_cell('X', 'X', '\e[32mX\e[0m').
compare_cell('X', '_', '\e[31mX\e[0m').
compare_cell('_', 'X', '\e[90mX\e[0m').
compare_cell('_', '_', '_').

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
% ----- Control and process the user input -----

% ----- Create Grid -----
create_grid(0, _, _, []).
create_grid(R, C, Fill, [Row|Rest]) :-
    R > 0,
    R1 is R-1,
    create_row(C, Fill, Row),
    create_grid(R1, C, Fill, Rest).

create_grid(0, _, []).
create_grid(R, C, [Row|Rest]) :- 
    R > 0,
    R1 is R-1,
    create_row(C, Row),
    create_grid(R1, C, Rest).

create_row(0, []).
create_row(N, [_|Tail]) :-
    N > 0,
    N1 is N-1,
    create_row(N1, Tail).

create_row(0, _, []).
create_row(N, Fill, [Fill|Tail]) :-
    N > 0,
    N1 is N-1,
    create_row(N1, Fill, Tail).
% ----- Create Grid -----

% ----- Printing Current Grid -----
print_puzzle(Grid, RowsHint, ColumnsHint) :-
    print_rows(Grid,RowsHint),
    print_columns(ColumnsHint),nl.

print_rows([], []).
print_rows([Row|RestRows], [Hints|RestHints]) :-
    print_list(Row, '|'),
    print_list(Hints,' '), nl,
    print_rows(RestRows,RestHints).

print_list([],_).
print_list([Head|Tail], Seperator) :-
    print_element(Head),
    write(Seperator),
    print_list(Tail, Seperator).

print_element(E) :- var(E) -> write(' ');write(E).

print_columns([]).
print_columns([[]|Tail]) :- write(' '), write(' '),print_columns(Tail). % in case of empty list, add whitespace
print_columns(Cols) :-
    maplist(first_elements, Cols, Firsts, Rest),
    print_list(Firsts, ' '), nl,
    print_columns(Rest).

first_elements([], _, []).
first_elements([Head|Rest],Head, Rest).
% ----- Printing Current Grid -----

% Optimizing strategy : Calculate all Posibilities for every Row and Column and sort it according to the number of Possibilities. 
% Therefore the Row/Column with the fewest is processed first -> at this row/column the probability is the highest to find the correct solution at the first try.
optimList([],[],[]).
optimList([Element|Elements], [Hint|Hints],[element(SolutionCount, Element, Hint)|Result]) :-
    length(Element, ElemLength),
    length(ElementCopy, ElemLength), % create a copy of row to NOT change the actual row variables (simply create a list with the same length)
    findall(ElementCopy, valid_row(Element, Hint), Solutions), % get all possibilites for current row
    length(Solutions, SolutionCount),
    optimList(Elements, Hints, Result).

% ----- solving algorithm -----
solve(Grid, RowsHint, ColumnsHint, Optimize) :-
    transpose(Grid, Columns),!,
    (Optimize ->
        append(RowsHint, ColumnsHint, AllHints),
        append(Grid, Columns, Elements),
        optimList(Elements, AllHints, OptimList),
        sort(OptimList, SortedOptimList),
        solve(SortedOptimList);

        maplist(valid_row, Grid, RowsHint),
        maplist(valid_row, Columns, ColumnsHint)
    ).

solve([]).
solve([element(_,Element,Hint)|Rest]) :-
    valid_row(Element, Hint),
    solve(Rest).

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
% ----- solving algorithm -----

% Examples with 5 different complexities
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


%Complexity 3
puzzle(3, 1, R, C) :-
    R = [[3],[2,1],[3,2],[2,2],[6],[1,5],[6],[1],[2]],
    C = [[1,2],[3,1],[1,5],[7,1],[5],[3],[4],[3]].


%Complexity 4
puzzle(4, 1, R, C) :-
    R = [[3],[4,2],[6,6],[6,2,1],[1,4,2,1],[6,3,2],[6,7],[6,8],[1,10],
                [1,10],[1,10],[1,1,4,4],[3,4,4],[4,4],[4,4]],
    C = [[1],[11],[3,3,1],[7,2],[7],[15],[1,5,7],[2,8],[14],[9],[1,6],
                [1,9],[1,9],[1,10],[12]].
    

% TODO: define further puzzles for complexity 1 to 5

