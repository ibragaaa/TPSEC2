# Compte rendu propose - TP2 Chiffrement reseau

## Page de garde

**Universite de Poitiers**  
**Master 1 TDSI**  
**Reseaux et Securite**  
**TP2 - Chiffrement reseau**

**Etudiant(e)s :** NOM1 PRENOM1 / NOM2 PRENOM2  
**Date :** A COMPLETER  
**Enseignant :** Xavier Skapin

---

## Note prealable

Le present document est un compte rendu propose, redige dans un style naturel de rendu etudiant de M1 TDSI a partir de l'analyse complete du depot Git, des supports de cours et du sujet `chiffrement-reseau_2025-2026_etudiants_tp2.pdf`. Il peut etre rendu quasiment tel quel, mais il est conseille de personnaliser les noms, les captures d'ecran et les quelques informations qui dependent des manipulations reellement faites sur votre machine virtuelle.

---

## 1. Introduction

Dans ce TP, l'objectif etait de mettre en place deux services reseau securises sur une machine Linux de TP :

- un service FTPS, c'est-a-dire un serveur FTP protege par TLS ;
- un service HTTPS avec Apache et un certificat TLS.

L'interet pedagogique du TP est de passer d'une approche purement theorique de la securisation des communications a une mise en pratique concrete. Le sujet ne demande pas seulement d'executer des commandes : il oblige aussi a comprendre le role des certificats X.509, la difference entre un service non chiffre et un service chiffre, ainsi que l'importance des droits d'acces sur les fichiers sensibles comme les cles privees.

Ce TP s'inscrit de maniere assez logique dans la progression du cours. On retrouve des notions vues en reseaux generaux, dans les couches IP et transport, dans les supports sur la securite reseau, et surtout dans les cours de cryptographie et de communications securisees. Le travail demande est donc a la fois systeme, reseau et securite.

---

## 2. Analyse du depot Git

L'analyse du depot montre qu'il ne s'agit pas d'un projet logiciel classique avec du code source, mais plutot d'un depot de travail pedagogique qui rassemble des supports de cours PDF et le sujet du TP. Les fichiers suivis dans Git sont essentiellement des documents de cours et d'encadrement.

On y trouve en particulier :

- des supports d'introduction aux reseaux et aux modeles de communication ;
- des supports sur la couche liaison, l'adressage IP et les protocoles TCP/UDP ;
- des supports de securite reseau sur les pare-feu, le filtrage et `iptables` ;
- deux supports de cryptographie ;
- des notices de mise en place de la machine virtuelle ;
- le sujet du TP de chiffrement reseau ;
- un sujet d'examen, utile pour comprendre le niveau attendu dans l'UE.

Cette organisation montre que le depot sert surtout de base documentaire. Autrement dit, le coeur du travail ne repose pas sur du developpement logiciel, mais sur l'exploitation d'un environnement Linux et sur la mise en oeuvre de services reseau securises.

---

## 3. Ce que les supports de cours apportent au TP

### 3.1 Reseaux et couches

Les cours de base sur les reseaux rappellent que la communication s'appuie sur plusieurs couches. Cette idee est utile ici parce que le TP mobilise en meme temps :

- la couche application avec FTP, HTTP, HTTPS et les outils clients ;
- la couche transport avec TCP ;
- la couche reseau avec IP et la resolution locale des noms ;
- la couche presentation au sens large, puisque le chiffrement vient proteger les donnees echangees.

Le TP illustre tres bien le fait qu'un service applicatif ne devient pas "securise" tout seul. Il faut ajouter un mecanisme de securisation au-dessus ou autour du service d'origine.

### 3.2 TCP, ports et services

Les cours sur TCP et UDP sont directement utiles. FTP, FTPS, HTTP et HTTPS reposent ici sur TCP. Cela a du sens car on a besoin d'une communication fiable, ordonnee et orientee connexion. Dans le cas du web, le passage de HTTP a HTTPS ne change pas le principe general du service, mais ajoute une couche de securisation TLS au-dessus de la communication TCP.

### 3.3 Cryptographie et certificats

Les deux supports de cryptographie sont probablement les plus importants pour comprendre le TP. Ils rappellent plusieurs idees essentielles :

- le chiffrement symetrique est efficace pour proteger les donnees pendant la session ;
- le chiffrement asymetrique sert notamment a l'echange de cles et a l'authentification ;
- les certificats X.509 permettent d'associer une identite a une cle publique ;
- la confiance accordee a un certificat depend de son emetteur et de la chaine de certification.

Dans notre TP, les certificats sont auto-signes. C'est suffisant pour tester le fonctionnement technique de TLS, mais cela explique aussi pourquoi le navigateur et FileZilla affichent des avertissements. Le service est chiffre, mais il n'est pas adosse a une autorite de certification reconnue.

### 3.4 Communications securisees

Le support sur les communications securisees rappelle le role de SSL/TLS dans la negociation des parametres de securite, l'authentification et la mise en place d'une communication confidentielle. On retrouve exactement cette logique dans les deux parties du TP :

- FTPS utilise TLS pour proteger l'echange FTP ;
- HTTPS utilise TLS pour proteger le trafic HTTP.

Le TP permet donc d'observer concretement ce qui, dans le cours, est presente sous forme de schema ou de sequence protocolaire.

---

## 4. Strategie de travail recommandee

A mon avis, il est pertinent de decouper le travail en trois grandes phases.

### Phase 1 - Analyse

Avant toute manipulation, il faut lire les supports de cours utiles et le sujet du TP. Cette phase permet de comprendre :

- pourquoi on genere un certificat ;
- pourquoi il faut proteger la cle privee ;
- pourquoi un certificat auto-signe declenche un avertissement ;
- pourquoi on teste ensuite avec un client FTP et un navigateur ;
- ce qu'on devrait observer dans Wireshark si on va jusqu'a l'analyse de trames.

### Phase 2 - Execution sur la machine virtuelle

Cette phase consiste a realiser les manipulations sur la VM :

- configuration de Pure-FTPd avec TLS ;
- generation des certificats et parametres cryptographiques ;
- preparation des repertoires et des droits des utilisateurs de test ;
- verification du transfert FTPS avec FileZilla ;
- configuration d'Apache en HTTPS ;
- test dans le navigateur ;
- eventuellement observation du trafic avec Wireshark.

### Phase 3 - Redaction du compte rendu

La derniere phase doit transformer les manipulations en compte rendu clair. Un bon rendu ne se contente pas d'aligner des commandes : il explique le but de chaque etape, ce qu'on observe, et ce que cela prouve du point de vue securite.

Cette methode en trois temps me semble la plus propre, parce qu'elle evite de rediger "a l'aveugle" et elle produit un document plus coherent.

---

## 5. Partie 1 - Mise en place d'un serveur FTPS

### 5.1 Objectif

La premiere partie du TP consiste a securiser un serveur Pure-FTPd. Par defaut, FTP n'est pas adapte a un contexte de securite car les echanges ne sont pas proteges. L'idee ici est donc de forcer l'utilisation de TLS pour obtenir :

- la confidentialite des donnees echangees ;
- une meilleure authentification du serveur ;
- une limitation de l'exposition des identifiants et des fichiers transferes.

### 5.2 Activation de TLS dans Pure-FTPd

Le sujet demande de verifier d'abord que le service `pure-ftpd` est bien actif, puis de creer le fichier `TLS` dans `/etc/pure-ftpd/conf` avec la valeur `2`.

Cette valeur est importante : elle signifie qu'on ne veut pas d'un mode mixte avec FTP non chiffre autorise en parallele, mais un fonctionnement uniquement securise en TLS. Du point de vue securite, c'est plus propre car cela evite qu'un client se connecte sans chiffrement par erreur.

### 5.3 Generation du certificat et de la cle privee

Ensuite, on genere un certificat auto-signe avec `openssl req -x509 -nodes -days 365 -newkey rsa:3072`. Cette commande est interessante pour plusieurs raisons :

- elle cree une nouvelle paire de cles ;
- elle genere un certificat X.509 ;
- elle choisit ici RSA avec une longueur de cle de 3072 bits ;
- elle produit un certificat valable 365 jours.

Le choix de RSA 3072 bits est coherent avec un niveau de securite correct pour un TP. On n'est pas sur une configuration industrielle complete, mais on n'est pas non plus sur une cle trop faible. Le champ `Common Name` doit correspondre au nom reel de la machine ou du service, ce qui est important pour l'identification du serveur par le client.

### 5.4 Protection de la cle privee

Une etape essentielle consiste a limiter les droits sur la cle privee. C'est un point central du TP. Chiffrer un service ne sert pas a grand-chose si n'importe quel utilisateur peut lire la cle privee du serveur. Dans ce cas, un attaquant local pourrait compromettre toute la confiance accordee au service.

Le fait de combiner ensuite le certificat et la cle privee dans `/etc/ssl/private/pure-ftpd.pem`, puis de restreindre fortement les droits sur ce fichier, va dans le meme sens : proteger le secret cryptographique.

### 5.5 Parametres Diffie-Hellman

Le sujet demande aussi de generer des parametres supplementaires avec `openssl dhparam` en 3072 bits. Meme si cette etape est un peu longue, elle a un vrai interet pedagogique. Elle montre qu'un service TLS ne repose pas seulement sur un certificat, mais aussi sur des parametres de negociation qui participent a la securite des echanges.

### 5.6 Preparation des utilisateurs et des repertoires

Le TP fournit deja deux utilisateurs de test : `ftptest1` et `ftptest2`. On doit creer pour chacun un repertoire `FTP` avec deux sous-repertoires :

- `prive`, qui ne doit etre accessible que par son proprietaire ;
- `public`, qui doit au contraire permettre un partage plus large.

Cette partie est tres interessante parce qu'elle rappelle qu'en securite, le chiffrement du transport n'est qu'un maillon de la chaine. Si les droits Unix sont mal regles, le probleme de securite reste entier, meme si la communication est chiffre.

### 5.7 Test avec FileZilla

Le test dans FileZilla permet normalement de verifier plusieurs points :

- la connexion du client au serveur FTPS ;
- l'apparition d'un certificat inconnu, ce qui confirme que le serveur presente bien son certificat ;
- la possibilite de verifier les informations du certificat ;
- l'acces refuse au repertoire prive d'un autre utilisateur ;
- l'acces autorise au repertoire public ;
- le televersement et le telechargement entre les zones publiques.

L'avertissement de certificat inconnu n'est pas ici un echec. Au contraire, dans le contexte du TP, c'est un comportement attendu. Il s'explique par le fait que le certificat est auto-signe et non emis par une autorite de certification reconnue.

### 5.8 Ce que cette partie montre

Cette premiere partie montre qu'il ne suffit pas d'activer un service pour qu'il soit "securise". Il faut :

- activer explicitement TLS ;
- produire un certificat ;
- proteger la cle privee ;
- verifier le comportement du client ;
- combiner la securite de transport et la securite locale des droits d'acces.

---

## 6. Partie 2 - Mise en place d'un serveur HTTPS

### 6.1 Objectif

La seconde partie du TP consiste a activer HTTPS sur Apache. Ici encore, l'idee est de partir d'un service fonctionnel mais non chiffre, puis d'y ajouter TLS pour proteger la communication.

### 6.2 Verification initiale

Le sujet demande de verifier d'abord que le serveur Apache fonctionne deja en HTTP avec `http://localhost`, puis de constater que `https://localhost` ne fonctionne pas encore.

Cette etape est importante parce qu'elle sert de point de comparaison. On part d'un service web operationnel en clair, puis on ajoute la securisation. Pedagogiquement, c'est plus utile que de partir d'une machine deja preconfiguree.

### 6.3 Nouveau nom de serveur

Le fichier `/etc/hosts` est ensuite modifie pour ajouter une correspondance du type `127.0.0.2 NOM_PRENOM.org`.

Cette etape peut paraitre simple, mais elle a un vrai interet. Elle montre qu'un service HTTPS est plus coherent quand il est associe a un nom explicite plutot qu'a `localhost`. Cela permet aussi de faire correspondre le nom du certificat avec le nom utilise dans l'URL. On touche ici au lien entre nom logique, resolution locale et identite du serveur.

Les tests `ping 127.0.0.2` et `ping NOM_PRENOM.org` servent a verifier que la resolution locale est correcte.

### 6.4 Generation du certificat pour Apache

Comme pour FTPS, on genere un nouveau certificat et une nouvelle cle privee avec `openssl`, mais cette fois en prenant soin de mettre dans le `Common Name` le nom du serveur personnalise defini dans `/etc/hosts`.

Ce point est important car, dans une connexion HTTPS, le navigateur compare le nom demande dans l'URL avec l'identite declaree dans le certificat. Si les deux ne correspondent pas, l'avertissement du navigateur est encore plus justifie.

### 6.5 Activation du module SSL et du site

La suite du travail consiste a :

- activer le module SSL avec `a2enmod ssl` ;
- creer un repertoire web personnalise dans `/var/www` ;
- y placer un `index.html` personnalise ;
- copier la configuration par defaut `default-ssl.conf` vers un fichier personnalise ;
- renseigner `ServerAdmin`, `ServerName`, `DocumentRoot`, `SSLCertificateFile` et `SSLCertificateKeyFile` ;
- activer le site avec `a2ensite` ;
- recharger Apache.

Sur le fond, cette partie montre qu'Apache se configure de facon modulaire. Le service HTTPS n'est pas "magique" : il repose sur un module, un hote virtuel, un certificat et un repertoire de contenu.

### 6.6 Test dans le navigateur

Le test final consiste a ouvrir `https://NOM_PRENOM.org`. On doit normalement obtenir :

- un avertissement de securite du navigateur ;
- la possibilite d'inspecter le certificat ;
- puis, si on accepte l'exception, l'affichage de la page HTML personnalisee.

Ici encore, l'avertissement du navigateur n'est pas anormal. Il signifie surtout que le certificat n'est pas signe par une autorite reconnue publiquement. En revanche, si le navigateur affiche bien les informations attendues et que la page se charge ensuite en HTTPS, cela montre que la configuration technique est correcte.

Le sujet demande aussi de verifier que `http://localhost` continue a renvoyer la page par defaut d'Apache. C'est une bonne verification, car elle montre que l'ajout du site HTTPS personnalise n'a pas casse le fonctionnement HTTP existant.

### 6.7 Ce que cette partie montre

Cette partie montre concretement la difference entre :

- un service HTTP en clair ;
- un service HTTPS protege par TLS ;
- un certificat techniquement valide mais non reconnu par une autorite de certification publique.

Elle montre aussi que la securite depend autant de la configuration systeme que des outils cryptographiques eux-memes.

---

## 7. Analyse securite globale du TP

Ce TP permet de mettre en evidence plusieurs idees importantes.

### 7.1 Ce qui est reellement securise

Une fois les manipulations faites correctement :

- les donnees qui circulent entre client et serveur sont chiffrees ;
- le client peut recuperer des informations sur l'identite du serveur via son certificat ;
- un attaquant qui observerait simplement le trafic ne lirait pas directement le contenu des transferts.

### 7.2 Ce qui reste limite

Il faut cependant rester lucide sur les limites de la configuration obtenue :

- les certificats sont auto-signes ;
- il n'y a pas de chaine de confiance publique ;
- l'utilisateur doit verifier lui-meme les informations du certificat ;
- le contexte reste celui d'une machine de TP locale, pas d'un deploiement reel sur Internet ;
- la securite du systeme depend aussi des droits Unix et de la protection des fichiers sensibles.

Autrement dit, le TP valide bien le fonctionnement du chiffrement et la logique des certificats, mais il ne remplace pas toute l'infrastructure de confiance d'un vrai service en production.

### 7.3 Apport de Wireshark

La partie optionnelle avec Wireshark est tres interessante car elle permet de relier la theorie du cours a l'observation reelle du trafic. En principe, on doit pouvoir reperer :

- les premiers echanges FTP ou HTTP en TCP ;
- l'activation de TLS ;
- le demarrage de la negociation avec des messages du type `Client Hello` et les reponses du serveur ;
- puis des donnees chiffrees devenues non lisibles directement.

Cette observation est tres utile pedagogiquement, car elle permet de voir que le chiffrement n'est pas une abstraction : il modifie vraiment la nature des paquets visibles sur le reseau.

---

## 8. Lien avec les supports du depot

Le depot est coherent avec le TP, car les documents fournis couvrent exactement les briques utiles :

- les cours reseau donnent les bases sur IP, TCP, les ports et le fonctionnement client/serveur ;
- les cours de cryptographie expliquent le role du chiffrement symetrique, asymetrique et des certificats ;
- le support sur les communications securisees explique le role d'IPsec et surtout de SSL/TLS ;
- les notices VirtualBox donnent le cadre technique pour lancer l'environnement de travail ;
- le sujet du TP transforme tout cela en manipulations concretes.

On voit donc bien que le depot n'est pas un simple stockage de fichiers heterogenes. C'est un ensemble pedagogique relativement coherent, oriente vers la mise en pratique de la securisation des echanges reseau.

---

## 9. Conclusion

Pour conclure, ce TP est interessant parce qu'il fait le lien entre l'administration systeme, les reseaux et la cryptographie. Il montre qu'un service reseau peut etre fonctionnel sans etre securise, et que l'ajout de TLS change concretement la nature de la communication.

La partie FTPS insiste beaucoup sur la securisation d'un service anciennement peu sur, ainsi que sur les droits d'acces locaux. La partie HTTPS est plus proche de situations qu'on rencontre partout aujourd'hui sur le web, mais elle rappelle qu'un certificat n'est pas automatiquement "de confiance" juste parce qu'il existe.

Au final, le TP permet de mieux comprendre le role des certificats X.509, l'utilite de TLS, la gestion des noms de machines, et l'importance d'une configuration rigoureuse. C'est aussi un bon exemple du fait que la securite n'est jamais reduite a une seule commande : elle repose sur un ensemble coherent de choix techniques.

---

## 10. Personnalisations conseillees avant rendu

Avant de deposer la version finale, il est conseille de :

- remplacer les noms generiques par les noms reels du binome ;
- ajouter 2 a 4 captures d'ecran utiles, sans surcharger ;
- indiquer le nom de domaine choisi dans `/etc/hosts` ;
- preciser les noms reels des certificats generes ;
- mentionner, si vous l'avez fait, l'analyse Wireshark ;
- exporter le document final en PDF conformement au sujet.

---

## 11. Reponses courtes a reutiliser si besoin

### Pourquoi le navigateur affiche-t-il un avertissement en HTTPS ?

Le navigateur affiche un avertissement parce que le certificat est auto-signe. Cela veut dire qu'il n'est pas rattache a une autorite de certification reconnue par defaut. La connexion peut etre chiffree correctement, mais la confiance dans l'identite du serveur n'est pas etablie automatiquement.

### Pourquoi l'avertissement FileZilla n'est-il pas forcement un probleme ?

Dans le cadre du TP, cet avertissement est attendu. Il prouve meme plutot que le serveur presente bien un certificat. Il faut simplement verifier que les informations du certificat correspondent bien a celles qui ont ete saisies lors de sa creation.

### Pourquoi proteger la cle privee est-il indispensable ?

Si la cle privee est lisible par d'autres utilisateurs, toute la securite du service peut etre compromise. Un attaquant local pourrait se faire passer pour le serveur ou recuperer des informations sensibles sur la configuration chiffree.
