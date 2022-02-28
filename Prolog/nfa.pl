% nfa.pl

% Dynamic

:- dynamic nfa_initial/2.
:- dynamic nfa_final/2.
:- dynamic nfa_delta/4.


% is_regexp(RE)

op(seq).
op(or).
op(star).
op(plus).

is_regexp(RE) :-
    atomic(RE),
    not(op(RE)),
    !.

is_regexp(RE) :-
    not(is_list(RE)),
    RE =.. [H|T],
    op(H),
    check_op(T),
    is_regexp([H|T]),
    !.

is_regexp(RE) :-
    not(is_list(RE)),
    RE =.. [H|_],
    not(op(H)).

is_regexp([star|[T]]) :-
    is_regexp(T),
    !.

is_regexp([plus|[T]]) :-
    is_regexp(T),
    !.

is_regexp([or|T]) :-
    is_regexp(T),
    !.

is_regexp([seq|T]) :-
    is_regexp(T),
    !.

is_regexp([H|T]) :-
    not(op(H)),
    is_regexp(H),
    is_regexp(T).

check_op([]) :- !.

check_op([H|T]) :-
    not(op(H)),
    check_op(T).


% nfa_regexp_comp(FA_Id, RE)

nfa_regexp_comp(FA_Id, RE) :-
    nonvar(FA_Id),
    not(nfa_initial(FA_Id, _)),
    is_regexp(RE),
    RE =.. L,
    gensym(q, IN),
    assert(nfa_initial(FA_Id, IN)),
    gensym(q, FIN),
    assert(nfa_final(FA_Id, FIN)),
    nfa_regexp_comp(FA_Id, L, IN, FIN),
    !.

nfa_regexp_comp(FA_Id, [seq|T], IN, FIN):-
    nfa_regexp_comp_seq(FA_Id, T, IN, FIN),
    !.

nfa_regexp_comp(FA_Id, [star|T], IN, FIN):-
    nfa_regexp_comp_star(FA_Id, T, IN, FIN),
    !.

nfa_regexp_comp(FA_Id, [plus|T], IN, FIN):-
    nfa_regexp_comp_plus(FA_Id, T, IN, FIN),
    !.

nfa_regexp_comp(FA_Id, [or|T], IN, FIN):-
    nfa_regexp_comp_or(FA_Id, T, IN, FIN),
    !.

nfa_regexp_comp(FA_Id, [H|T], IN, FIN):-
    L =.. [H|T],
    assert(nfa_delta(FA_Id, IN, L, FIN)).

nfa_regexp_comp(FA_Id, [X], IN, FIN) :-
    assert(nfa_delta(FA_Id, IN, X, FIN)).

nfa_regexp_comp_star(FA_Id, [X], IN, FIN) :-
    X =.. L,
    gensym(q, STATE1),
    gensym(q, STATE2),
    nfa_regexp_comp(FA_Id, L, STATE1, STATE2),
    assert(nfa_delta(FA_Id, IN, epsilon, FIN)),
    assert(nfa_delta(FA_Id, IN, epsilon, STATE1)),
    assert(nfa_delta(FA_Id, STATE2, epsilon, STATE1)),
    assert(nfa_delta(FA_Id, STATE2, epsilon, FIN)).

nfa_regexp_comp_plus(FA_Id, [X], IN, FIN) :-
    X =.. L,
    gensym(q, STATE1),
    gensym(q, STATE2),
    nfa_regexp_comp(FA_Id, L, STATE1, STATE2),
    assert(nfa_delta(FA_Id, IN, epsilon, STATE1)),
    assert(nfa_delta(FA_Id, STATE2, epsilon, STATE1)),
    assert(nfa_delta(FA_Id, STATE2, epsilon, FIN)).

nfa_regexp_comp_seq(FA_Id, [X], IN, FIN) :-
    X =.. L,
    nfa_regexp_comp(FA_Id, L, IN, FIN),
    !.

nfa_regexp_comp_seq(FA_Id, [H|T], IN ,FIN) :-
    gensym(q, STATE),
    nfa_regexp_comp_seq(FA_Id, [H], IN, STATE),
    gensym(q, STATE2),
    assert(nfa_delta(FA_Id, STATE, epsilon, STATE2)),
    nfa_regexp_comp_seq(FA_Id, T, STATE2, FIN).


nfa_regexp_comp_or(FA_Id, [X], IN, FIN) :-
   X =..L,
   gensym(q, STATE),
   assert(nfa_delta(FA_Id, IN, epsilon, STATE)),
   gensym(q, STATE2),
   nfa_regexp_comp(FA_Id, L, STATE, STATE2),
   assert(nfa_delta(FA_Id, STATE2, epsilon, FIN)).

nfa_regexp_comp_or(FA_Id, [H|T], IN ,FIN) :-
   nfa_regexp_comp_or(FA_Id, [H], IN, FIN),
   nfa_regexp_comp_or(FA_Id, T, IN, FIN).


% nfa_test(FA_Id, Input)

nfa_test(FA_Id, Input) :-
    nonvar(FA_Id),
    nonvar(Input),
    nfa_initial(FA_Id, IN),
    nfa_test(FA_Id, Input, IN).

nfa_test(FA_Id, [H|T], STATE) :-
    nfa_delta(FA_Id, STATE, H, STATE2),
    nfa_test(FA_Id, T, STATE2),
    !.

nfa_test(FA_Id, Input, STATE) :-
    nfa_delta(FA_Id, STATE, epsilon, STATE2),
    nfa_test(FA_Id, Input, STATE2),
    !.

nfa_test(FA_Id, [], STATE) :-
    nfa_final(FA_Id, STATE).


% nfa_clear, nfa_clear(FA_id)

nfa_clear :-
    nfa_clear(_).

nfa_clear(FA_Id) :-
    retractall(nfa_delta(FA_Id, _, _, _)),
    retractall(nfa_initial(FA_Id, _)),
    retractall(nfa_final(FA_Id, _)).


% List automa

nfa_list :-
    nfa_list(_).

nfa_list(FA_id) :-
    listing(nfa_delta(FA_id, _, _, _)),
    listing(nfa_initial(FA_id, _)),
    listing(nfa_final(FA_id, _)).


