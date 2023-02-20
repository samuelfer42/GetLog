#!/bin/bash

# Variables de couleurs pour l'affichage dans le terminal
RED='\033[1;31m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Variables de date
DATE_WITH_TIME=$(date "+%d-%m-%Y %H:%M:%S")
DATE_NAME=$(date "+%d_%m_%Y_%Hh_%Mm_%Ss_Dump")

# Répertoire de montage pour l'iPhone
MNT_DIR="/home/$SUDO_USER/mnt-ff7-ios"

# Fonction pour demander à l'utilisateur le nom du vol
user_input_flghtname_comment() {
echo -e "${YELLOW}NOM DU VOL${WHITE}"
    read varNameFlight
    if [[ -n "$varNameFlight" ]]; then
        varNameFlight="Logs/$varNameFlight"
    else
        varNameFlight="Logs/$DATE_NAME"
        echo -e "${RED}AUCUN NOM, PAR DEFAUT : $varNameFlight"
    fi
    mkdir $varNameFlight
    #COMMENTAIRE DE VOL
    echo -e "${YELLOW}COMMENTAIRE DU VOL${WHITE}"
    read varCommentFlight
}

# Fonction pour écrire le commentaire dans le fichier ReadMe.txt
write_comment_in_file() {
    echo -e $DATE_WITH_TIME >>$varNameFlight/ReadMe.txt
    adb shell "
  gprop | grep -e "factory.serial" -e "smartbattery.serial" -e "parrot.build.version"
  " >>$varNameFlight/ReadMe.txt
    if [ ${#varCommentFlight} != 0 ]; then
        echo -e $varCommentFlight >>$varNameFlight/ReadMe.txt
    fi
}

# Fonction pour créer l'arborescence de fichiers
making_tree_directory() {
    mkdir $varNameFlight/Media
    mkdir $varNameFlight/Drone
    mkdir $varNameFlight/Drone/TLM
    mkdir $varNameFlight/MPP
    mkdir $varNameFlight/FF7
}

# Fonction pour récupérer les logs du drone
log_drone() {
    echo -e "${YELLOW}Choisissez le mode d'exécution : "
    echo -e "${CYAN}1) Récupèration du dernier bootID"
    echo -e "${CYAN}2) Récupèration du de tout les logs du drone"
    echo -e "${CYAN}3) Récupèration de toutes les données présents dans la carte SD"
    read mode_choice
    if [ "$mode_choice" = "1" ]; then
        start_normal
    elif [ "$mode_choice" = "2" ]; then
        all_log_drone
    elif [ "$mode_choice" = "3" ]; then
        add_all_sd
    else
        clear
        echo -e "${RED}Option non valide. Veuillez réessayer."
    fi
}

# Fonction secondaire pour afficher les different choix de log
add_log() {
    echo -e "${YELLOW}Choisissez quel log récupéré : "
    echo -e "${CYAN} 1) Logs du DRONE"
    echo -e "${CYAN} 2) Logs du MPP"
    echo -e "${CYAN} 3) Logs de FF7${YELLOW}"
    read mode_choice
    if [ "$mode_choice" = "1" ]; then
        clear
        log_drone
    elif [ "$mode_choice" = "2" ]; then
        clear
        log_mpp
    elif [ "$mode_choice" = "3" ]; then
        clear
        log_ff7
    else
        clear
        echo -e "${RED}Option non valide. Veuillez réessayer."
    fi
}

# Fonction pour récupérer les logs du drone
start_normal() {
    clear
    check_device_connected
    write_comment_in_file
    adb_pulling_files_without_specific_bootid
}

# Fonction pour récupérer tout les logs du drone
all_log_drone() {
    clear
    check_device_connected
    write_comment_in_file
    adb_pulling_all_files
}

# Fonction pour récupérer tous les logs de la carte SD
add_all_sd() {
    echo -e "${YELLOW}Récupération Carte SD${WHITE}"
    adb pull /mnt/user/DCIM/ $varNameFlight/Media/SDCard
}

# Fonction pour choisir le mode de recuperation des logs de FF7
log_ff7() {
    echo -e "${YELLOW}Choisissez le mode de récupération de log de FF7 : "
    echo -e "${CYAN}1) Récupèration du dernier log"
    echo -e "${CYAN}2) Récupèration du de tout les logs de FF7${YELLOW}"
    read mode_choice
    if [ "$mode_choice" = "1" ]; then
        start_normal_ff7
    elif [ "$mode_choice" = "2" ]; then
        all_log_ff7
    else
        clear
        echo -e "${RED}Option non valide. Veuillez réessayer.${YELLOW}"
    fi
}

# Fonction pour récupérer le dernier log de FF7
start_normal_ff7() {
    ./ifuse/native-wrapper.sh ifuse "$MNT_DIR" --documents com.parrot.freeflight7.inhouse
    log_dir="$MNT_DIR/log/"
    destination_dir="$varNameFlight/FF7/"
    latest_file=$(ls -t $log_dir | head -1)
    echo -e "${YELLOW}Récupération log FF7${WHITE}"
    echo -e "${YELLOW}Création du point de montage de l'iPhone${WHITE}"
    echo -n "Copie en cours"
    cp -r "$log_dir/$latest_file" "$destination_dir"
    echo -e "\nCopie terminée"
    echo "FF7: $MNT_DIR/log/$latest_file" >>"$2/ReadMe.txt"
    fusermount -uz "$MNT_DIR"
}

# Fonction pour récupérer tous les logs de FF7
all_log_ff7() {
    ./ifuse/native-wrapper.sh ifuse "$MNT_DIR" --documents com.parrot.freeflight7.inhouse
    log_dir="$MNT_DIR/log/"
    destination_dir="$varNameFlight/FF7/"
    echo -e "${YELLOW}Récupération log FF7${WHITE}"
    echo -e "${YELLOW}Création du point de montage de l'iPhone${WHITE}"
    echo -n "Copie en cours"
    cp -r "$log_dir" "$destination_dir"
    echo -e "\nCopie terminée"
    echo "FF7: $MNT_DIR/log/" >>"$2/ReadMe.txt"
    fusermount -uz "$MNT_DIR"
}

# Fonction pour récupérer les logs de MPP
log_mpp() {
    echo -e "${YELLOW}Choisissez le mode de récupération de log du MPP : "
    echo -e "${CYAN}1) Récupèration du dernier log du MPP"
    echo -e "${CYAN}2) Récupèration de tout les logs du MPP${YELLOW}"
    read mode_choice
    if [ "$mode_choice" = "1" ]; then
        start_normal_mpp
    elif [ "$mode_choice" = "2" ]; then
        all_log_mpp
    else
        clear
        echo -e "${RED}Option non valide. Veuillez réessayer.${YELLOW}"
    fi
}

start_normal_mpp() {
    echo -e "${YELLOW}Connexion au MPP${NC}"
    adb connect 192.168.53.1:9050
    echo -e "${YELLOW}Récupération log MPP${WHITE}"
    adb shell ls -t "/log/" | head -1 | tr -d '\015' | while read line; do
        adb pull "/log/$line" $varNameFlight/MPP/
        echo "MPP: /log/$line" >>$varNameFlight/ReadMe.txt
    done
}

all_log_mpp() {
    echo -e "${YELLOW}Connexion au MPP${NC}"
    adb connect 192.168.53.1:9050
    echo -e "${YELLOW}Récupération log MPP${WHITE}"
    adb shell ls "/log/" | while read line; do
        adb pull "/log/$line" $varNameFlight/MPP/
        echo "MPP: /log/$line" >>$varNameFlight/ReadMe.txt
    done
}

# Fonction pour afficher les diffèrent choix de suppression.
delete() {
    echo -e "${YELLOW}Quel log supprimer : "
    echo -e "${CYAN}1 => logs DRONE"
    echo -e "${CYAN}2 => logs MPP"
    echo -e "${CYAN}3 => logs FF7${YELLOW}"
    echo -e "${CYAN}4 => logs sauvegardé sur le pc"

    read r_choice
    if [ $r_choice == "1" ]; then
        clear
        delete_log_drone

    elif [ $r_choice == "2" ]; then
        clear
        delete_log_mpp

    elif [ $r_choice == "3" ]; then
        clear
        delete_log_FF7

    elif [ $r_choice == "4" ]; then
        clear
        delete_log_pc
    else
        clear
        echo -e "${RED}Option non valide. Veuillez réessayer."
    fi
}

# Fonction pour supprimer les logs du drone
delete_log_drone() {
    echo -e "${YELLOW}Supression des logs du drone${RED}"
     read -n 1 -s -r -p "Appuyez sur n'importe quelle touche pour continuer"
    adb shell rm -rf /mnt/user-internal/FSR/*
    adb shell rm -rf /mnt/user-internal/FDR-TLM/*
    adb shell rm -rf /mnt/logs/FDR/*
    echo -e "${RED}Supression terminée"
}

delete_log_pc(){
    echo -e "${YELLOW}Supression des logs du PC${RED}"
    read -n 1 -s -r -p "Appuyez sur n'importe quelle touche pour continuer"
    sudo rm -rf Logs/*
    echo -e "${RED}Supression effectuer"
}


# Fonction pour supprimer les logs du MPP
delete_log_mpp() {
    echo -e "${YELLOW}Supression des logs du MPP${RED}"
    read -n 1 -s -r -p "Appuyez sur n'importe quelle touche pour continuer"
    echo -e "${YELLOW}Connexion au MPP${NC}"
    adb connect 192.168.53.1:9050
    adb shell rm -rf /log/*
    echo -e "${RED}Supression terminée"
}

# Fonction pour supprimer les logs de FF7
delete_log_FF7() {
    echo -e "${YELLOW}Création du point de montage de l'iPhone${WHITE}"
    echo -e "${YELLOW}Supression des logs de FF7 ${RED}"
    read -n 1 -s -r -p "Appuyez sur n'importe quelle touche pour continuer"
    ./ifuse/native-wrapper.sh ifuse "$MNT_DIR" --documents com.parrot.freeflight7.inhouse
    rm -rf /home/$SUDO_USER/mnt-ff7-ios/log/
    fusermount -uz "$MNT_DIR"
    echo -e "${RED}Supression terminée"
}

# Fonction pour crée les fichiers
create_file() {
    user_input_flghtname_comment
    making_tree_directory
}

# Fonction pour verifier si le drone est connecter
check_device_connected() {
    adb get-state 1>/dev/null 2>&1 && isDroneDetected=1 || isDroneDetected=0
    if [[ $isDroneDetected == 0 ]]; then
        echo -e "${RED}Aucun drone détecté, vérifiez les branchements et/ou attendez le boot du drone"
    fi
}

# Fonction pour verifier la place disponible sur le pc
check_available_space_on_computer() {
    space_available=$(df --output=avail -h "$PWD" | sed '1d;s/[^0-9]//g')
    limite=25
    if [ $space_available -lt $limite ]; then
        echo -e "${RED}$space_available Go mémoire sur votre ordinateur, libérer de la place puis recommencer."
        read -s -n 1 key
        if [[ $key = "" ]]; then
            echo "Processus de récupération maintenu."
        else
            exit
        fi
    fi
}

# Fonction pour récupérer le dernier fichier modifié
get_latest_file() {
    dir=$1
    latest_file=$(adb shell ls -t "$dir" | head -n 1 | tr -d '\r')
    echo "$dir/$latest_file"
}

# Fonction pour récupérer le dernier BOOTID
adb_pulling_files_without_specific_bootid() {
    echo -e "${CYAN}Récupération FSR${YELLOW}"
    latest_file=$(get_latest_file "/mnt/user-internal/FSR/")
    adb pull "$latest_file" $varNameFlight/Media
    echo "FSR: $latest_file" >>$varNameFlight/ReadMe.txt

    echo -e "${CYAN}Récupération FDR-TLM${YELLOW}"
    latest_file=$(get_latest_file "/mnt/user-internal/FDR-TLM/")
    adb pull "$latest_file" $varNameFlight/Drone/TLM
    echo "TLM: $latest_file" >>$varNameFlight/ReadMe.txt

    echo -e "${CYAN}Récupération LOGS${YELLOW}"
    latest_file=$(get_latest_file "/mnt/logs/FDR/")
    adb pull "$latest_file" $varNameFlight/Drone
    echo "LOG: $latest_file" >>$varNameFlight/ReadMe.txt
}

# Fonction pour récupère tout les logs
adb_pulling_all_files() {
    echo -e "${CYAN}Récupération FSR${YELLOW}"
    adb shell ls /mnt/user-internal/FSR/ | tr -d '\015' | while read line; do
        adb pull "/mnt/user-internal/FSR/$line" "$varNameFlight/Media"
        echo "FSR: /mnt/user-internal/FSR/$line" >>"$varNameFlight/ReadMe.txt"
    done

    echo -e "${CYAN}Récupération FDR-TLM${YELLOW}"
    adb shell ls /mnt/user-internal/FDR-TLM/ | tr -d '\015' | while read line; do
        adb pull "/mnt/user-internal/FDR-TLM/$line" "$varNameFlight/Drone/TLM"
        echo "TLM: /mnt/user-internal/FDR-TLM/$line" >>"$varNameFlight/ReadMe.txt"
    done

    echo -e "${CYAN}Récupération LOGS${YELLOW}"
    adb shell ls /mnt/logs/FDR/ | tr -d '\015' | while read line; do
        adb pull "/mnt/logs/FDR/$line" "$varNameFlight/Drone"
        echo "LOG: /mnt/logs/FDR/$line" >>"$varNameFlight/ReadMe.txt"
    done
}

# Fonction principal pour afficher les different choix
while true; do
    echo -e "${YELLOW}Que voulez-vous faire : "
    echo -e "${CYAN}1 => Pull les logs"
    echo -e "${CYAN}2 => Supression des données${YELLOW}"
    echo -e "${CYAN}3 => Quitter${YELLOW}"
    read choice
    if [ $choice == "1" ]; then
        clear
        if [ -z "$varNameFlight" ]; then
            create_file
        fi
        add_log
    elif [ $choice == "2" ]; then
        clear
        delete
    elif [ $choice == "3" ]; then
        clear
        exit
    else
        clear
        echo -e "${RED}Option non valide. Veuillez réessayer."
    fi
done
