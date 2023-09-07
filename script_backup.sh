#!/bin/bash
# Itérer sur chaque utilisateur
getent passwd | awk -F: '{ print $1, $6 }' | while read -r username home_dir; do
# Cette ligne utilise getent passwd pour récupérer la liste des utilisateurs et 
# leur répertoire $HOME. La commande awk extrait le nom d'utilisateur et le répertoire $HOME. 
# while read -r username home_dir; do itère sur chaque ligne de la sortie.
    # Skip si le répertoire home n'existe pas
    [ -d "$home_dir" ] || continue
    # Cette ligne vérifie si le répertoire $HOME existe ; sinon, elle saute à la prochaine itération de la boucle.
    # Date actuelle
    date=$(date '+%Y-%m-%d')
    # Cette ligne stocke la date actuelle dans une variable date.
    # Effectuer les différentes recherches
    for option in "cree_7jours" "modifie_7jours" "rep_sup10Mo" "cache"; do
    # Cette ligne commence une boucle for qui va itérer sur les quatre options de fichiers à sauvegarder.
        case $option in
        # Cette ligne débute un bloc case, qui va exécuter un bloc de code différent en fonction de la valeur de $option.
            "cree_7jours")
                files=$(find $home_dir -type f -ctime -7)
                ;;
            # Ce bloc est exécuté si $option est égal à "cree_7jours". Il utilise la commande find pour 
            # trouver tous les fichiers dans $home_dir créés depuis moins de 7 jours.
            "modifie_7jours")
                files=$(find $home_dir -type f -ctime +7)
                ;;
            # Ce bloc est similaire au précédent, mais il trouve les fichiers modifiés depuis plus de 7 jours.
            "rep_sup10Mo")
                files=$(find $home_dir -type d -exec du -s {} \; | awk '$1*1024 > 10485760 { print $2 }')
                ;;
            # Ce bloc trouve les répertoires dont la taille est supérieure à 10 Mo.
            "cache")
                files=$(find $home_dir -name ".*")
                ;;
            # Ce bloc trouve les fichiers et répertoires cachés dans $home_dir.
        esac
        # Cette ligne termine le bloc case.
        # Créer le tar.gz
        tar -czvf /var/backups/${username}_${option}_${date}.tar.gz $files
        # Cette ligne crée un fichier .tar.gz contenant les fichiers trouvés
        # Définir les permissions
        chown $username:$username /var/backups/${username}_${option}_${date}.tar.gz
        chmod 700 /var/backups/${username}_${option}_${date}.tar.gz
        # Ces deux lignes définissent les permissions du fichier .tar.gz afin qu'il ne soit accessible que par l'utilisateur concerné.
    done
done
#Ces lignes terminent les deux boucles for et while.