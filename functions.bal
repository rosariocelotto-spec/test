import ballerina/lang.regexp;

// Tabella vocali e consonanti per nome/cognome
final string[] vocali = ["A", "E", "I", "O", "U"];

// Tabella mesi per codice fiscale
final map<string> codiciMese = {
    "01": "A", "02": "B", "03": "C", "04": "D",
    "05": "E", "06": "H", "07": "L", "08": "M",
    "09": "P", "10": "R", "11": "S", "12": "T"
};

// Tabella caratteri dispari (posizione 1,3,5,7,9,11,13,15 - 1-indexed)
final map<int> valoriDispari = {
    "0": 1, "1": 0, "2": 5, "3": 7, "4": 9, "5": 13, "6": 15, "7": 17, "8": 19, "9": 21,
    "A": 1, "B": 0, "C": 5, "D": 7, "E": 9, "F": 13, "G": 15, "H": 17, "I": 19, "J": 21,
    "K": 2, "L": 4, "M": 18, "N": 20, "O": 11, "P": 3, "Q": 6, "R": 8, "S": 12, "T": 14,
    "U": 16, "V": 10, "W": 22, "X": 25, "Y": 24, "Z": 23
};

// Tabella caratteri pari (posizione 2,4,6,8,10,12,14,16 - 1-indexed)
final map<int> valoriPari = {
    "0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9,
    "A": 0, "B": 1, "C": 2, "D": 3, "E": 4, "F": 5, "G": 6, "H": 7, "I": 8, "J": 9,
    "K": 10, "L": 11, "M": 12, "N": 13, "O": 14, "P": 15, "Q": 16, "R": 17, "S": 18, "T": 19,
    "U": 20, "V": 21, "W": 22, "X": 23, "Y": 24, "Z": 25
};

// Alfabeto per il carattere di controllo
final string alfabetoControllo = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

// Estrae consonanti e vocali da una stringa
function estraiConsonantiVocali(string testo) returns [string[], string[]] {
    string testoUpper = testo.toUpperAscii();
    string[] consonanti = [];
    string[] vocaliTrovate = [];
    string:RegExp letterePattern = re `[A-Z]`;
    regexp:Span[] lettere = letterePattern.findAll(testoUpper);
    foreach regexp:Span span in lettere {
        string lettera = span.substring();
        boolean isVocale = vocali.indexOf(lettera) != ();
        if isVocale {
            vocaliTrovate.push(lettera);
        } else {
            consonanti.push(lettera);
        }
    }
    return [consonanti, vocaliTrovate];
}

// Calcola il codice per il cognome (3 caratteri)
function calcolaCognome(string cognome) returns string {
    [string[], string[]] estratti = estraiConsonantiVocali(cognome);
    string[] consonanti = estratti[0];
    string[] vocaliTrovate = estratti[1];
    string[] caratteri = [];
    foreach string c in consonanti {
        caratteri.push(c);
    }
    foreach string v in vocaliTrovate {
        caratteri.push(v);
    }
    // Riempi con X se meno di 3 caratteri
    while caratteri.length() < 3 {
        caratteri.push("X");
    }
    return caratteri[0] + caratteri[1] + caratteri[2];
}

// Calcola il codice per il nome (3 caratteri)
function calcolaNome(string nome) returns string {
    [string[], string[]] estratti = estraiConsonantiVocali(nome);
    string[] consonanti = estratti[0];
    string[] vocaliTrovate = estratti[1];
    // Se il nome ha 4 o più consonanti, usa la 1a, 3a e 4a
    if consonanti.length() >= 4 {
        return consonanti[0] + consonanti[2] + consonanti[3];
    }
    string[] caratteri = [];
    foreach string c in consonanti {
        caratteri.push(c);
    }
    foreach string v in vocaliTrovate {
        caratteri.push(v);
    }
    while caratteri.length() < 3 {
        caratteri.push("X");
    }
    return caratteri[0] + caratteri[1] + caratteri[2];
}

// Calcola anno, mese e giorno per il codice fiscale
function calcolaDataNascita(string dataNascita, string sesso) returns string|error {
    string:RegExp dataPattern = re `-`;
    string[] parti = dataPattern.split(dataNascita);
    if parti.length() != 3 {
        return error("Formato data non valido. Usare YYYY-MM-DD");
    }
    string annoStr = parti[0];
    string meseStr = parti[1];
    string giornoStr = parti[2];
    // Ultime 2 cifre dell'anno
    string anno = annoStr.substring(2, 4);
    // Codice mese
    string? codiceMeseVal = codiciMese[meseStr];
    if codiceMeseVal is () {
        return error("Mese non valido: " + meseStr);
    }
    string mese = codiceMeseVal;
    // Giorno: per le donne si aggiunge 40
    int giornoInt = check int:fromString(giornoStr);
    string sessoUpper = sesso.toUpperAscii();
    if sessoUpper == "F" {
        giornoInt = giornoInt + 40;
    }
    string giorno = giornoInt < 10 ? "0" + giornoInt.toString() : giornoInt.toString();
    return anno + mese + giorno;
}

// Calcola il carattere di controllo
function calcolaCarattereControllo(string codiceParziale) returns string|error {
    if codiceParziale.length() != 15 {
        return error("Il codice parziale deve avere 15 caratteri");
    }
    int somma = 0;
    foreach int i in 0 ..< 15 {
        string carattere = codiceParziale.substring(i, i + 1);
        // Posizioni dispari (1-indexed): 1,3,5,7,9,11,13,15 → indici 0,2,4,6,8,10,12,14
        if i % 2 == 0 {
            int? valoreDispari = valoriDispari[carattere];
            if valoreDispari is () {
                return error("Carattere non valido: " + carattere);
            }
            somma = somma + valoreDispari;
        } else {
            int? valorePari = valoriPari[carattere];
            if valorePari is () {
                return error("Carattere non valido: " + carattere);
            }
            somma = somma + valorePari;
        }
    }
    int indiceControllo = somma % 26;
    return alfabetoControllo.substring(indiceControllo, indiceControllo + 1);
}

// Funzione principale: genera il codice fiscale
function generaCodiceFiscale(DatiAnagrafici dati) returns string|error {
    // Validazione sesso
    string sessoUpper = dati.sesso.toUpperAscii();
    if sessoUpper != "M" && sessoUpper != "F" {
        return error("Il sesso deve essere 'M' o 'F'");
    }
    // Calcolo parti
    string parteCognome = calcolaCognome(dati.cognome);
    string parteNome = calcolaNome(dati.nome);
    string parteData = check calcolaDataNascita(dati.dataNascita, sessoUpper);
    string codiceBelfioreUpper = dati.codiceBelfiore.toUpperAscii();
    if codiceBelfioreUpper.length() != 4 {
        return error("Il codice Belfiore deve avere 4 caratteri (es. H501)");
    }
    // Codice parziale (15 caratteri)
    string codiceParziale = parteCognome + parteNome + parteData + codiceBelfioreUpper;
    // Carattere di controllo
    string carattereControllo = check calcolaCarattereControllo(codiceParziale);
    return codiceParziale + carattereControllo;
}

// Valida la struttura di un codice fiscale (16 caratteri, pattern corretto)
function validaCodiceFiscale(string codiceFiscale) returns boolean {
    string cfUpper = codiceFiscale.toUpperAscii();
    if cfUpper.length() != 16 {
        return false;
    }
    string:RegExp cfPattern = re `^[A-Z]{6}[0-9LMNPQRSTUV]{2}[ABCDEHLMPRST]{1}[0-9LMNPQRSTUV]{2}[A-Z]{1}[0-9LMNPQRSTUV]{3}[A-Z]{1}$`;
    return cfPattern.isFullMatch(cfUpper);
}
