# Job Board App (Bacheca Annunci di Lavoro - Front-end Flutter)

Applicazione mobile sviluppata in **Flutter** per il corso di **Enterprise Mobile Application Development**.
L'app permette alle aziende di registrarsi, accedere alla propria area riservata e pubblicare offerte di lavoro, e ai candidati (senza autenticazione) di consultare la bacheca e candidarsi allegando il proprio Curriculum Vitae in formato PDF.

---

## 📱 Requisiti e Funzionalità
- **R1 – Registrazione Azienda**: Creazione di un profilo aziendale con nome, email e password.
- **R2 – Login Azienda**: Accesso con credenziali e memorizzazione sicura del token di sessione.
- **R3 – Logout Azienda**: Disconnessione e blocco dell'accesso all'area riservata.
- **R4 – Pubblicazione Annuncio**: Form per creare un'offerta di lavoro con titolo, sede e descrizione.
- **R5 – Consultazione Bacheca (Candidato)**: Elenco offerte disponibili con ricerca/filtri in tempo reale e schermata di dettaglio offerta.
- **R6 – Candidatura (Candidato)**: Invio candidatura compilando generalità e allegando il file PDF del curriculum tramite file picker nativo.
- **R7 – Consultazione Candidature (Azienda)**: Elenco candidature ricevute per ciascun annuncio con apertura diretta del PDF del CV allegato.

---

## 🎬 Scenari di Consegna (Dimostrabili per i Video S1-S3)

### Scenario 1 (S1) – Pubblicare un annuncio
1. All'avvio dell'app, toccare **Area Aziende** e selezionare **Registrati ora**.
2. Inserire i dati dell'azienda (es. *TechCorp*, email e password) e confermare la creazione dell'account.
3. Effettuare il login con email e password: l'app autentica l'azienda e mostra l'**Area Riservata Azienda**.
4. Toccare il pulsante **Nuovo Annuncio**, compilare titolo e descrizione, quindi confermare la pubblicazione.
5. L'annuncio viene pubblicato e compare immediatamente nella bacheca visibile a tutti.

### Scenario 2 (S2) – Candidarsi a un annuncio
1. Aprire l'app senza effettuare alcun login (visuale pubblica per i candidati).
2. L'app mostra l'elenco degli annunci pubblicati.
3. Selezionare l'annuncio desiderato per visualizzarne il dettaglio.
4. Toccare **Candidati a questo annuncio**, compilare nome, cognome ed email.
5. Toccare **Seleziona File PDF** e scegliere il curriculum dal telefono.
6. Premere **Conferma e Invia Candidatura**: l'app invia i dati e il file al server locale e mostra il messaggio di conferma.

### Scenario 3 (S3) – Consultare le candidature e uscire
1. Effettuare il login con l'account aziendale che ha ricevuto candidature.
2. Nella dashboard, aprire l'elenco degli annunci e selezionare quello con candidature.
3. Selezionare il candidato dall'elenco per visualizzarne i dettagli anagrafici.
4. Premere **Apri Curriculum Vitae (PDF)**: il file PDF del candidato viene scaricato dal server e visualizzato nel lettore PDF nativo dello smartphone.
5. Tornare alla dashboard e toccare l'icona di **Logout** in alto a destra.
6. L'app torna alla schermata pubblica e l'area riservata non è più accessibile.

---

## ⚙️ Configurazione Connessione Smartphone ↔ Server Locale
Durante la demo o la registrazione video con il tuo smartphone fisico:
1. Assicurati che lo smartphone e il computer dove gira il backend siano connessi alla **stessa rete Wi-Fi**.
2. Trova l'indirizzo IP locale del tuo computer (su Mac: `ipconfig getifaddr en0` oppure Preferenze di Sistema -> Rete).
3. Nell'app Flutter, tocca l'icona **Impostazioni di Rete** (in alto a destra nella bacheca) e imposta l'URL del server (es. `http://192.168.1.50:8000`).
4. L'app memorizza l'URL in cache (`SharedPreferences`), pronto per tutte le chiamate.

---

## 🚀 Avvio dell'Applicazione

### Prerequisiti
- Flutter SDK 3.x
- Dispositivo Android/iOS collegato (o emulatore/simulatore)

### Comandi
```bash
# 1. Scaricare le dipendenze
flutter pub get

# 2. Verificare l'assenza di errori
flutter analyze

# 3. Eseguire i test automatici sui modelli
flutter test

# 4. Avviare l'app sul dispositivo
flutter run
```

---

## 📦 Struttura del Progetto
```text
job_board_frontend/
├── lib/
│   ├── config/
│   │   └── api_config.dart          # Gestione dinamica dell'URL del server
│   ├── models/
│   │   ├── company.dart             # Modello dati Azienda
│   │   ├── job.dart                 # Modello dati Offerta di Lavoro
│   │   └── application.dart         # Modello dati Candidatura
│   ├── services/
│   │   ├── api_service.dart         # Client HTTP con Multipart e Token Injection
│   │   ├── auth_service.dart        # Servizio Login/Registrazione e SharedPreferences
│   │   ├── jobs_service.dart        # Servizio Annunci pubblici e aziendali
│   │   └── applications_service.dart# Servizio Invio e Apertura PDF
│   ├── providers/
│   │   ├── auth_provider.dart       # Gestione stato autenticazione aziendale
│   │   └── jobs_provider.dart       # Gestione stato annunci e candidature
│   ├── screens/
│   │   ├── public/
│   │   │   ├── jobs_board_screen.dart # Bacheca pubblica (Home - R5)
│   │   │   ├── job_detail_screen.dart # Dettaglio annuncio (R5)
│   │   │   └── apply_job_screen.dart  # Form candidatura con file picker (R6)
│   │   ├── auth/
│   │   │   ├── login_screen.dart      # Login azienda (R2)
│   │   │   └── register_screen.dart   # Registrazione azienda (R1)
│   │   └── company/
│   │       ├── company_dashboard_screen.dart # Area riservata "I miei annunci" (R4, R7, R3)
│   │       ├── create_job_screen.dart        # Form pubblicazione offerta (R4)
│   │       └── job_applications_screen.dart  # Consultazione candidature e apertura CV (R7)
│   ├── widgets/
│   │   └── server_config_dialog.dart# Dialog per configurare l'IP del backend
│   └── main.dart                    # Inizializzazione app e Provider
├── test/
│   └── widget_test.dart             # Test unitari sui modelli
├── android/                         # Configurazione Android (Cleartext HTTP abilitato)
├── ios/                             # Configurazione iOS (NSAllowsArbitraryLoads)
├── pubspec.yaml
└── README.md
```
