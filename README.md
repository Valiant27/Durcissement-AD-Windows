# Projet : Installation et sécurisation d'Active Directory sous Windows Server 2022

## Objectif

Mettre en place une infrastructure Windows Server complète et sécurisée, intégrant Active Directory, DNS, DHCP et un outil de supervision (Wazuh), le tout dans un environnement de test virtualisé avec Hyper-V.

---

## Étape 1 : Préparation de l'environnement

### 1.1 Installation de Windows Server 2022

- ISO officielle de Windows Server 2022 Datacenter montée dans Hyper-V  
- Installation avec "Desktop Experience"  
- Création d’un mot de passe administrateur fort  

*Capture suggérée : écran d'installation de Windows Server*

### 1.2 Configuration réseau

- IP statique : `192.168.1.10`  
- Vérification de la connectivité réseau et Internet  

*Capture suggérée : configuration IP dans les paramètres réseau*

---

## Étape 2 : Installation et configuration d'Active Directory

### 2.1 Renommage du serveur

- Nouveau nom : `SRV-DC01`  
- Redémarrage nécessaire

### 2.2 Installation du rôle AD DS

- Gestionnaire de serveur > Ajouter des rôles et fonctionnalités  
- Sélection : Active Directory Domain Services (AD DS)

### 2.3 Promotion en contrôleur de domaine

- Nouveau domaine : `mondomaine.local`  
- Configuration DSRM  
- Redémarrage automatique

*Capture suggérée : assistant de promotion en contrôleur de domaine*

---

## Étape 3 : Sécurisation et configuration avancée

### 3.1 GPO : stratégies de sécurité

- GPO appliquée à l'OU `Users` :
  - Mots de passe complexes (≥12 caractères, expiration : 90j)
  - Désactivation des comptes inactifs après 30 jours
  - Restrictions des droits administrateurs

*Capture suggérée : paramètres GPO dans GPMC*

### 3.2 Audit des événements

- Connexions réussies et échouées  
- Modifications AD (groupes, comptes)

*Capture suggérée : stratégie d’audit configurée*

### 3.3 Observateur d’événements

- Vérification des journaux de sécurité :  
  `Observateur d’événements > Journaux Windows > Sécurité`

*Capture suggérée : journal montrant une tentative de connexion*

---

## Étape 4 : Tests de l’infrastructure

### 4.1 Test GPO

- Création utilisateur `test_user`  
- Connexion avec mot de passe faible → Refusée  
- `gpupdate /force` + redémarrage pour valider l’application

### 4.2 Logs de connexion

- Vérification dans l'Observateur d’événements

### 4.3 Ajout d’une machine cliente Windows 10

- Réglage IP et DNS (DNS = IP du DC)  
- Rejoint le domaine `mondomaine.local`  
- Connexion avec : `mondomaine\test_user`

*Capture suggérée : écran de connexion au domaine sur Windows 10*

---

## Étape 5 : Configuration DNS & DHCP

### 5.1 DNS

- Déployé automatiquement avec AD DS  
- Vérification des zones directe/inversée  
- Test avec :  
```bash
nslookup srv-dc01.mondomaine.local
```

Capture suggérée : console DNS avec zone directe

### 5.2 DHCP

- Installation du rôle DHCP via le Gestionnaire de serveur  
- Création d’une plage d’adresses : `192.168.1.100 - 192.168.1.150`  
- IP du contrôleur de domaine (192.168.1.10) et de la passerelle (192.168.1.1) sont en dehors de cette plage → aucune exclusion nécessaire  
- Configuration des options DHCP :
  - DNS : `192.168.1.10`
  - Passerelle : `192.168.1.1`
  - Domaine : `mondomaine.local`
- Autorisation du serveur DHCP dans Active Directory

*Capture suggérée : console DHCP affichant la plage d’adresses configurée*

---

## Étape 6 : Supervision avec Wazuh

### 6.1 Installation du Wazuh Server (VM Ubuntu)

- Utilisation du script officiel :
```bash
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
bash wazuh-install.sh -a -i
```

- VM Ubuntu avec au moins 8 Go de RAM et 30 Go d’espace disque
- Port par défaut : https://<IP_WAZUH>:443

Capture suggérée : interface web Wazuh accessible sur le port 443

### 6.2 Déploiement de l'agent Wazuh sur Windows Server (SRV-DC01)

- Téléchargement de l’agent depuis : https://documentation.wazuh.com/current/installation-guide/wazuh-agent/wazuh-agent-package-windows.html
- Configuration dans le fichier C:\\Program Files (x86)\\ossec-agent\\ossec.conf :

```xml
Copier
Modifier
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

Enregistrement de l'agent depuis le manager Linux :
```bash
Copier
Modifier
/var/ossec/bin/manage_agents
Coller la clé dans l’agent Windows
```

Redémarrage du service agent :
```powershell
Copier
Modifier
sc stop wazuh-agent
sc start wazuh-agent
```

Capture suggérée : agent Windows visible dans l’interface Wazuh (en ligne)

### 6.3 Vérification de la collecte des logs

- Génération d’événements : connexions, déconnexions, erreurs, modification d’utilisateurs, etc.
- Ces événements doivent apparaître dans le tableau de bord Wazuh
- Possibilité de filtrer les événements par gravité, nom de l’agent, type, etc.

Capture suggérée : tableau de bord Wazuh affichant les événements de sécurité du contrôleur de domaine

## Résultat final

- L’environnement de test simule une infrastructure Windows sécurisée et supervisée :
- Contrôleur de domaine fonctionnel : SRV-DC01.mondomaine.local
- Stratégies de sécurité via GPO appliquées aux utilisateurs
- DHCP distribue dynamiquement les adresses IP
- Supervision active des journaux avec Wazuh (agent installé sur le DC)

## Contexte

- Projet personnel réalisé sous Hyper-V, dans un objectif de montée en compétences en :
- Administration Active Directory
- Sécurisation des environnements Windows
- Configuration des services réseau (DHCP, DNS)
- Supervision et gestion centralisée des événements de sécurité

## Prochaines pistes d'amélioration

- Joindre un poste Linux au domaine via realmd ou sssd
- Déployer des scripts PowerShell pour l’automatisation AD
- Ajouter des règles personnalisées dans Wazuh pour détecter les comportements suspects (modifications de GPO, escalades de privilèges, etc.)
