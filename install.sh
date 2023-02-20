#!/bin/bash

# Variables de couleurs pour l'affichage dans le terminal
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RED='\033[1;31m'
NC='\033[0m' # No Color


# Mise à jour de la liste des paquets disponibles
echo -e "\n"
echo -e "${YELLOW}Mise à jour du système${NC}"
sudo apt update > /dev/null

# Installation de ifuse
echo -e "\n"
echo -e "${YELLOW}Début de l'installation de ifuse${NC}"
sudo apt install ifuse -y

if [ $? -eq 0 ]; then
  echo -e "${YELLOW}ifuse a été installé avec succès.${NC}"
else
  echo -e "${RED}Une erreur s'est produite lors de l'installation de ifuse.${NC}"
fi
# Pause pour permettre à l'utilisateur d'appuyer sur une touche 
echo -e "${CYAN}"
read -n 1 -s -r -p "Appuyez sur n'importe quelle touche pour continuer"
clear
# Création du fichier de mount de l'iphone
MNT_DIR="/home/$SUDO_USER/mnt-ff7-ios"
echo -e "\n"
echo -e "${YELLOW}Création du dossier de mount pour l'iphone${NC}"
echo -e "\n"
sudo mkdir $MNT_DIR

# Ajout des autorisations
echo -e "${YELLOW}Ajout des autorisations d'execution du script et du dossier mount${NC}"
sudo chmod 777 $MNT_DIR
sudo chmod 777 install.sh
echo -e "${CYAN}"

# Ajout d'un raccourcie
echo -e "${CYAN}"

# Pause pour permettre à l'utilisateur d'appuyer sur une touche 
read -n 1 -s -r -p "Appuyez sur n'importe quelle touche pour continuer"
clear

echo -e "${RED}N'oublier pas d'ajouter un certificat de debug sur le MPP avec l'outils Gencert${NC}"
echo -e "\n"
echo -e "${YELLOW}Une fois Gencert ouvert et le ${RED}MPP connecter${YELLOW}, cliquer sur ${RED}Detecte${NC}"
echo -e "\n"
echo -e "${YELLOW}Vérifier que l'ip est bien ${RED}192.168.53.1${YELLOW}, puis cliquer sur ${RED}Generate${YELLOW}"
echo -e "\n"
echo -e "${YELLOW} et enfin cliquer sur ${RED}Upload${CYAN}. "
echo -e "\n"

# Pause pour permettre à l'utilisateur d'appuyer sur une touche 
read -n 1 -s -r -p "Appuyez sur n'importe quelle touche pour ouvrir Gencert"
gencert 



