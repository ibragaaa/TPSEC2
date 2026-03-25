# Universite de Poitiers - Master 1 TDSI

## Compte rendu propose - TP 2 Chiffrement reseau

**Etudiant(e)(s) :** A COMPLETER  
**Formation :** Master 1 TDSI  
**UE :** Reseau et securite  
**Sujet :** `chiffrement-reseau_2025-2026_etudiants_tp2.pdf`

---

## Introduction

Dans ce depot Git, on ne trouve pas un projet de developpement classique avec du code source, mais surtout un ensemble de supports de cours et le sujet officiel du TP. J'ai donc commence par faire une lecture complete du depot pour comprendre de quoi il s'agissait exactement, puis j'ai relie le sujet aux documents de cours les plus utiles.

Le TP porte sur la mise en place de communications chiffrees dans deux cas concrets :

- un service de transfert de fichiers avec **FTPS** ;
- un service web securise avec **HTTPS**.

L'idee generale est assez claire : partir de services reseau classiques, puis ajouter un certificat, activer TLS, verifier le comportement cote client et comprendre ce qui change vraiment au niveau securite.

Ce compte rendu est redige comme un rendu etudiant. Il peut servir directement de base de devoir a rendre, quitte a remplacer ensuite les champs a completer par les vraies valeurs choisies pendant la seance et a ajouter quelques captures d'ecran si besoin.

---

## 1. Analyse complete du depot

### 1.1 Nature generale du depot

Le depot contient essentiellement des fichiers PDF. Il s'agit donc plutot d'un depot de travail et de cours qu'un depot logiciel. J'y ai retrouve :

- le sujet du TP ;
- plusieurs supports de cryptographie ;
- plusieurs supports de reseaux ;
- plusieurs supports de securite reseau et de filtrage ;
- des notices pour la machine virtuelle utilisee en TP.

Autrement dit, le depot fournit a la fois le **travail a faire** et presque tout le **contexte theorique** necessaire pour le comprendre.

### 1.2 Fichiers les plus importants pour ce TP

Les documents qui m'ont paru les plus directement utiles sont les suivants :

- `chiffrement-reseau_2025-2026_etudiants_tp2.pdf` : sujet officiel ;
- `cryptography_base_course_student.pdf` : bases de cryptographie, RSA, Diffie-Hellman, certificats, PKI ;
- `cryptography_communication_course_student.pdf` : fonctionnement de SSL/TLS ;
- `Security-overview-students.pdf` : objectifs globaux de securite ;
- `1-IntroModeles-2.pdf`, `3-ReseauxIP-2.pdf`, `4-Transport-2.pdf` : rappels sur les couches, IP, TCP/UDP et les ports ;
- `03_Network-Security_Iptables.pdf` et les autres supports firewall : utiles pour comprendre pourquoi FTP est historiquement un protocole plus delicat a securiser et a filtrer ;
- `Install-VM-H04.pdf` et `M1-OC_virtualbox.pdf` : utiles pour l'environnement de travail.

### 1.3 Ce que montrent les supports de cours dans leur ensemble

En lisant tous les fichiers du depot, on voit que le TP s'inscrit dans une progression assez logique :

1. d'abord les bases des reseaux : couches OSI, TCP/IP, IP, transport ;
2. ensuite la securite reseau : architecture, firewalls, filtrage, tests ;
3. enfin la cryptographie appliquee aux communications : certificats, TLS, services securises.

Le TP n'arrive donc pas "tout seul". Il est clairement place a l'endroit ou on commence a passer de la theorie a des cas concrets d'administration reseau et systeme.

---

## 2. Analyse du sujet `chiffrement-reseau_2025-2026_etudiants_tp2.pdf`

Le sujet est decoupe en deux parties principales :

1. **FTP securise** avec Pure-FTPd et TLS ;
2. **HTTPS** avec Apache, un nom local personnalise et un certificat.

Il y a aussi, dans les deux parties, une dimension optionnelle d'analyse de trames avec Wireshark.

Ce que j'ai retenu du sujet, c'est qu'il ne demande pas seulement de faire marcher des commandes. Il cherche surtout a nous faire comprendre :

- comment un certificat est genere ;
- comment une cle privee doit etre protegee ;
- comment un client verifie un certificat ;
- pourquoi un certificat auto-signe declenche un avertissement ;
- en quoi FTPS et HTTPS apportent de la confidentialite et de l'integrite par rapport a FTP et HTTP simples.

Le sujet insiste aussi sur les sauvegardes de fichiers systeme, l'utilisation de `sudo`, et le fait que le rendu attendu est un compte rendu d'etudiant, pas seulement une suite de commandes.

---

## 3. Rappels de cours utiles pour comprendre le TP

### 3.1 Chiffrement symetrique et asymetrique

Dans le cours de base sur la cryptographie, on retrouve la distinction classique :

- le **chiffrement asymetrique** sert surtout a l'authentification, a l'echange de cle et a la gestion des certificats ;
- le **chiffrement symetrique** sert ensuite a chiffrer efficacement les donnees pendant la session.

Dans le TP, on voit exactement ce mecanisme :

- le serveur presente un certificat contenant une cle publique ;
- le client peut verifier ce certificat ;
- ensuite, une cle de session est etablie ;
- les donnees sont alors echangees de facon chiffree.

### 3.2 Certificats X.509

Le support `cryptography_base_course_student.pdf` rappelle qu'un certificat X.509 contient plusieurs informations, notamment :

- l'identite du proprietaire ;
- la cle publique ;
- la periode de validite ;
- l'algorithme utilise ;
- l'emetteur du certificat.

Dans ce TP, les certificats sont auto-signes. C'est un point tres important, parce que cela explique les messages d'alerte observes cote client. En fait, le probleme n'est pas l'absence de chiffrement, mais l'absence de confiance fournie par une autorite reconnue.

### 3.3 SSL / TLS

Le support `cryptography_communication_course_student.pdf` detaille le principe general d'une session TLS :

1. le client envoie une demande de connexion ;
2. le serveur repond avec ses parametres et son certificat ;
3. le client examine ces informations ;
4. une cle de session est mise en place ;
5. la suite des echanges est chiffree.

C'est ce mecanisme qu'on retrouve dans :

- **FTPS** = FTP + TLS ;
- **HTTPS** = HTTP + TLS.

### 3.4 Couches et ports

Les supports reseaux rappellent que TLS s'appuie sur TCP. On peut donc resumer les choses ainsi :

- couche application : FTP ou HTTP ;
- couche de securisation : TLS ;
- couche transport : TCP ;
- couche reseau : IP.

Le cours sur TCP/UDP rappelle aussi les ports classiques :

- FTP controle : 21 ;
- FTP data : 20 ;
- HTTP : 80 ;
- HTTPS : 443.

Cela aide a comprendre pourquoi FTP est plus particulier que HTTP. FTP utilise historiquement plusieurs flux et cela complique parfois le filtrage ou le suivi de session, ce qui est d'ailleurs mentionne dans les supports sur `iptables`.

### 3.5 Le role de `/etc/hosts`

Le sujet demande d'ajouter une ligne comme :

```text
127.0.0.2 NOM_PRENOM.org
```

Les cours IP rappellent qu'une grande partie du bloc `127.0.0.0/8` correspond au loopback. Donc `127.0.0.2` designe encore la machine locale. Cela permet de tester un "vrai" nom de serveur sans passer par un DNS externe.

---

## 4. Partie 1 - Mise en place de FTPS

### 4.1 Objectif de la partie

Dans cette premiere partie, le but est de prendre un serveur FTP qui fonctionne sans chiffrement par defaut, puis de le faire passer en **mode securise avec TLS**. L'interet est double :

- authentifier le serveur ;
- proteger les donnees qui transitent.

### 4.2 Activation de TLS dans Pure-FTPd

La premiere verification se fait avec :

```bash
systemctl status pure-ftpd
```

Ensuite, le sujet demande de creer le fichier de configuration `TLS` avec la valeur `2` :

```bash
echo 2 | sudo tee /etc/pure-ftpd/conf/TLS
```

J'interprete cette valeur comme le fait d'imposer TLS et donc d'eviter les connexions FTP non chiffrees.

### 4.3 Creation du certificat et de la cle privee

La commande demandee est :

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:3072 -out NOM_PRENOM.cert.pem -keyout NOM_PRENOM_PRIV.key.pem
```

Cette commande est interessante parce qu'elle montre directement plusieurs choix de securite :

- certificat auto-signe ;
- algorithme RSA ;
- longueur de cle de 3072 bits ;
- validite d'un an ;
- cle privee non protegee par mot de passe pour permettre le demarrage du service.

Le point auquel il faut faire attention est le **Common Name**. Il doit correspondre au nom du serveur. Dans la premiere partie, on peut rester sur `localhost` si le sujet n'a pas encore introduit de nom personnalise.

### 4.4 Protection de la cle privee

Le sujet insiste a juste titre sur les droits d'acces. Une cle privee ne doit surtout pas etre exposee. J'ai trouve cette partie pedagogiquement importante, parce qu'on voit bien qu'activer TLS ne suffit pas : il faut aussi proteger les fichiers sensibles au niveau systeme.

Le sujet demande ensuite de regrouper certificat et cle privee dans :

```text
/etc/ssl/private/pure-ftpd.pem
```

et de limiter les droits a l'administrateur.

Exemple de logique attendue :

```bash
chmod 640 NOM_PRENOM_PRIV.key.pem
sudo cat NOM_PRENOM.cert.pem NOM_PRENOM_PRIV.key.pem | sudo tee /etc/ssl/private/pure-ftpd.pem
sudo chmod 600 /etc/ssl/private/pure-ftpd.pem
```

### 4.5 Parametres supplementaires pour le chiffrement

Le sujet fait ensuite generer les parametres Diffie-Hellman :

```bash
sudo openssl dhparam -out /etc/ssl/private/pure-ftpd-dhparams.pem 3072
```

Cette etape peut etre longue, mais elle a du sens par rapport au cours : elle s'inscrit dans la logique d'etablissement de cle pour la session TLS.

### 4.6 Redemarrage du service

Une fois la configuration terminee :

```bash
sudo systemctl restart pure-ftpd
systemctl status pure-ftpd
```

Si tout se passe bien, le service redemarre correctement. En cas de probleme, c'est a ce moment-la qu'il faut verifier les fichiers, les chemins et les permissions.

### 4.7 Preparation des repertoires de test

Le sujet s'appuie sur deux utilisateurs deja presents :

- `ftptest1` ;
- `ftptest2`.

Pour chacun d'eux, il faut creer :

- un dossier `FTP/prive` ;
- un dossier `FTP/public`.

L'idee est de faire varier les droits :

- `prive` doit rester reserve au proprietaire ;
- `public` doit permettre l'echange de fichiers.

Une mise en oeuvre classique serait :

```bash
mkdir -p ~/FTP/prive ~/FTP/public
chmod 700 ~/FTP/prive
chmod 777 ~/FTP/public
```

Ce point est important, parce qu'il montre que le chiffrement du transport et les permissions Unix ne repondent pas au meme besoin.

### 4.8 Test avec FileZilla

Le test demande de lancer FileZilla en tant qu'utilisateur `ftptest1`, puis de se connecter au serveur FTP local.

Lors de la connexion, on s'attend a voir apparaitre une fenetre de type **"certificat inconnu"**. Pour moi, c'est presque un resultat attendu du TP. Ce message prouve au contraire que le certificat est bien presente par le serveur.

L'explication est simple :

- le certificat existe ;
- il est coherent avec ce qui a ete saisi ;
- mais il n'est pas signe par une autorite de certification reconnue.

Apres validation du certificat, on verifie le comportement des repertoires :

- le dossier prive de `ftptest2` n'est pas accessible ;
- le dossier public de `ftptest2` est accessible ;
- un televersement vers `ftptest2/FTP/public` fonctionne ;
- un telechargement dans l'autre sens fonctionne aussi.

### 4.9 Ce que montre cette partie

Cette premiere partie illustre bien deux idees :

1. **TLS protege le transport** ;
2. **les droits Unix protegent l'acces local aux ressources**.

Autrement dit, meme avec FTPS, un mauvais parametrage des repertoires resterait un probleme. Et inversement, de bons droits Unix ne remplacent pas le chiffrement sur le reseau.

### 4.10 Observation optionnelle avec Wireshark

Si on refait le transfert sous Wireshark, on doit observer :

- une connexion TCP initiale ;
- une phase de negotiation TLS ;
- puis des donnees applicatives qui ne sont plus lisibles en clair.

Cette partie est tres interessante visuellement, parce qu'elle permet de voir concretement la difference entre un service reseau fonctionnel et un service reseau chiffre.

---

## 5. Partie 2 - Mise en place de HTTPS

### 5.1 Objectif de la partie

La deuxieme partie reprend la meme logique, mais appliquee cette fois a un serveur web Apache. L'objectif est de passer d'un site HTTP simple a un site HTTPS personnalise.

### 5.2 Verification de la situation initiale

On commence par verifier qu'Apache fonctionne :

```bash
sudo service apache2 status
```

Ensuite, le sujet demande de tester dans le navigateur :

- `http://localhost`
- `https://localhost`

Normalement, seule l'URL en HTTP fonctionne au debut. C'est une bonne facon de montrer que HTTPS ne se "devine" pas : il faut une vraie configuration supplementaire.

### 5.3 Ajout d'un nom local personnalise

Le sujet demande ensuite de modifier `/etc/hosts` pour ajouter un nom du type :

```text
127.0.0.2 NOM_PRENOM.org
```

Cette etape m'a paru tres utile pedagogiquement. Elle permet de simuler un nom de serveur personnalise sans disposer d'un vrai domaine ni d'un DNS externe.

Le test :

```bash
ping -c 1 127.0.0.2
ping -c 1 NOM_PRENOM.org
```

doit montrer que le nom choisi renvoie bien vers la machine locale.

### 5.4 Generation d'un certificat pour Apache

Le sujet demande ensuite de generer un nouveau certificat, toujours auto-signe, mais cette fois avec comme **Common Name** le nom defini dans `/etc/hosts`.

Par exemple :

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:3072 -out NOM_PRENOM_HTTPS.cert.pem -keyout NOM_PRENOM_HTTPS_PRIV.key.pem
```

On retrouve exactement la meme logique que pour FTPS, mais appliquee au service web.

### 5.5 Activation de SSL dans Apache

Le module SSL doit etre active :

```bash
sudo a2enmod ssl
```

Puis il faut preparer un repertoire web personnalise dans `/var/www` avec une page `index.html`, par exemple :

```html
<h1>Serveur HTTPS pour NOM PRENOM</h1>
```

Cette personnalisation est utile, parce qu'elle permet de verifier qu'on arrive bien sur le site configure pour le TP, et non sur la page standard d'Apache.

### 5.6 Configuration du site HTTPS

Le sujet demande de partir du fichier de configuration SSL par defaut et de le dupliquer :

```bash
sudo cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/NOM_PRENOM_SSL.conf
```

Puis il faut ajuster notamment :

- `ServerAdmin`
- `ServerName`
- `DocumentRoot`
- `SSLCertificateFile`
- `SSLCertificateKeyFile`

Ces directives lient ensemble :

- le nom du serveur ;
- le contenu web servi ;
- le certificat et la cle privee.

### 5.7 Activation du site et rechargement

Le site n'est pas actif tant qu'il n'est pas explicitement active :

```bash
sudo a2ensite NOM_PRENOM_SSL.conf
sudo systemctl reload apache2
sudo service apache2 status
```

Si la configuration est correcte, le site HTTPS devient accessible.

### 5.8 Test dans le navigateur

Quand on ouvre :

```text
https://nom_prenom.org
```

le navigateur affiche normalement un avertissement. La aussi, l'interpretation est importante :

- le certificat est bien envoye par le serveur ;
- le chiffrement est bien en place ;
- mais le certificat n'est pas reconnu comme fiable, car il est auto-signe.

Il faut donc accepter l'exception de securite pour continuer.

Une fois cet avertissement passe, on doit voir la page HTML personnalisee.

Le sujet demande egalement de verifier que :

```text
http://localhost
```

renvoie toujours vers la page par defaut d'Apache. Cela montre que les deux sites peuvent coexister en parallele.

### 5.9 Interet de l'analyse Wireshark

Comme pour FTPS, l'observation dans Wireshark permet de voir :

- la connexion TCP ;
- la negotiation TLS ;
- puis un trafic web chiffre.

Cela permet de visualiser tres concretement ce que le cours presente de maniere theorique.

---

## 6. Lien avec les autres supports du depot

Apres lecture complete du depot, j'ai trouve interessant de relier le sujet a plusieurs autres supports.

### 6.1 Lien avec les cours de reseaux

Les cours d'introduction, d'IP et de transport permettent de replacer le TP dans l'empilement des couches. On voit bien que :

- FTP et HTTP sont des protocoles applicatifs ;
- TCP sert de transport ;
- TLS vient ajouter la securite au-dessus de TCP ;
- IP assure l'acheminement.

Cela aide a comprendre que le chiffrement n'annule pas le fonctionnement des autres couches : il vient s'y ajouter.

### 6.2 Lien avec les cours de cryptographie

Les cours de cryptographie donnent tout le cadre theorique du TP :

- certificats X.509 ;
- cryptographie asymetrique ;
- cryptographie symetrique ;
- Diffie-Hellman ;
- PKI ;
- handshake TLS.

En pratique, le TP sert presque de mise en application directe de ces notions.

### 6.3 Lien avec les supports firewall

Les documents sur le filtrage et `iptables` montrent bien que FTP est un protocole particulier, notamment a cause de ses connexions de controle et de donnees. J'ai trouve que cela donnait encore plus de sens a la partie FTPS : securiser FTP est utile, mais ce n'est pas forcement le protocole le plus simple a administrer dans une architecture complete.

HTTPS apparait au contraire comme un cas plus naturel aujourd'hui, car le web chiffre est devenu la norme.

### 6.4 Lien avec les objectifs de securite

Le support `Security-overview-students.pdf` rappelle les objectifs classiques :

- authentification ;
- confidentialite ;
- integrite ;
- non-repudiation ;
- disponibilite.

Dans ce TP, les objectifs principalement travailles sont surtout :

- l'**authentification du serveur** ;
- la **confidentialite** ;
- l'**integrite** des echanges.

---

## 7. Ce que je retiens du TP

Personnellement, ce TP m'a paru interessant parce qu'il fait le lien entre plusieurs aspects souvent vus separement en cours :

- administration systeme ;
- protocoles reseau ;
- cryptographie ;
- verification cote client.

Il montre aussi qu'un service securise ne repose pas sur une seule commande magique. Pour obtenir un resultat correct, il faut combiner :

- un service bien configure ;
- un certificat coherent ;
- une cle privee bien protegee ;
- un client capable de verifier le certificat ;
- et, en plus, de bonnes permissions locales.

J'ai aussi trouve utile de voir que les avertissements du navigateur ou de FileZilla ne signifient pas forcement que "ca ne marche pas". Souvent, cela veut juste dire que le chiffrement existe bien, mais que la confiance dans le certificat n'est pas encore etablie par une autorite reconnue.

---

## Conclusion

Pour conclure, ce TP illustre tres bien l'application concrete du chiffrement dans les communications reseau. La partie FTPS montre comment securiser un service de transfert de fichiers, tandis que la partie HTTPS applique la meme logique a un serveur web Apache.

Ce que je retiens surtout, c'est que la securite ne se limite pas au chiffrement des donnees. Il faut aussi :

- gerer correctement les certificats ;
- proteger les cles privees ;
- configurer proprement les services ;
- comprendre les messages de verification affiches par les clients.

Le TP fait donc bien le lien entre la theorie vue en cours et des manipulations proches de ce qu'on peut rencontrer en administration reseau ou systeme.

---

## Annexe - Commandes principales du sujet

### FTPS

```bash
systemctl status pure-ftpd
echo 2 | sudo tee /etc/pure-ftpd/conf/TLS
sudo openssl req -x509 -nodes -days 365 -newkey rsa:3072 -out NOM_PRENOM.cert.pem -keyout NOM_PRENOM_PRIV.key.pem
sudo cat NOM_PRENOM.cert.pem NOM_PRENOM_PRIV.key.pem | sudo tee /etc/ssl/private/pure-ftpd.pem
sudo chmod 600 /etc/ssl/private/pure-ftpd.pem
sudo openssl dhparam -out /etc/ssl/private/pure-ftpd-dhparams.pem 3072
sudo systemctl restart pure-ftpd
```

### Repertoires utilisateurs

```bash
mkdir -p ~/FTP/prive ~/FTP/public
chmod 700 ~/FTP/prive
chmod 777 ~/FTP/public
```

### HTTPS

```bash
sudo service apache2 status
sudo a2enmod ssl
sudo cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/NOM_PRENOM_SSL.conf
sudo a2ensite NOM_PRENOM_SSL.conf
sudo systemctl reload apache2
sudo service apache2 status
```

### Tests locaux

```bash
ping -c 1 127.0.0.2
ping -c 1 nom_prenom.org
```
