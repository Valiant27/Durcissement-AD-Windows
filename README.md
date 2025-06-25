# Projet : Installation et sécurisation d'Active Directory sous Windows Server 2022

## Objectif du projet

Mettre en place un environnement Windows Server 2022 avec Active Directory, DNS, DHCP et supervision, dans une optique de durcissement et de sécurisation des accès via GPO et de surveillance via un outil comme Wazuh.
Note : Ce projet a été réalisé à des fins pédagogiques sur un environnement de test virtualisé sous VMware Workstation Pro.

## Étape 1 : Préparation de l'environnement

### 1.1 Installation de Windows Server 2022

- ISO officielle de Windows Server 2022 Datacenter montée dans VMware Workstation Pro
- Installation de l'OS avec l'option "Desktop Experience"
- Configuration initiale : mot de passe administrateur fort

### 1.2 Configuration réseau

- Attribution d'une IP statique : 192.168.1.10
- Test de connectivité Internet et du réseau local

(Insérer capture d’écran de la configuration réseau)

## Étape 2 : Installation et configuration d'Active Directory

### 2.1 Renommage du serveur

- Nouveau nom : SRV-DC01
- Redémarrage du serveur requis

### 2.2 Installation du rôle AD DS

- Via le Gestionnaire de serveur > "Ajouter des rôles et fonctionnalités"
- Sélection d'Active Directory Domain Services (AD DS)

### 2.3 Promotion en contrôleur de domaine

- Nouveau domaine : mondomaine.local
- Configuration du mot de passe DSRM
- Redémarrage à la fin de la promotion

(Insérer capture d’écran de l’assistant de promotion)

## Étape 3 : Configuration avancée et sécurisation

### 3.1 Application de GPO

- Utilisation de la console GPMC
- GPO de sécurité appliquée sur l'OU "Users"
- Mots de passe complexes (min. 12 caractères, expiration 90j)
- Désactivation des comptes inactifs après 30 jours

(Insérer capture d’écran de la GPO)

### 3.2 Audit des événements de sécurité

- Activation de l'audit dans "Stratégie de sécurité locale" et GPMC
- Connexions réussies/échouées
- Modifications d’objets AD

### 3.3 Journalisation et supervision

- Intégration de l’Observateur d’événements Windows pour les journaux "Sécurité"

(Insérer capture d’écran de l’Observateur d’événements)

## Étape 4 : Tests de l'infrastructure

### 4.1 Test de GPO

- Création d’un utilisateur test_user
- Vérification du refus d’un mot de passe faible lors de sa définition
- Utilisation de gpupdate /force et redémarrage pour forcer l’application de la GPO

### 4.2 Suivi dans l’Observateur d’événements

- Vérification de la journalisation des tentatives de connexion

### 4.3 Ajout d'une machine cliente Windows 10 au domaine

- VM Windows 10 hébergée sur VMware Workstation Pro
- Configuration IP manuelle et DNS pointant vers le DC (192.168.1.10)
- Intégration au domaine via "Système > Modifier les paramètres" > "Domaine : mondomaine.local"
- Authentification testée avec l'utilisateur test_user

(Insérer capture d’écran de la jonction au domaine)

## Étape 5 : Configuration des services DNS et DHCP

### 5.1 DNS

- Installation automatique avec AD DS
- Vérification des zones directe et inversée via la console DNS
- Test avec nslookup :

```bash
nslookup srv-dc01.mondomaine.local
```

(Insérer capture d’écran de la console DNS)

### 5.2 DHCP

- Installation du rôle DHCP via le Gestionnaire de serveur
- Création d’une plage : 192.168.1.100 à 192.168.1.150
- Configuration des options : DNS, passerelle, domaine
- Autorisation du serveur DHCP dans AD

(Insérer capture d’écran de la plage DHCP)

## Étape 6 : Supervision avec Wazuh

### 6.1 Installation de Wazuh Server (Linux)

- Utilisation du script officiel sur une VM Ubuntu :

```bash
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
bash wazuh-install.sh -a -i
```

6.2 Déploiement de l'agent Wazuh sur Windows Server (SRV-DC01)

- Téléchargement depuis https://documentation.wazuh.com/current/installation-guide/wazuh-agent/wazuh-agent-package-windows.html
- Configuration de l’IP du manager et nom d’agent : SRV-DC01
- Fichier ossec.conf :

```xml
<client>
  <server>
    <address>192.168.153.131</address>
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

(Insérer capture d’écran de l’interface Wazuh avec l’agent connecté)

### 6.3 Contrôle via l’interface Web Wazuh

- Connexion : https://<IP_WAZUH>:443
- Visualisation de l’agent Windows, alertes, logs de sécurité

(Insérer capture d’écran de l’interface Wazuh)

## Résultat final

L'infrastructure est pleinement fonctionnelle et sécurisée :
- Un domaine mondomaine.local opérationnel
- Des stratégies de sécurité appliquées
- Une supervision active avec Wazuh
- Un environnement prêt à gérer des utilisateurs et machines en production
