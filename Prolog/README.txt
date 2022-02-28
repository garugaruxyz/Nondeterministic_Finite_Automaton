Richiesta del progetto : 

L'applicazione è un compilatore di RE, costruisce l' E-NFA e dato un input controlla se
l'input è accettato o meno dall' E-NFA.


Predicati Principali :

1. is_regexp(RE) restituisce vero quando RE è un’espressione regolare. 
 I casi base sono numeri e atomi (in genere anche ciò che soddisfa atomic/1), sono le 
 espressioni regolari più semplici.
 Nella realizzazione di is_regexp(RE) abbiamo considerato che i simboli dell'alfabeto 
 non possono essere i funtori riservati, ad esempio star(or) non deve essere accettato.
 Nel caso non sia una RE semplice, tramite il predicato UNIV (=..), trasformiamo il termine 
 in una lista se non è una lista. Se la lista in testa ha un funtore riservato controlla che la
 coda della lista non contenga come simboli dell'alfabeto un funture riservato. 
 Nel caso in cui la testa non contenga un funtore tramite le varie unificazioni verifica se 
 rispetta le regole. 
 Vengono accettati anche simboli composti come baz(42) e baz(or).

2. nfa_regexp_comp(FA_Id, RE) è vero quando RE è compilabile in un automa, che 
 viene inserito nella base dati del Prolog. FA_Id diventa un identificatore per 
 l’automa. Nella realizzazione dell' automa è stato utilizzato un E-NFA e di conseguenza 
 verranno generati delle epsilon transizioni tra i vari stati.

3. nfa_test(FA_Id, Input) è vero quando l’input per l’automa identificato da FA_Id 
 viene consumato completamente e l’automa si trova in uno stato finale. Input è una 
 lista Prolog di simboli dell’alfabeto sopra definito.

4. nfa_clear, nfa_clear(FA_id) sono veri quando dalla base di dati Prolog sono rimossi
 tutti gli automi definiti (caso nfa_clear/0) o l’automa FA_id (caso nfa_clear/1).
 Essi utilizzano la retractall per eliminare dalla base di dati di Prolog i predicati
 relativi.

5. nfa_list, nfa_list(FA_id) mostrano i predicati nella base di dati di Prolog attraverso
 l'uso del listing. Nella realizzazione del progetto è richiesta la stampa delle delta, 
 dello stato iniziale e dello stato finale.


Predicati ausiliari :

Nei predicati principali is_regexp(RE) e nfa_regexp_comp(FA_Id, RE) viene utilizzato
il predicato Univ (=..). Esso, dato un termine, crea una lista con in testa l' operatore 
ed in coda il restante termine.

Sono stati definiti quattro predicati op che sono i quattro funtori riservati.

check_op(L) controlla che i simboli dell'alfabeto in L siano diversi dai funtori riservati.

nfa_regexp_comp_star genera il blocco dell' E-NFA relativo a star.

nfa_regexp_comp_plus genera il blocco dell' E-NFA relativo a plus

nfa_regexp_comp_seq genera il blocco dell' E-NFA relativo a seq.

nfa_regexp_comp_or genera il blocco dell' E-NFA relativo all' or.

I diversi predicati di creazione dell' E-NFA utilizzano il predicato gensym per generare
il nome dello stato, ad esempio nfa_initial(42, q42) nfa_final(42, q43).