# update-filebrowser.sh

Script Bash per l'aggiornamento automatico e massivo di File Browser installato su Proxmox VE (Host e Container LXC).

---

## 🇮🇹 Istruzioni in Italiano

### 🎯 Scopo dello Script

Questo script semplifica il processo di aggiornamento del binario di File Browser (scaricando l'ultima versione ufficiale) in tutti i luoghi dove è stato installato sul tuo server Proxmox, sia direttamente sull'**Host** che all'interno dei **Container LXC** attivi.

### ⚠️ Prerequisiti

Lo script assume che:

1.  **File Browser sia installato** utilizzando gli [Helper Scripts della community di Proxmox VE](https://community-scripts.github.io/ProxmoxVE/scripts).
2.  L'installazione sia stata effettuata sul **Proxmox Host** e/o all'interno di uno o più **Container LXC basati su Debian/Alpine**.
3.  All'interno di ogni LXC, il servizio sia gestito da `systemd` (o `openrc` in Alpine) con il nome di servizio standard: `filebrowser.service`.
4.  Le utility `curl` e `tar` siano disponibili sia sull'Host che all'interno dei Container target.

### ⚙️ Installazione e Configurazione

#### Opzione A: Esecuzione Diretta (Consigliata)

Esegui lo script direttamente dal tuo repository GitHub senza salvarlo localmente.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/fcaronte/proxmox_lxc_filebrowser_update/refs/heads/main/update-filebrowser.sh)" <-- ARGOMENTO>
# Esempio per aggiornare tutto:
bash -c "$(curl -fsSL https://raw.githubusercontent.com/fcaronte/proxmox_lxc_filebrowser_update/refs/heads/main/update-filebrowser.sh)" -- all
````

#### Opzione B: Installazione Locale

Per integrarlo nel tuo ambiente e renderlo eseguibile tramite un semplice comando:

1.  **Salva lo script** in `/usr/local/bin/`:
    ```bash
    wget -O /usr/local/bin/update-filebrowser.sh https://raw.githubusercontent.com/fcaronte/proxmox_lxc_filebrowser_update/main/update-filebrowser.sh
    ```
2.  **Rendi lo script eseguibile:**
    ```bash
    chmod +x /usr/local/bin/update-filebrowser.sh
    ```

### 🚀 Utilizzo

Esegui lo script come utente `root` sul tuo Host Proxmox:

| Azione | Comando (Installazione Locale) | Comando (Esecuzione Diretta) | Descrizione |
| :--- | :--- | :--- | :--- |
| **Aggiorna Tutto** | `update-filebrowser.sh all` | `bash <(curl -fsSL <URL>) all` | Aggiorna l'installazione Host e tutte le LXC attive. |
| **Aggiorna Solo Host** | `update-filebrowser.sh host` | `bash <(curl -fsSL <URL>) host` | Aggiorna solo File Browser installato sul Proxmox Host. |
| **Aggiorna LXC Singola** | `update-filebrowser.sh 101` | `bash <(curl -fsSL <URL>) 101` | Aggiorna File Browser solo nella LXC con ID 101. |
| **Aggiorna LXC Multiple** | `update-filebrowser.sh 101,102,105` | `bash <(curl -fsSL <URL>) 101,102,105` | Aggiorna selettivamente le LXC elencate. |
| **Aiuto** | `update-filebrowser.sh help` | `bash <(curl -fsSL <URL>) help` | Mostra le istruzioni di utilizzo. |

*(Nota: `<URL>` è l'URL RAW del tuo script sopra indicato).*

-----

## 🇬🇧 English Instructions

### 🎯 Script Purpose

This Bash script is designed to simplify the update process for the File Browser binary (by downloading the latest official release) across all locations where it is installed on your Proxmox VE server, including the **Host** machine and any **LXC Containers**.

### ⚠️ Requirements

The script assumes that:

1.  **File Browser is installed** using the [Proxmox VE Community Helper Scripts](https://community-scripts.github.io/ProxmoxVE/scripts).
2.  The installation was performed on the **Proxmox Host** and/or within one or more **Debian/Alpine-based LXC Containers**.
3.  The service inside each LXC is managed by `systemd` (or `openrc` in Alpine) with the standard service name: `filebrowser.service`.
4.  The `curl` and `tar` utilities are available on both the Host and inside the target Containers.

### ⚙️ Installation and Setup

#### Option A: Direct Execution (Recommended)

You can run the script directly from your GitHub repository without downloading it first.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/fcaronte/proxmox_lxc_filebrowser_update/refs/heads/main/update-filebrowser.sh)" -- all <-- ARGUMENT>
# Example to update all:
bash -c "$(curl -fsSL https://raw.githubusercontent.com/fcaronte/proxmox_lxc_filebrowser_update/refs/heads/main/update-filebrowser.sh)" -- all
```

#### Option B: Local Installation

To integrate it into your environment and make it runnable via a simple command:

1.  **Save the script** in `/usr/local/bin/`:
    ```bash
    wget -O /usr/local/bin/update-filebrowser.sh https://raw.githubusercontent.com/fcaronte/proxmox_lxc_filebrowser_update/main/update-filebrowser.sh
    ```
2.  **Make the script executable:**
    ```bash
    chmod +x /usr/local/bin/update-filebrowser.sh
    ```

### 🚀 Usage

Run the script as the `root` user on your Proxmox Host:

| Action | Command (Local Installation) | Command (Direct Execution) | Description |
| :--- | :--- | :--- | :--- |
| **Update All** | `update-filebrowser.sh all` | `bash <(curl -fsSL <URL>) all` | Updates the Host installation and all running LXC containers. |
| **Update Host Only** | `update-filebrowser.sh host` | `bash <(curl -fsSL <URL>) host` | Updates File Browser only on the Proxmox Host installation. |
| **Update Single LXC** | `update-filebrowser.sh 101` | `bash <(curl -fsSL <URL>) 101` | Updates File Browser only in the LXC with ID 101. |
| **Update Multiple LXCs**| `update-filebrowser.sh 101,102,105` | `bash <(curl -fsSL <URL>) 101,102,105` | Selectively updates the listed LXC IDs. |
| **Help** | `update-filebrowser.sh help` | `bash <(curl -fsSL <URL>) help` | Displays usage instructions. |

```

Spero che questa versione chiara e specifica ti sia utile per il tuo progetto su GitHub!

Hai bisogno di aiuto con l'aggiunta di altre funzionalità allo script o con la configurazione di un altro file di progetto (es. un file di licenza)?
```
