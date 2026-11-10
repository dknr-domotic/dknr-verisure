# README

[![Release](https://img.shields.io/docker/v/jcpd/dknr-verisure?sort=semver)](https://img.shields.io/docker/v/jcpd/dknr-verisure?sort=semver)
[![Pull](https://img.shields.io/docker/pulls/jcpd/dknr-verisure)](https://img.shields.io/docker/pulls/jcpd/dknr-verisure)
[![Issue](https://img.shields.io/github/issues/dknr-domotic/dknr-verisure)](https://img.shields.io/github/issues/dknr-domotic/dknr-verisure)
[![License](https://img.shields.io/github/license/dknr-domotic/dknr-verisure)](https://github.com/dknr-domotic/dknr-verisure/blob/master/LICENSE)


## A propos

**dknr-verisure** est un projet consacré à la récupération et à l'exploitation de l'état d'une alarme Verisure France. Il n'existe pas d'accès local à la centrale Verisure : ce projet interroge le cloud Verisure, avec la même API que l'application My Verisure.

Toutes les informations sont regroupées sur votre serveur MQTT, dans la même arborescence que les autres projets DKNR.

Ce projet n'est ni édité ni soutenu par Verisure. L'API utilisée n'est pas publique, elle peut changer sans préavis.


## Fonctionnalités

- **Connexion avec le compte My Verisure**, validation par SMS comprise.
- **Mot de passe jamais enregistré** : seul le jeton de session est conservé, il est renouvelé automatiquement.
- **Support de plusieurs installations** d'un même compte.
- **Etat de l'alarme** : désarmée, partielle jour, partielle nuit, totale (et les combinaisons périmétrique / annexe).
- **Lecture périodique** à intervalle réglable, sans réveiller la centrale.
- **Support Home-Assistant Discovery** en lecture.

Le pilotage (armer, désarmer) n'est pas encore disponible, voir [A faire](#a-faire).


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

Les installations du compte apparaissent ensuite dans la page **Alarme**.

Si Verisure ferme la session (changement de mot de passe, déconnexion des appareils depuis l'application...), la page **Alarme** l'indique et il faut se reconnecter depuis la page **Compte**. Le projet ne retente jamais seul une connexion.

Le bouton **Déconnecter** ferme la session et efface le compte, ses installations et leurs topics MQTT.

### Intervalle de lecture

Dans la page **Configurer**, l'**intervalle de lecture** est de 180 secondes par défaut et de 60 secondes au minimum. Verisure bloque temporairement les accès trop fréquents : dans ce cas le projet suspend ses lectures pendant 15 minutes.

Un changement d'état de l'alarme est donc connu avec un retard pouvant aller jusqu'à cet intervalle.


## MQTT

Avec le topic `dknr` par défaut, l'identifiant d'un appareil est le numéro de l'installation Verisure :

* `dknr/get/verisure/<id>/<entité>` : valeurs publiées (retenues) à chaque changement.
* `dknr/set/verisure/<id>/refresh` : demande une lecture immédiate (une lecture par 20 secondes au plus).
* `dknr/discovery/verisure/<id>/<entité>` : description des entités.
* `homeassistant/<type>/verisure/<id>_<entité>/config` : Home Assistant Discovery.

Entités :

* `state` : `D` désarmée, `P` partielle jour, `Q` partielle nuit, `T` totale, `E` périmétrique, `B` partielle jour et périmétrique, `C` partielle nuit et périmétrique, `A` totale et périmétrique, `X` annexe, `R` partielle jour et annexe, `S` partielle nuit et annexe, `O` totale et annexe.
* `armed` : `1` si l'alarme est armée, quel que soit le mode, sinon `0`.
* `wifi` : `1` si la centrale est connectée en wifi, sinon `0`.
* `timestamp` : date du dernier changement connu de Verisure.

Seules les entités réellement fournies par l'installation sont publiées.

L'API Verisure ne donne pas l'état des détecteurs d'ouverture ni des détecteurs de mouvement.


## A faire

* **Pilotage** : armer et désarmer depuis MQTT et depuis le tableau de bord.
* Journal d'activité de l'alarme.


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
