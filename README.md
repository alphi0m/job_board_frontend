# Bacheca Annunci di Lavoro - Front-end Flutter

Applicazione mobile sviluppata in Flutter per il corso di Enterprise Mobile Application Development (A.A. 2025/2026).
Sviluppato da Alfio Marra ([@alphi0m](https://github.com/alphi0m)).

## Descrizione del progetto
L'applicazione implementa il client mobile per la gestione della bacheca annunci di lavoro, interfacciandosi con il backend REST locale.

L'app copre i tre scenari d'uso richiesti dalle specifiche della task:
1. **Scenario 1 (Pubblicazione annuncio)**: registrazione di una nuova azienda, login, accesso all'area riservata e creazione/pubblicazione di una nuova offerta di lavoro.
2. **Scenario 2 (Candidatura)**: consultazione della bacheca pubblica da parte del candidato non autenticato, selezione di un annuncio, compilazione dei dati anagrafici e caricamento del CV in formato PDF tramite file picker nativo.
3. **Scenario 3 (Consultazione candidature e logout)**: accesso dell'azienda alla lista dei propri annunci, selezione delle candidature pervenute, apertura del file PDF del curriculum tramite il visualizzatore nativo del dispositivo e successivo logout con blocco dell'area riservata.

## Tecnologie e librerie utilizzate
- **Flutter SDK** (Material 3 con supporto dinamico Light/Dark Theme)
- **provider**: per la gestione dello stato dell'applicazione e della sessione
- **http**: per le comunicazioni REST e l'upload multipart dei file
- **file_picker**: per la selezione del file PDF del curriculum dalla memoria del dispositivo
- **open_filex** e **url_launcher**: per l'apertura e visualizzazione dei PDF
- **shared_preferences**: per la persistenza del token di sessione, del tema e dell'indirizzo del server

## Configurazione e avvio

### Prerequisiti
- Flutter SDK 3.x installato e configurato
- Un emulatore, browser Chrome o uno smartphone connesso in debug (Android / iOS)

### Comandi
1. Clonare il repository:
```bash
git clone https://github.com/alphi0m/job_board_frontend.git
cd job_board_frontend
```

2. Scaricare le dipendenze:
```bash
flutter pub get
```

3. Eseguire l'applicazione:
```bash
# Per avviare su smartphone o emulatore:
flutter run

# Per avviare su Chrome:
flutter run -d chrome
```

## Connessione con il backend locale
Per permettere all'app su smartphone fisico di raggiungere il server in esecuzione sul computer:
- Assicurarsi che computer e smartphone siano connessi alla stessa rete Wi-Fi.
- All'interno dell'app è presente un pulsante delle impostazioni di rete nella barra superiore della bacheca pubblica, che consente di impostare l'indirizzo IP del computer (ad esempio `http://192.168.1.X:8000`). L'impostazione viene memorizzata in cache locale.
- Per l'emulatore Android l'indirizzo predefinito è `http://10.0.2.2:8000`, mentre per iOS Simulator o Chrome è `http://localhost:8000`.

## Test
Per eseguire i test unitari sui modelli:
```bash
flutter test
```
