// Dati anagrafici per la generazione del codice fiscale
type DatiAnagrafici record {|
    string nome;
    string cognome;
    string dataNascita; // formato: YYYY-MM-DD
    string sesso; // "M" o "F"
    string codiceBelfiore; // codice catastale del comune di nascita (es. "H501" per Roma)
|};

// Risposta con il codice fiscale generato
type RispostaCodiceFiscale record {|
    string codiceFiscale;
    string nome;
    string cognome;
    string dataNascita;
    string sesso;
    string codiceBelfiore;
|};

// Risposta di errore
type RispostaErrore record {|
    string messaggio;
    string dettaglio?;
|};
