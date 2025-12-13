#!/usr/bin/env bash

# Script per aggiornare FileBrowser su Host e/o Container LXC
# Autore: Gemini (Modificato da te)

# Variabili
APP_NAME="FileBrowser"
BIN_PATH="/usr/local/bin/filebrowser"
SERVICE_NAME="filebrowser.service"

# Colori e icone
YW='\033[33m'
GN='\033[1;92m'
RD='\033[01;31m'
BL='\033[36m'
CL='\033[m'
CM="${GN}✔️${CL}"
CROSS="${RD}✖️${CL}"
INFO="${BL}ℹ️${CL}"

function msg_info() {
    echo -e "${INFO} ${YW}$1...${CL}"
}

function msg_ok() {
    echo -e "${CM} ${GN}$1${CL}"
}

function msg_error() {
    echo -e "${CROSS} ${RD}$1${CL}"
}

# --- Funzione per l'Aggiornamento ---

function perform_update() {
    local target_type="$1" # host o lxc
    local target_id="$2"   # ID LXC o "Host"

    msg_info "Aggiornamento $APP_NAME su $target_type $target_id"

    # Comando per scaricare e installare l'ultima versione
    local update_command='curl -fsSL "https://github.com/filebrowser/filebrowser/releases/latest/download/linux-amd64-filebrowser.tar.gz" | tar -xzv -C /usr/local/bin'
    
    # Comando per riavviare il servizio
    local restart_command="systemctl restart $SERVICE_NAME"
    
    # Comando per verificare lo stato
    local status_command="systemctl is-active --quiet $SERVICE_NAME"

    local exec_prefix=""

    if [[ "$target_type" == "lxc" ]]; then
        # Esegui i comandi all'interno della LXC
        exec_prefix="lxc-attach $target_id -- "
    fi

    # 1. Aggiorna il binario
    if $exec_prefix bash -c "$update_command" &>/dev/null; then
        msg_ok "Binario $APP_NAME aggiornato su $target_type $target_id."

        # 2. Riavvia il servizio
        msg_info "Riavvio del servizio su $target_type $target_id"
        if $exec_prefix bash -c "$restart_command"; then
            sleep 1 # Diamo tempo al servizio di ripartire
            if $exec_prefix bash -c "$status_command"; then
                msg_ok "$APP_NAME riavviato correttamente su $target_type $target_id."
                return 0 # Successo
            else
                msg_error "Errore nel riavvio su $target_type $target_id. Controlla: systemctl status $SERVICE_NAME"
                return 1 # Fallimento nel riavvio
            fi
        else
            msg_error "Comando di riavvio fallito su $target_type $target_id."
            return 1 # Fallimento nel comando di riavvio
        fi
    else
        msg_error "Errore durante il download/installazione su $target_type $target_id. (Verifica che curl, tar e bash siano disponibili nel container)"
        return 1 # Fallimento nell'aggiornamento
    fi
}

# --- Logica di Esecuzione ---

# Ottieni la lista delle LXC (solo quelle in esecuzione)
LXC_RUNNING=$(pct list | awk 'NR>1 {print $1}' | grep -E '^[0-9]+$')

case "$1" in
    all)
        # Aggiorna l'Host
        perform_update "host" "Host"
        echo
        # Aggiorna tutte le LXC attive
        for id in $LXC_RUNNING; do
            perform_update "lxc" "$id"
        done
        ;;

    host)
        # Aggiorna solo l'Host
        perform_update "host" "Host"
        ;;

    "" | help)
        echo -e "${BL}Usage: $0 <all | host | ID_LXC | ID1,ID2,ID3>${CL}"
        echo -e "${BL}Esempi:${CL}"
        echo "  $0 all       # Aggiorna l'Host e tutte le LXC attive."
        echo "  $0 host      # Aggiorna solo l'Host Proxmox."
        echo "  $0 101       # Aggiorna solo la LXC con ID 101."
        echo "  $0 101,102   # Aggiorna le LXC 101 e 102."
        echo
        echo -e "${YW}LXC Attive Trovate: ${LXC_RUNNING:-Nessuna}${CL}"
        ;;

    *)
        # Gestisce argomenti multipli separati da virgola (es. 101,105,108)
        if [[ "$1" =~ ^[0-9]+(,[0-9]+)*$ ]]; then
            IFS=',' read -r -a lxc_ids <<< "$1"
            for id in "${lxc_ids[@]}"; do
                if echo "$LXC_RUNNING" | grep -q "\<$id\>"; then
                    perform_update "lxc" "$id"
                else
                    msg_error "LXC $id non trovata o non è in esecuzione. Ignorata."
                fi
            done
        else
            msg_error "Argomento non valido. Usa 'all', 'host', un singolo ID LXC o ID multipli separati da virgola (es. 101,102)."
            exit 1
        fi
        ;;
esac
