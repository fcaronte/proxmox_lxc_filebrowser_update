-----

# 🌍 Language / Lingua

  * [🇮🇹 Leggi in Italiano](#-proxmox-lxc-file-browser-updater-italiano)
  * [🇬🇧 Read in English](#-proxmox-lxc-file-browser-updater-english)

-----

# 🇮🇹 Proxmox LXC File Browser Updater (Italiano)

# 🚀 Proxmox LXC File Browser Updater (v1.0.3)

[![Bash Script](https://img.shields.io/badge/language-Bash-4EAA25.svg)](https://www.gnu.org/software/bash/)
[![Proxmox](https://img.shields.io/badge/Platform-Proxmox-E57020.svg)](https://www.proxmox.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Script avanzato per l'aggiornamento automatico, massivo e selettivo del binario ufficiale di File Browser installato su Proxmox VE, sia direttamente sull'Host che all'interno dei Container LXC attivi.

---

## 🌟 Novità Versione 1.0.x

* **Interfaccia Grafica (GUI/TUI)**: Se avviato senza argomenti, lo script apre un menu interattivo (whiptail) adattivo per selezionare visivamente i target e le opzioni.
* **Controllo Intelligente di Presenza**: Verifica se File Browser è effettivamente installato nella destinazione (Host o LXC), saltando automaticamente i container non interessati senza generare falsi positivi.
* **Modalità Dry-Run**: Consente di simulare l'intero processo e verificare la disponibilità degli aggiornamenti senza applicare modifiche reali.
* **Esecuzione In-Process Sicura**: Eliminati i loop di subshell per garantire la totale stabilità di esecuzione indipendentemente dal nome del file locale.

---

## 🚀 Modalità di Esecuzione

### 1. Modalità Interattiva (GUI)
Semplicemente esegui lo script senza parametri (o tramite l'URL diretto):
```bash
bash -c "$(curl -fsSL [https://raw.githubusercontent.com/fcaronte/proxmox_lxc_filebrowser_update/refs/heads/main/update-filebrowser.sh](https://raw.githubusercontent.com/fcaronte/proxmox_lxc_filebrowser_update/refs/heads/main/update-filebrowser.sh))"

```

Si aprirà un menu dove potrai scegliere visivamente se aggiornare l'Host, l'intera lista di LXC attivi o singoli container, oltre alla possibilità di attivare il Dry-Run.

### 2. Modalità CLI (Terminale / Installazione Locale)

| Comando | Descrizione |
| --- | --- |
| `update-filebrowser.sh all` | Aggiorna l'installazione Host e tutti i LXC attivi in cui è presente l'app. |
| `update-filebrowser.sh host` | Aggiorna File Browser installato esclusivamente sul Proxmox Host. |
| `update-filebrowser.sh 101` | Aggiorna l'applicazione solo all'interno del LXC con ID 101. |
| `update-filebrowser.sh 101,102` | Aggiorna selettivamente i LXC elencati (separati da virgola). |
| `update-filebrowser.sh all --dry-run` | Simula l'operazione su tutti i target senza modificare i file. |

*Nota: Se usi l'esecuzione diretta via URL e vuoi passare i comandi CLI, ricordati di interporre il separatore `--` (es: `bash -c "$(curl...)" -- all`).*

---

## 📋 Note Tecniche e Sicurezza

* **Rilevamento**: Lo script scansiona la presenza del binario in `/usr/local/bin/filebrowser` per identificare i target validi.
* **Gestione Servizi**: Al termine del download del binario, lo script riavvia in sicurezza il servizio `filebrowser.service` via systemd (o openrc) e ne verifica lo stato.
* **Report Finale**: Al termine delle operazioni viene mostrato un riepilogo visivo immediato con lo stato di ogni singolo target (Aggiornato  ✅, Non Presente 🟡, Errore ❌).

---

## 📝 Licenza

Sviluppato con il supporto di **Gemini AI**. Licenza MIT.

---

# 🇬🇧 Proxmox LXC File Browser Updater (English)

# 🚀 Proxmox LXC File Browser Updater (v1.0.3)

Advanced script for automated, massive, and selective updates of the official File Browser binary installed on Proxmox VE, both directly on the Host and inside active LXC Containers.

---

## 🌟 Version 1.0.x Highlights

* **Interactive GUI (TUI)**: Launching the script without arguments opens an adaptive whiptail menu to visually select targets and execution options.
* **Smart Presence Detection**: Checks if File Browser is actually installed on the target destination (Host or LXC) before processing, automatically skipping unrelated containers.
* **Dry-Run Mode**: Allows you to simulate the entire process and check update availability without making any real changes.
* **Robust In-Process Execution**: Removed subshell loops to ensure complete execution stability regardless of the local file name.

---

## 🚀 Execution Modes

### 1. Interactive Mode (GUI)

Simply run the script with no parameters (or via direct URL execution):

```bash
bash -c "$(curl -fsSL [https://raw.githubusercontent.com/fcaronte/proxmox_lxc_filebrowser_update/refs/heads/main/update-filebrowser.sh](https://raw.githubusercontent.com/fcaronte/proxmox_lxc_filebrowser_update/refs/heads/main/update-filebrowser.sh))"

```

A graphical checklist menu will appear allowing you to pick targets (Host, All running LXCs, or single containers) and toggle flags like Dry-Run.

### 2. CLI Mode (Terminal / Local Installation)

| Command | Description |
| --- | --- |
| `update-filebrowser.sh all` | Updates the Host installation and all active LXCs where the app is detected. |
| `update-filebrowser.sh host` | Updates File Browser only on the Proxmox Host installation. |
| `update-filebrowser.sh 101` | Updates File Browser only inside the LXC with ID 101. |
| `update-filebrowser.sh 101,102` | Selectively updates the listed comma-separated LXC IDs. |
| `update-filebrowser.sh all --dry-run` | Checks targets and simulates the workflow without altering files. |

*Note: If you use the direct URL execution method and want to pass CLI arguments, remember to append the `--` separator first (e.g., `bash -c "$(curl...)" -- all`).*

---

## 📋 Technical Notes & Safety

* **Detection**: The script scans for the binary path in `/usr/local/bin/filebrowser` to identify valid update targets.
* **Service Management**: After extracting the new binary, it securely restarts the `filebrowser.service` via systemd (or openrc) and validates its active state.
* **Final Report**: Displays an instant visual summary indicating the outcome for each target (Updated ✅, Skipped/Not Present 🟡, Failed ❌).

---

## 📝 License

Developed with **Gemini AI** support. MIT License.

```

```
