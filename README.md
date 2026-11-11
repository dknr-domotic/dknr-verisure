# README

[![Release](https://img.shields.io/docker/v/jcpd/dknr-verisure?sort=semver)](https://img.shields.io/docker/v/jcpd/dknr-verisure?sort=semver)
[![Pull](https://img.shields.io/docker/pulls/jcpd/dknr-verisure)](https://img.shields.io/docker/pulls/jcpd/dknr-verisure)
[![Issue](https://img.shields.io/github/issues/dknr-domotic/dknr-verisure)](https://img.shields.io/github/issues/dknr-domotic/dknr-verisure)
[![License](https://img.shields.io/github/license/dknr-domotic/dknr-verisure)](https://github.com/dknr-domotic/dknr-verisure/blob/master/LICENSE)


## A propos

**dknr-verisure** est un projet consacré au pilotage, à la récupération et à l'exploitation de l'état d'une alarme Verisure France. Il n'existe pas d'accès local à la centrale Verisure : ce projet interroge le cloud Verisure, avec la même API que l'application My Verisure.

Toutes les informations sont regroupées sur votre serveur MQTT, dans la même arborescence que les autres projets DKNR.

Ce projet n'est ni édité ni soutenu par Verisure. L'API utilisée n'est pas publique, elle peut changer sans préavis.

La documentation détaillée est sur [dknr-domotic.github.io](https://dknr-domotic.github.io/sources/verisure/).


## Fonctionnalités

- **Connexion avec le compte My Verisure**, validation par SMS comprise.
- **Mot de passe jamais enregistré** : seul le jeton de session est conservé, il est renouvelé automatiquement.
- **Support de plusieurs installations** d'un même compte.
- **Etat de l'alarme** : désarmée, partielle jour, partielle nuit, totale (et les combinaisons périmétrique / annexe).
- **Lecture périodique** à intervalle réglable, sans réveiller la centrale.
- **Pilotage** de l'alarme intérieure : désarmer, partielle jour, partielle nuit, totale.
- **Désarmement par MQTT désactivé par défaut**, à autoriser explicitement.
- **Journal** des événements de l'alarme (mises en service, désactivations, alarmes, coupures...) et dernier événement publié sur MQTT.
- **Support Home-Assistant Discovery** en lecture et pilotage.


## Matériel requis

* une alarme Verisure France et un compte My Verisure.
* une machine exécutant le logiciel docker et ayant accès à internet.

Il est conseillé de créer dans l'application My Verisure un utilisateur réservé à ce projet.


## Installation

Des images Docker prêtes à l'emploi sont disponibles. 
Utilisez le fichier docker-compose.yaml à la racine du dépôt en fournissant les variables d'environnement suivantes :

* **DKNR_USERNAME** : login de l'interface node-red.
* **DKNR_PASSWORD** : mot de passe de l'interface node-red.
* **DKNR_SECRET**   : un mot secret pour encrypter les credits.

Le tableau de bord est disponible sur `http://<ip du serveur docker>:1880/` et l'éditeur Node-RED sur `http://<ip du serveur docker>:1880/admin`.


## Configuration

### Connecter le compte

Dans la page **Compte** :

* saisissez l'**identifiant** et le **mot de passe** My Verisure. Attention, Verisure bloque le compte après plusieurs mots de passe erronés.
* si Verisure demande une validation, choisissez le **numéro de téléphone**, cliquez sur **Recevoir le code par SMS** puis saisissez le **code reçu**. Cette validation n'est demandée qu'une fois, tant que le compte reste connecté.

Les installations du compte apparaissent ensuite dans la page **Alarme**. Chaque installation porte un nom, « Alarme » par défaut, modifiable depuis cette page : l'alias donné par Verisure est l'adresse de l'installation, il n'est jamais publié sur MQTT.

En cas d'échec, la ligne **Dernière erreur** de la page **Compte** donne la réponse exacte de Verisure. Si Verisure refuse la connexion, ne multipliez pas les essais : vérifiez d'abord que l'application My Verisure se connecte toujours.

Si Verisure ferme la session (changement de mot de passe, déconnexion des appareils depuis l'application...), la page **Alarme** l'indique et il faut se reconnecter depuis la page **Compte**. Le projet ne retente jamais seul une connexion.

Le bouton **Déconnecter** ferme la session et efface le compte, ses installations et leurs topics MQTT.

### Intervalle de lecture

Dans la page **Configurer**, l'**intervalle de lecture** est de 180 secondes par défaut et de 60 secondes au minimum. Verisure bloque temporairement les accès trop fréquents : dans ce cas le projet suspend ses lectures pendant 15 minutes.

Un changement d'état de l'alarme fait depuis le clavier ou l'application est donc connu avec un retard pouvant aller jusqu'à cet intervalle.

### Journal

La page **Journal** liste les derniers événements de l'alarme connus de Verisure (100 au plus), avec leur auteur : utilisateur de l'application, badge, détecteur...

Le journal est lu à chaque changement d'état de l'alarme, à l'ouverture de la page, et sinon toutes les 15 minutes. Un événement qui ne change pas l'état de l'alarme (coupure de courant, par exemple) peut donc être connu avec 15 minutes de retard.

### Pilotage

Dans la page **Alarme**, les boutons **Désarmer**, **Jour**, **Nuit** et **Totale** changent le mode de l'alarme. Le bouton coloré est le mode actuel. Une commande prend une dizaine de secondes, le temps que la centrale réponde ; son résultat est affiché en notification.

* Passer d'un mode armé à un autre (par exemple de totale à partielle nuit) **désarme puis réarme** l'alarme.
* Si une porte ou une fenêtre est ouverte, Verisure refuse l'armement et le nom de la zone est indiqué. L'armement forcé n'est pas géré.
* Seule l'alarme intérieure est pilotée, pas le périmétrique ni l'annexe.

Par défaut, **MQTT peut armer mais pas désarmer** : toute personne ou tout appareil pouvant publier sur votre serveur MQTT pourrait sinon couper l'alarme. Pour l'autoriser, cochez **Autoriser le désarmement par MQTT** dans la page **Configurer**. Sans cette option, un changement de mode d'une alarme déjà armée est aussi refusé par MQTT, puisqu'il passe par un désarmement.

Le tableau de bord de ce projet n'est pas protégé par mot de passe et permet de désarmer : ne l'exposez pas en dehors de votre réseau local.


## MQTT

Avec le topic `dknr` par défaut, l'identifiant d'un appareil est le numéro de l'installation Verisure :

* `dknr/get/verisure/<id>/<entité>` : valeurs publiées (retenues) à chaque changement.
* `dknr/set/verisure/<id>/mode` : `D`, `P`, `Q` ou `T` (ou le nom du mode). Une commande retenue (retain) est ignorée.
* `dknr/set/verisure/<id>/refresh` : demande une lecture immédiate (une lecture par 20 secondes au plus).
* `dknr/discovery/verisure/<id>/<entité>` : description des entités.
* `homeassistant/<type>/verisure/<id>_<entité>/config` : Home Assistant Discovery.

Entités :

* `fault` : `1` en défaut, `0` quand tout va bien. Le défaut est levé quand le compte n'est pas connecté (session expirée, validation par SMS en attente) ou quand aucune lecture valide de l'alarme n'a abouti depuis 3 intervalles de lecture (10 minutes au minimum), par exemple sans internet, Verisure en panne ou accès suspendu par Verisure. Elle est déclarée en discovery DKNR (type binaire) et Home Assistant (binary_sensor de type « problem »), pour servir d'alerte dans votre domotique.
* `mode` : mode de l'alarme intérieure, en lecture et en commande : `D` désarmée, `P` partielle jour, `Q` partielle nuit, `T` totale.
* `state` : `D` désarmée, `P` partielle jour, `Q` partielle nuit, `T` totale, `E` périmétrique, `B` partielle jour et périmétrique, `C` partielle nuit et périmétrique, `A` totale et périmétrique, `X` annexe, `R` partielle jour et annexe, `S` partielle nuit et annexe, `O` totale et annexe.
* `armed` : `1` si l'alarme est armée, quel que soit le mode, sinon `0`.
* `wifi` : `1` si la centrale est connectée en wifi, sinon `0`.
* `event` : texte du dernier événement, tel que donné par Verisure.
* `event_type` : type du dernier événement : `armed`, `armed_with_exceptions`, `arming_failed`, `disarmed`, `alarm`, `alarm_resolved`, `tampering`, `sabotage`, `image_request`, `power_cut`, `power_restored`, `status_check`, `communication_failed`, `communication_restored`, `door_opened`, `door_closed`, `routine_executed`, `tag_or_remote_activated`, `high_temperature`, `unknown`.
* `event_by` : auteur du dernier événement (utilisateur, badge, détecteur...).
* `event_time` : date du dernier événement, au format ISO 8601 (UTC).
* `timestamp` : date de la dernière mise à jour connue de Verisure, au format ISO 8601 (UTC).

Seules les entités réellement fournies par l'installation sont publiées.

L'API Verisure ne donne pas l'état des détecteurs d'ouverture ni des détecteurs de mouvement.


## A faire

* Armement forcé lorsqu'une zone est ouverte.
* Pilotage du périmétrique et de l'annexe.
* Photos des détecteurs-caméras.


## Contribuer

Ce projet est **open-source**, vous pouvez participer en créant des [tickets](https://github.com/dknr-domotic/dknr-verisure/issues) ou en proposant de [requêtes](https://github.com/dknr-domotic/dknr-verisure/pulls) sur le dépôt github du projet.


## Voir aussi

- [DKNR Teleinfo](https://github.com/dknr-domotic/dknr-teleinfo)
- [DKNR APSystems](https://github.com/dknr-domotic/dknr-apsystems)
- [DKNR Daikin](https://github.com/dknr-domotic/dknr-daikin)
- [DKNR Zendure](https://github.com/dknr-domotic/dknr-zendure)
- [DKNR RFXCom](https://github.com/dknr-domotic/dknr-rfxcom)
- [DKNR Nuki](https://github.com/dknr-domotic/dknr-nuki)
- [securitas-direct-new-api](https://github.com/guerrerotook/securitas-direct-new-api), intégration Home Assistant dont le protocole est repris ici.
