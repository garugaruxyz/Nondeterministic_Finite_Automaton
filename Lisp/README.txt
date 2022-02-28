Richiesta del progetto : 

L'applicazione è un compilatore di RE, costruisce l' E-NFA e dato un input controlla se
l'input è accettato o meno dall' E-NFA.



Funzioni principali:

1. (is-regexp RE) ritorna vero quando RE è un’espressione regolare, falso (NIL) in caso 
 contrario.
 Un’espressione regolare può essere una Sexp, nel qual caso il suo primo elemento deve 
 essere diverso da seq, or, star, oppure plus.
 Controlla se RE è atomico o se è una lista, nel primo caso controlla che il simbolo 
 dell'alfabeto non sia un funtore riservato (check-op RE) e nel caso in cui sia una lista
 chiama la funzione ausiliare (is-regexpL RE).
 is-regexp fa uso di funzioni ausiliari dettagliate in seguito.
 Nella realizzazione di (is_regexp RE) abbiamo considerato che i simboli dell'alfabeto 
 non possono essere i funtori riservati ad esempio star(or) non deve essere accettato.
 Vengono accettati anche simboli composti come baz(42) e baz(or).

2. (nfa-regexp-comp RE) ritorna l’automa ottenuto dalla compilazione di RE, se è un’espressione
 regolare, altrimenti ritorna NIL.
 Se non può compilare la regexp RE, la funzione semplicemente ritorna NIL.
 nfa-regexp-comp fa uso di funzioni ausiliari dettagliate in seguito.
 L'automa ritornato è nel seguente formato/struttura:
  ((nfa initial) (nfa final) (liste delle nfa delta))
 Esempio:
  ((NFA-INITIAL #:G768) (NFA-FINAL #:G769) ((#:G768 A #:G770) (#:G770 EPSILON #:G771) (#:G771 B #:G769)))

3. (nfa-test FA Input) ritorna vero quando l’input per l’automa FA viene consumato completamente e 
 l’automa si trova in uno stato finale. 
 Input è una lista Lisp di simboli dell’alfabeto, se non è una lista ritorna NIL 
 Se FA non ha la corretta struttura di un automa come ritornato da nfa-regexp-comp, la funzione
 segnalerà un errore. 
 Altrimenti la funzione ritorna T se riesce a riconoscere l’Input o NIL se non lo riconosce.



Funzioni ausiliari:

(is-regexpL RE) controlla che l'arietà di ogni funtore sia rispettata e richiama check-op 
 e check-arg sul cdr della lista.

(check-arg RE) controlla gli argomenti di RE: 
 se l'argomento è una lista, controlla che anch'essa sia un'espressione regolare e che i suoi
 argomenti siano validi a sua volta.
 Se è un'espressione regolare e gli argomenti sono tutti validi restituisce vero (T), altrimenti
 restituisce falso (NIL).

(check-op RE) controlla che non ci siano simboli dell'alfabeto con i nomi dei funtori riservati: 
 se non sono presenti restituisce vero (T), falso (NIL) in caso contrario.

(comp-seq in RE fin) genera il blocco dell' E-NFA relativo a seq.

(comp-plus in RE fin) genera il blocco dell' E-NFA relativo a plus.

(comp-star in RE fin) genera il blocco dell' E-NFA relativo a star.

(comp-or in RE fin) genera il blocco dell' E-NFA relativo a or.

(comp in RE fin) controlla che se RE è un atomo o un simbolo composto crea la lista che collega 
 l'inizio (in) alla fine (fin), altrimenti
 se è un funtore richiama la rispettiva funzione (comp-seq, comp-plus, comp-star, comp-or)

(valid NFA), (check-nfa NFA) e (check-nfa-delta NFA) controllano che la struttura di NFA sia 
 sintatticamente corretta seguendo la struttura definita nel punto 2 tra le funzioni 
 principali, altrimenti ritorna un errore.
 
(nfa-test-control IN DELTA input FIN), (nfa-test-prova IN DELTA input FIN STATE)
(nfa-test-control1 IN DELTA input FIN STATE) e (nfa-test-state IN DELTA) in generale permettono di scorrere la 
 struttura dell'automa per verificare se l'input è riconosciuto o no dall'automa in questione.
In dettaglio : 

 nfa-test-control mette in relazione tutte le possibili computazioni per consumare l'input (tramite
 l'ausilio di nfa-test-control1 e nfa-test-prova) per arrivare allo stato finale.

 nfa-test-prova viene utilizzato per effettuare delle verifiche degli stati. Esso utilizza una (cond) con tre test :
       il primo restituisce T se ci si trova nello stato finale e l'input è completamente consumato;
       il secondo verifica se è possibile consumare il primo carattere dell'input e in caso di successo viene consumato il carattere 
	richiamando la funzione nfa-test-control sul cdr dell'input ed aggiornando il nuovo stato iniziale;
       il terzo verifica se lo stato in cui ci si trova possiede una epsilon mossa da effettuare.

 nfa-test-state viene utilizzato per creare una lista di tutte le possibili combinazioni di un determinato stato.
 La lista viene consumata in nfa-test-control.