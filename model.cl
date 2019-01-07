achievement(true, houseBuilt).
achievement(true, frame).
achievement(frame, interiorExterior).
achievement(frame, interior).
achievement(frame, exterior).
achievement(true, sitePrepared).
achievement(sitePrepared, wallsBuilt).
achievement(frame, wallsPainted).
achievement(wallsPainted, windowsFitted).
achievement(frame, lawnInstalled).
achievement(frame, concretePoured).

contains(achievement(true, houseBuilt), achievement(true, frame)).
contains(achievement(true, houseBuilt), achievement(frame, interiorExterior)).
contains(achievement(frame, interiorExterior), achievement(frame, interior)).
contains(achievement(frame, interiorExterior), achievement(frame, exterior)).
contains(achievement(true, frame), achievement(true, sitePrepared)).
contains(achievement(true, frame), achievement(sitePrepared, wallsBuilt)).
contains(achievement(frame, interior), achievement(frame, wallsPainted)).
contains(achievement(frame, interior), achievement(wallsPainted, windowsFitted)).
contains(achievement(frame, exterior), achievement(frame, lawnInstalled)).
contains(achievement(frame, exterior), achievement(frame, concretePoured)).

typeAnd(achievement(true, houseBuilt)).
typeAnd(achievement(frame, interiorExterior)).
typeAnd(achievement(true, frame)).
typeAnd(achievement(frame, interior)).
typeOr(achievement(frame, exterior)).

a(contractor, owner, achievement(true, houseBuilt)).
a(frameManager, contractor, achievement(true, frame)).
a(interiorManager, contractor, achievement(frame, interiorExterior)).
a(interiorManager, interiorManager, achievement(frame, interior)).
a(exteriorManager, interiorManager, achievement(frame, exterior)).
a(sitePreparer, frameManager, achievement(true, sitePrepared)).
a(bricklayer, frameManager, achievement(sitePrepared, wallsBuilt)).
a(painter, interiorManager, achievement(frame, wallsPainted)).
a(fitter, interiorManager, achievement(wallsPainted, windowsFitted)).

% Accountability implies just expectation
exp(X,Y,A) :- a(X,Y,A).

% If someone is accountable towards me for an achievement, I have control over it
ctrl(X,A) :- a(_,X,A).

% If I am accountable for an atomic achievement and no one is accountable towards me for it I must be able to realize it
canRealize(X,A) :- a(X,_,A), not a(_,X,A),atomic(A).

% If I can realize an achievement, I have control over it
ctrl(X,A) :- canRealize(X,A).

% An achievement that contains other achievements is a complex achievement
complex(achievement(P,Q)) :- achievement(P,Q), contains(achievement(P,Q),_).

% An achievement that does not contain other achievements is an atomic achievement
atomic(achievement(P,Q)) :- achievement(P,Q), not contains(achievement(P,Q),_).

% An achievement cannot be both complex and atomic
:- complex(A), atomic(A).

% An achievement must be complex or atomic
:- achievement(P,Q), not complex(achievement(P,Q)), not atomic(achievement(P,Q)).

% The contains relation is asymmetric
:- contains(A1,A2),contains(A2,A1).

% If an achievement is of type AND, it must contain exactly two subgoals
2 { containsDef(A,A1) : contains(A,A1) } 2 :- typeAnd(A).
:- contains(A,A1), not containsDef(A,A1), typeAnd(A).

% If an achievement is of type OR, it must contain exactly two subgoals
2 { containsDef(A,A1) : contains(A,A1) } 2 :- typeOr(A).
:- contains(A,A1), not containsDef(A,A1), typeOr(A).

% Only complex achievements can be of type OR
:- typeOr(achievement(P,Q)), not complex(achievement(P,Q)).

% Only complex achievements can be of type AND
:- typeAnd(achievement(P,Q)), not complex(achievement(P,Q)).

% A principal cannot directly realize a complex achievement
:- complex(A), canRealize(_,A).

% If I control a subgoal of a complex achievement with type OR, I control the complex achievement too
ctrl(X,A) :- typeOr(A), contains(A,A1), ctrl(X,A1).

% If I control both subgoals of a complex achievement with type AND, I control the complex achievement too
ctrl(X,A) :- typeAnd(A), contains(A,A1), contains(A,A2), ctrl(X,A1), ctrl(X,A2), A1!=A2.

canRealize(X,A1) :- a(X,_,A), typeAnd(A), contains(A,A1),not a(_,X,A1),atomic(A1).
:- typeAnd(A), a(X,_,A), contains(A, A1), not ctrl(X, A1).

0 {canRealize(X,A1): a(X,_,A), not a(_,X,A1), contains(A,A1), atomic(A1)} 2 :- typeOr(A).

% If I am accountable for an achievement with type OR, I must control at lest one of the subgoals
:- typeOr(A), a(X,_,A), contains(A, A1), contains(A, A2), A1!=A2, not ctrl(X, A1), not ctrl(X, A2).

% It is inconsistent that a principal is accountable for an achievement and he/she does not have control over it
:- a(X,_,A), not ctrl(X,A).
