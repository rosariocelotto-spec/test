import ballerina/http;

listener http:Listener ep = check new http:Listener(8080);

service /api on ep {

    # Genera il codice fiscale a partire dai dati anagrafici
    resource function post codice\-fiscale(@http:Payload DatiAnagrafici dati)
            returns RispostaCodiceFiscale|http:BadRequest|http:InternalServerError {
        string|error risultato = generaCodiceFiscale(dati);
        if risultato is error {
            http:BadRequest risposta = {
                body: <RispostaErrore>{
                    messaggio: "Dati non validi",
                    dettaglio: risultato.message()
                }
            };
            return risposta;
        }
        return {
            codiceFiscale: risultato,
            nome: dati.nome,
            cognome: dati.cognome,
            dataNascita: dati.dataNascita,
            sesso: dati.sesso.toUpperAscii(),
            codiceBelfiore: dati.codiceBelfiore.toUpperAscii()
        };
    }

    # Verifica la validità strutturale di un codice fiscale
    resource function get codice\-fiscale/[string codiceFiscale]()
            returns record {|boolean valido; string codiceFiscale;|}|http:BadRequest {
        string cfUpper = codiceFiscale.toUpperAscii();
        boolean isValido = validaCodiceFiscale(cfUpper);
        if !isValido {
            http:BadRequest risposta = {
                body: <RispostaErrore>{
                    messaggio: "Codice fiscale non valido",
                    dettaglio: "Il codice '" + codiceFiscale + "' non rispetta il formato del codice fiscale italiano"
                }
            };
            return risposta;
        }
        return {valido: true, codiceFiscale: cfUpper};
    }
}
