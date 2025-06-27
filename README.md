# Projet personnel : Installation et sécurisation d'Active Directory sous Windows Server 2022

## Objectif du projet

Mettre en place un environnement Windows Server 2022 avec Active Directory, DNS, DHCP et supervision, dans une optique de durcissement et de sécurisation des accès via GPO et de surveillance via un outil comme Wazuh.

Note : Ce projet a été réalisé à des fins pédagogiques sur un environnement de test virtualisé sous VMware Workstation Pro.

## Étape 1 : Préparation de l'environnement

### 1.1 Installation de Windows Server 2022

- ISO officielle de Windows Server 2022 Datacenter montée dans VMware Workstation Pro.
- Installation de l'OS avec l'option "Desktop Experience".
- Configuration initiale : mot de passe administrateur fort.

### 1.2 Configuration réseau

- Attribution d'une IP statique : 192.168.1.10.
- Test de connectivité Internet et du réseau local.

![Paramètres réseau](https://github.com/user-attachments/assets/3657cada-bf46-42bb-9bc5-a2c6d9b37ebe)

## Étape 2 : Installation et configuration d'Active Directory

### 2.1 Renommage du serveur

- Nouveau nom : SRV-DC01.
- Redémarrage du serveur requis.

### 2.2 Installation du rôle AD DS

- Via le Gestionnaire de serveur > "Ajouter des rôles et fonctionnalités".
- Sélection d'Active Directory Domain Services (AD DS).

### 2.3 Promotion en contrôleur de domaine

- Nouveau domaine : mondomaine.local.
- Configuration du mot de passe DSRM.
- Redémarrage à la fin de la promotion.

## Étape 3 : Configuration avancée et sécurisation

### 3.1 Application de GPO

- Utilisation de la console GPMC.
- GPO de sécurité appliquée sur l'OU "Users".
- Mots de passe complexes (min. 12 caractères, expiration 90j).

![Editeur GPO](https://github.com/user-attachments/assets/94f8db03-e6cf-4618-959e-47b1be192bcb)

- Désactivation automatique des comptes inactifs depuis plus de 30 jours, via un script PowerShell (DesactivationComptesInactifs.ps1) exécuté périodiquement grâce au Planificateur de tâches.

![Planificateur de tâches](https://github.com/user-attachments/assets/e39573c6-7cd4-40a0-abdc-533bcdbb889d)

### 3.2 Audit des événements de sécurité

- Activation de l'audit dans "Stratégie de sécurité locale" et GPMC.
- Connexions réussies/échouées.
- Modifications d’objets AD.

### 3.3 Journalisation et supervision

- Intégration de l’Observateur d’événements Windows pour les journaux "Sécurité".

![Observateur d'évènements](https://github.com/user-attachments/assets/29ce843a-1bd7-491d-851a-bfee499efa14)

## Étape 4 : Tests de l'infrastructure

### 4.1 Test de GPO

- Création d’un utilisateur test_user.
- Vérification du refus d’un mot de passe faible lors de sa définition.
- Utilisation de gpupdate /force et redémarrage pour forcer l’application de la GPO.

### 4.2 Suivi dans l’Observateur d’événements

- Vérification de la journalisation des tentatives de connexion.

### 4.3 Ajout d'une machine cliente Windows 10 au domaine

- VM Windows 10 hébergée sur VMware Workstation Pro.
- Configuration IP manuelle et DNS pointant vers le DC (192.168.1.10).
- Intégration au domaine via "Système > Modifier les paramètres" > "Domaine : mondomaine.local".
- Authentification testée avec l'utilisateur test_user.

![Utilisateurs AD](https://github.com/user-attachments/assets/15c56927-7dbf-496e-b9d4-b88cd437512d)

## Étape 5 : Configuration des services DNS et DHCP

### 5.1 DNS

- Installation automatique avec AD DS.
- Vérification des zones directe et inversée via la console DNS.
- Test avec nslookup :

```bash
nslookup srv-dc01.mondomaine.local
```

![Gestionnaire DNS](https://github.com/user-attachments/assets/980c1206-048a-415b-88a4-2d88db11ce57)

### 5.2 DHCP

- Installation du rôle DHCP via le Gestionnaire de serveur.
- Création d’une plage : 192.168.1.100 à 192.168.1.150.
- Configuration des options : DNS, passerelle, domaine.
- Autorisation du serveur DHCP dans AD.

![DHCP](https://github.com/user-attachments/assets/73a76202-b2d1-446c-9341-0d0b652dfe68)

## Étape 6 : Supervision avec Wazuh

### 6.1 Installation de Wazuh Server (Linux)

- Utilisation du script officiel sur une VM Ubuntu. Pour les versions ultérieures à 22.04 non prises en charge, l’option --ignore-check permet de forcer l’installation malgré l’avertissement.

```bash
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
bash wazuh-install.sh -a --ignore-check
```

### 6.2 Déploiement de l'agent Wazuh sur Windows Server (SRV-DC01)

- Téléchargement depuis https://documentation.wazuh.com/current/installation-guide/wazuh-agent/wazuh-agent-package-windows.html
- Configuration de l’IP du manager et nom d’agent : SRV-DC01.
- Fichier ossec.conf :

```xml
<client>
  <server>
    <address><IP_SERVEUR_WAZUH></address>
    <port>1514</port>
    <protocol>tcp</protocol>
  </server>
  <crypto_method>aes</crypto_method>
  <notify_time>10</notify_time>
  <time-reconnect>60</time-reconnect>
  <auto_restart>yes</auto_restart>
</client>
```

- Enregistrement de l’agent avec :

```bash
/var/ossec/bin/manage_agents
```

- Redémarrage du service :

```powershell
sc stop wazuh-agent
sc start wazuh-agent
```

### 6.3 Contrôle via l’interface Web Wazuh

- Connexion : https://<IP_SERVEUR_WAZUH>:443.
- Visualisation de l’agent Windows, alertes, logs de sécurité.

![Wazuh](https://github.com/user-attachments/assets/160c374b-5cff-40d3-9da9-e28ebc60f727)

## Résultat final

L'infrastructure est pleinement fonctionnelle et sécurisée :
- Un domaine mondomaine.local opérationnel ;
- Des stratégies de sécurité appliquées ;
- Une supervision active avec Wazuh ;
- Un environnement prêt à gérer des utilisateurs et machines en production.

## À propos

Ce projet a été réalisé à des fins pédagogiques dans le cadre de mon apprentissage personnel.  
Il démontre mes compétences en :

- Administration Windows Server ;
- Mise en œuvre d’un Active Directory sécurisé ;
- Application de politiques GPO ;
- Supervision via Wazuh.
