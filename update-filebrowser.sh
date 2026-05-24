#!/usr/bin/env bash

# ======================================================================
# SCRIPT: update-filebrowser.sh
# VERSIONE: 1.0.3 (In-Process Target Resolution)
# ======================================================================

# Rileva le dimensioni del terminale
TERM_WIDTH=$(tput cols)
TERM_HEIGHT=$(tput lines)

# Calcola una larghezza sicura (80% dello schermo, max 70, min 40)
IFACE_WIDTH=$(( TERM_WIDTH * 80 / 100 ))
if [ $IFACE_WIDTH -gt 70 ]; then IFACE_WIDTH=70; fi
if [ $IFACE_WIDTH -lt 40 ]; then IFACE_WIDTH=40; fi

# Calcola un'altezza sicura (80% dello schermo)
IFACE_HEIGHT=$(( TERM_HEIGHT * 80 / 100 ))
if [ $IFACE_HEIGHT -lt 15 ]; then IFACE_HEIGHT=15; fi

# Calcola l'altezza della lista interna (altezza finestra - 10 righe di bordi/testo)
LIST_HEIGHT=$(( IFACE_HEIGHT - 10 ))

echo $$ > /var/run/update-filebrowser.pid
trap "echo -ne '\033[0m'; rm -f /var/run/update-filebrowser.pid" EXIT

# --- CONFIGURAZIONE VARIABILI INTERNE ---
APP_NAME="FileBrowser"
BIN_PATH="/usr/local/bin/filebrowser"
SERVICE_NAME="filebrowser.service"
HOST_IP=$(hostname -I | awk '{print $1}')

C_DEFAULT='\033[0m'
C_RED='\033[0;31m'    
C_GREEN='\033[0;32m'  
C_YELLOW='\033[1;33m' 
C_CYAN='\033[0;36m'   

declare -a UPDATE_LOGS
DRY_RUN=false
ARGS=()

# --- FUNZIONE HELP ---
show_help() {
    echo -e "${C_CYAN}Utilizzo:${C_DEFAULT} $0 <host|ID_LXC|all> [opzioni]"
    echo ""
    echo -e "${C_YELLOW}Opzioni CLI:${C_DEFAULT}"
    echo "  --dry-run       Simulazione senza applicare modifiche"
    echo ""
    echo "Info: Avvia senza argomenti per l'interfaccia grafica."
    exit 0
}

# --- FUNZIONE CORE DI AGGIORNAMENTO ---
perform_update() {
    local target_type="$1" 
    local target_id="$2"   

    echo -e "--------------------------------------------------------"
    echo -e "${C_CYAN}#### PROCESSO $APP_NAME SU $target_type ($target_id) ####${C_DEFAULT}"

    local exec_prefix=""
    if [[ "$target_type" == "lxc" ]]; then
        if [ "$(pct status $target_id 2>/dev/null)" != "status: running" ]; then
            echo -e "${C_YELLOW}LXC $target_id non è in esecuzione.${C_DEFAULT}" >&2
            return 0
        fi
        exec_prefix="pct exec $target_id -- "
    fi

    # Verifica se FileBrowser è installato nella destinazione
    if ! $exec_prefix [ -f "$BIN_PATH" ] && ! $exec_prefix command -v filebrowser &>/dev/null; then
        echo -e "${C_YELLOW}FileBrowser non trovato su $target_type $target_id. Salto.${C_DEFAULT}" >&2
        UPDATE_LOGS+=("🟡 $target_type $target_id - Non presente.")
        return 0
    fi

    echo -e "      Verifica aggiornamenti..." >&2

    if [ "$DRY_RUN" = true ]; then
        UPDATE_LOGS+=("✅ $target_type $target_id - Aggiornamento disponibile (Dry Run)")
        return 0
    fi

    local update_command='curl -fsSL "https://github.com/filebrowser/filebrowser/releases/latest/download/linux-amd64-filebrowser.tar.gz" | tar -xzv -C /usr/local/bin'
    local restart_command="systemctl restart $SERVICE_NAME"
    local status_command="systemctl is-active --quiet $SERVICE_NAME"

    if $exec_prefix bash -c "$update_command" &>/dev/null; then
        echo -e "${C_GREEN}      ✔ Binario aggiornato su $target_type $target_id.${C_DEFAULT}" >&2
        
        if $exec_prefix bash -c "$restart_command" &>/dev/null; then
            sleep 1
            if $exec_prefix bash -c "$status_command"; then
                echo -e "${C_GREEN}      ✔ Servizio riavviato correttamente.${C_DEFAULT}" >&2
                UPDATE_LOGS+=("✅ $target_type $target_id - Aggiornato e riavviato.")
                return 0
            else
                echo -e "${C_RED}      ✖ Servizio non attivo dopo il riavvio.${C_DEFAULT}" >&2
                UPDATE_LOGS+=("❌ $target_type $target_id - Errore stato servizio.")
                return 1
            fi
        else
            echo -e "${C_RED}      ✖ Impossibile riavviare il servizio.${C_DEFAULT}" >&2
            UPDATE_LOGS+=("❌ $target_type $target_id - Fallito riavvio systemd.")
            return 1
        fi
    else
        echo -e "${C_RED}      ✖ Errore durante il download o l'estrazione.${C_DEFAULT}" >&2
        UPDATE_LOGS+=("❌ $target_type $target_id - Errore download binario.")
        return 1
    fi
}

# --- LOGICA DI INPUT (INTERATTIVA VS CLI) ---
if [ $# -eq 0 ]; then
    if ! command -v whiptail &> /dev/null; then
        echo -e "${C_RED}Errore: whiptail non trovato.${C_DEFAULT}"
        exit 1
    fi

    LXC_RAW=$(pct list | awk 'NR>1 {print $1 " [" $3 "] off"}')
    MENU_ITEMS="HOST [Proxmox_Host] off ALL [Tutti_i_LXC_attivi] off $LXC_RAW"

    CHOICES=$(whiptail --title "$APP_NAME Updater" \
        --checklist "Seleziona dove aggiornare $APP_NAME (Spazio per selezionare):" \
        $IFACE_HEIGHT $IFACE_WIDTH $LIST_HEIGHT \
        $MENU_ITEMS 3>&1 1>&2 2>&3)

    exit_status=$?
    if [ $exit_status -ne 0 ]; then
        echo -e "\n${C_YELLOW}Operazione annullata.${C_DEFAULT}"
        exit 0
    fi    

    [ -z "$CHOICES" ] && exit 0
    CHOICES=$(echo "$CHOICES" | tr -d '"')

    OPTIONS=$(whiptail --title "Opzioni di Aggiornamento" \
        --checklist "Seleziona le flag desiderate:" \
        $IFACE_HEIGHT $IFACE_WIDTH 5 \
        "dryrun" "Simulazione (Dry Run) [-n]" OFF 3>&1 1>&2 2>&3)

    if [ $? -ne 0 ]; then
        echo -e "\n${C_YELLOW}Operazione annullata.${C_DEFAULT}"
        exit 0
    fi

    [[ "$OPTIONS" == *"dryrun"* ]] && DRY_RUN=true

    # Popoliamo direttamente l'array degli argomenti con le scelte di whiptail
    for TARGET in $CHOICES; do
        TARGET_CLEAN=$(echo "$TARGET" | xargs)
        [[ -n "$TARGET_CLEAN" ]] && ARGS+=("$TARGET_CLEAN")
    done
else
    # GESTIONE ARGOMENTI DA CLI STANDARD
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            -h|--help)
                show_help
                ;;
            *)
                ARGS+=("$1")
                shift
                ;;
        esac
    done
fi

if [ ${#ARGS[@]} -eq 0 ]; then show_help; fi

echo -e "${C_CYAN}Aggiornamento $APP_NAME - Host: $HOST_IP${C_DEFAULT}"
[ "$DRY_RUN" = true ] && echo -e "${C_YELLOW}*** MODALITÀ DRY-RUN ATTIVA ***${C_DEFAULT}"

# --- RISOLUZIONE DEI TARGET ED ESECUZIONE ---
LXC_RUNNING=$(pct list | awk 'NR>1 {print $1}' || true)

for ARG in "${ARGS[@]}"; do
    if [ "$ARG" == "host" ] || [ "$ARG" == "HOST" ]; then
        perform_update "host" "Host"
    elif [ "$ARG" == "all" ] || [ "$ARG" == "ALL" ]; then
        perform_update "host" "Host"
        for id in $LXC_RUNNING; do
            perform_update "lxc" "$id"
        done
    elif [[ "$ARG" =~ ^[0-9]+(,[0-9]+)*$ ]]; then
        IFS=',' read -r -a lxc_ids <<< "$ARG"
        for id in "${lxc_ids[@]}"; do
            perform_update "lxc" "$id"
        done
    elif [[ "$ARG" =~ ^[0-9]+$ ]]; then
        perform_update "lxc" "$ARG"
    else
        echo -e "${C_RED}✖️ Argomento non valido: $ARG${C_DEFAULT}" >&2
    fi
done

# --- REPORT FINALE ---
echo -e "\n--- REPORT FINALE ---"
for E in "${UPDATE_LOGS[@]}"; do
    if [[ "$E" == "✅"* ]]; then echo -e "${C_GREEN}$E${C_DEFAULT}"
    elif [[ "$E" == "🟡"* ]]; then echo -e "${C_YELLOW}$E${C_DEFAULT}"
    else echo -e "${C_RED}$E${C_DEFAULT}"; fi
done
