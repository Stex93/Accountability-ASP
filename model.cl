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
%a(me, exteriorManager, achievement(frame, lawnInstalled)).

%-ctrlSelf(painter,achievement(frame,wallsPainted)).
%-ctrlSelf(interiorManager,achievement(frame,wallsPainted)).
%ctrlSelf(exteriorManager,achievement(frame, lawnInstalled)).
%ctrlSelf(exteriorManager,achievement(frame, concretePoured)).

% Essere accountable implica che ci sia aspettativa.
exp(X,Y,A) :- a(X,Y,A).

% Se qualcuno è accountable verso di me per un achievement io ho il controllo su di esso.
ctrl(X,A) :- a(_,X,A).

% Se sono accountable per un achievement atomico e nessuno è accountable verso di me, allora devo averne controllo diretto.
canRealize(X,A) :- a(X,_,A), not a(_,X,A),atomic(A).

% Avere controllo diretto implica avere controllo.
ctrl(X,A) :- canRealize(X,A).

% Un achievement che ne contiene altri è complesso.
complex(achievement(P,Q)) :- achievement(P,Q), contains(achievement(P,Q),_).

% Un achievement che non ne contiene altri è atomico.
atomic(achievement(P,Q)) :- achievement(P,Q), not contains(achievement(P,Q),_).

% Un achievement non può essere sia complesso che atomico.
:- complex(A), atomic(A).

% E' inconsistente che un achievement non sia né atomico né complesso.
:- achievement(P,Q), not complex(achievement(P,Q)), not atomic(achievement(P,Q)).

% La relazione contains è asimmetrica.
:- contains(A1,A2),contains(A2,A1).

% Se un achievement è di tipo AND, deve contenere esattamente due sottogoal
2 { containsDef(A,A1) : contains(A,A1) } 2 :- typeAnd(A).
:- contains(A,A1), not containsDef(A,A1), typeAnd(A).

% Se un achievement è di tipo OR, deve contenere esattamente due sottogoal
2 { containsDef(A,A1) : contains(A,A1) } 2 :- typeOr(A).
:- contains(A,A1), not containsDef(A,A1), typeOr(A).

% Possono avere tipo OR solo gli achievement complessi
:- typeOr(achievement(P,Q)), not complex(achievement(P,Q)).

% Possono avere tipo AND solo gli achievement complessi
:- typeAnd(achievement(P,Q)), not complex(achievement(P,Q)).

% Non si può avere controllo diretto sugli achievement complessi.
:- complex(A), canRealize(_,A).

ctrl(X,A) :- typeOr(A), contains(A,A1), ctrl(X,A1).
ctrl(X,A) :- typeAnd(A), contains(A,A1), contains(A,A2), ctrl(X,A1), ctrl(X,A2), A1!=A2. %%%%%%%%%%%%%% aggiunto A1!=A2

%:- contains(A,A1), contains(A,A2), atomic(A1), typeOr(A), not ctrlSelf(_,A1), not ctrl(A2).

canRealize(X,A1) :- a(X,_,A), typeAnd(A), contains(A,A1),not a(_,X,A1),atomic(A1).
:- typeAnd(A), a(X,_,A), contains(A, A1), not ctrl(X, A1). %%%%%%%%%%%%% aggiunto

%ctrlSelf(X,A1) :- a(X,_,A), typeOr(A), contains(A,A1), contains(A,A2), not ctrl(X,A2),atomic(A1), A1!=A2.

0 {canRealize(X,A1): a(X,_,A), not a(_,X,A1), contains(A,A1), atomic(A1)} 2 :- typeOr(A). %%%%%%%%%%%%%% aggiunto

:- typeOr(A), a(X,_,A), contains(A, A1), contains(A, A2), A1!=A2, not ctrl(X, A1), not ctrl(X, A2). %%%%%%%%%%%%% aggiunto

:- a(X,_,A), not ctrl(X,A).
