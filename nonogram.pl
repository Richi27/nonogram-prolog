nonogram(RowsHint, ColumnsHint):-
    length(RowsHint, R),
    R > 0,
    length(ColumnsHint, C),
    C > 0,
    empty_grid(Grid, R, C),
    print_puzzle(Grid,RowsHint, ColumnsHint),
    solve(Grid, RowsHint, ColumnsHint, Solution),
    print_puzzle(Solution,RowsHint, ColumnsHint).

% TODO: very similiar to above predicate, mabye simplify
nonogram_user(RowsHint, ColumnsHint) :-
    length(RowsHint, R),
    R > 0,
    length(ColumnsHint, C),
    C > 0,
    empty_grid(Grid, R, C),
    print_puzzle(Grid,RowsHint, ColumnsHint),
    user_input(Grid, RowsHint, ColumnsHint).

% TODO: rework user input to check for valid input and retry if not valid and implement undo when asked if the user want to continue 
user_input(Grid, RowsHint, ColumnsHint) :- 
    nl,
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
        user_input(NewGrid, RowsHint, ColumnsHint); 
        valid_puzzle(NewGrid, RowsHint, ColumnsHint) -> write('Correct solution. You win!');write('Wrong solution. Game Over!')
    ).

continue('y').

% TODO: implement unmark_cell (because we have mark_cell, we automatically have the reverse function unmark_cell, but it has to be included in user input)

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
empty_row(['_'|Tail], N) :- 
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

print_element(E) :- var(E), !, write(' ').
print_element(E) :- write(E).

print_columns([]).
print_columns([[]|Tail]) :- write(' '), write(' '),print_columns(Tail). % in case of empty list, add whitespace
print_columns(Cols) :- 
    maplist(first_elements, Cols, Firsts, Rest),
    print_list(Firsts, ' '), nl,
    print_columns(Rest).

first_elements([], _, []).
first_elements([Head|Rest],Head, Rest).

solve(Grid, RowsHint, ColumnsHint, Solution) :-
    valid_puzzle(Grid, RowsHint, ColumnsHint),
    labeling_solution(Grid),
    Solution = Grid.

valid_puzzle(Grid, RowsHint, ColumnsHint) :-
    maplist(valid_row, Grid, RowsHint),
    transpose(Grid, Columns),
    maplist(valid_row, Columns, ColumnsHint).

split([],_,[]).
split(List, Spliterator, [List]) :- not_in_list(Spliterator, List).
split([Spliterator|List], Spliterator, Result) :- split(List, Spliterator, Result).
split(List, Spliterator, [Sublist|Result]) :-
   append(Sublist, [Spliterator|Rest], List),
   split(Rest, Spliterator, Result).

transpose([],[]).
transpose([[]|Tail],Result) :- transpose(Tail, Result).
transpose(Grid, [Firsts|Result]) :-
    maplist(first_elements, Grid, Firsts, Rest),
    transpose(Rest, Result).

valid_row(Row, Hints) :-
    split(Row,'_',Sublists),
    length(Sublists, SubLen),
    length(Hints, SubLen),
    maplist(length,Sublists, Hints), !.

not_in_list(_, []).
not_in_list(Element, [Head | Tail]) :-
    Element \= Head,
    not_in_list(Element, Tail).

test(N) :- puzzle(N, R, C), nonogram(R,C).

user(N) :- puzzle(N,R,C), nonogram_user(R,C).

puzzle(1, R, C) :- 
    R = [[1,1],[2],[1]],
    C = [[2],[2],[1]].

puzzle(2, R, C) :- 
    R = [[4],[2,1],[2],[2],[2]],
    C = [[1,1],[2,1],[1],[3,1],[1,1,1]].

puzzle(3, R, C) :- 
    R = [[3],[2,1],[3,2],[2,2],[6],[1,5],[6],[1],[2]], 
    C = [[1,2],[3,1],[1,5],[7,1],[5],[3],[4],[3]]. 

% TODO: define further puzzles, maybe arrange them after complexity 1 to 5
% when the user selects a difficulty one of many puzzles of that difficulty gets randomly selected
