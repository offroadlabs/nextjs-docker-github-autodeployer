# Configuration Docker Compose pour une application Next.js

Ce dépôt fournit une solution complète pour le déploiement d’applications Next.js en utilisant Docker Compose et Traefik. Conçu pour être flexible et hautement paramétrable, ce setup inclut la gestion automatique des mises à jour via les webhooks GitHub, facilitant l’intégration continue (CI/CD). Il offre également un support HTTPS sécurisé avec Let’s Encrypt, assurant le renouvellement automatique des certificats SSL pour une sécurité accrue. Idéal pour le déploiement en production, cette configuration permet une mise en place rapide et fiable d’applications modernes, tout en réduisant la charge de maintenance grâce à l’automatisation.

[🇬🇧 English version available here](readme.md)

## Prérequis

- Docker
- Docker Compose

## Structure des services

### Traefik

Traefik est utilisé comme reverse proxy et gestionnaire de certificats SSL via Let's Encrypt.

### App

L'application Next.js est déployée via un service Docker qui se connecte à Traefik pour la gestion des routes et des certificats. Les commandes pour gérer l'application Next.js utilisent `pnpm` comme gestionnaire de paquets.

## Variables d'environnement

Les variables d'environnement suivantes peuvent être définies pour configurer le comportement de Traefik et de l'application.

### `ACME_EMAIL`

- **Description** : Email utilisé par Traefik pour la gestion des certificats Let's Encrypt. Cet email est utilisé pour recevoir des notifications de Let's Encrypt concernant l'état des certificats SSL.
- **Exemple** : `example@example.com`
- **Remarque** : Il est important d'utiliser un email valide pour recevoir des notifications en cas de problème avec les certificats.

### `TRUSTED_IPS`

- **Description** : Liste des adresses IP de confiance pour les en-têtes de forwarding (`X-Forwarded-For`, etc.). Cela permet de sécuriser les connexions en s'assurant que seules les requêtes provenant de ces IPs sont considérées comme fiables.
- **Exemple** : `127.0.0.1/32,192.168.1.1`
- **Remarque** : Assurez-vous que cette liste est correctement configurée pour inclure uniquement les adresses IP de confiance.

### `APP_DOMAIN`

- **Description** : Nom de domaine principal utilisé pour accéder à l'application. Traefik utilise cette variable pour router le trafic HTTP/HTTPS vers le bon service.
- **Exemple** : `example.com`
- **Remarque** : Ce domaine doit pointer vers l'adresse IP de votre serveur où cette configuration Docker Compose est déployée.

### `WEBHOOK_PATH`

- **Description** : Chemin de l'URL utilisé pour les webhooks GitHub. Ce chemin est utilisé pour configurer une route spécifique pour les requêtes webhook.
- **Exemple** : `/webhook`
- **Remarque** : Le chemin doit correspondre à celui configuré dans les paramètres de votre dépôt GitHub pour les webhooks.

### `GITHUB_SECRET`

- **Description** : Clé secrète utilisée pour sécuriser les webhooks GitHub. Cette clé est utilisée pour vérifier que les requêtes webhook proviennent bien de GitHub

### `REPO_URL`

- **Description** : URL du dépôt GitHub contenant le code de l'application Next.js. Ce paramètre est utilisé pour cloner ou mettre à jour le code de l'application à partir de GitHub.
- **Exemple** : `https://github.com/votre-utilisateur/votre-repo.git`

### `BRANCH`

- **Description** : Branche du dépôt GitHub à déployer. Par défaut, la branche `main` est utilisée.
- **Exemple** : `main`
- **Remarque** : Vous pouvez spécifier une autre branche pour tester des fonctionnalités ou déployer des versions spécifiques de votre application.

### `POST_BUILD_COMMANDS`

- **Description** : Commandes supplémentaires à exécuter après le build de l'application. Cela peut inclure des migrations de base de données, des commandes de nettoyage, etc.
- **Exemple** : `pnpm run migrate && pnpm run build`
- **Remarque** : `pnpm` est utilisé pour gérer les commandes et les paquets de l'application Next.js.

### `DATABASE_URL`

- **Description** : URL de connexion à la base de données utilisée par l'application. Ce paramètre est essentiel pour que l'application puisse se connecter à la base de données.
- **Exemple** : `postgresql://user:password@localhost:5432/database`

## Configuration du Webhook GitHub

Pour que votre application Next.js se mette automatiquement à jour lorsque vous poussez des changements dans votre dépôt GitHub, un webhook doit être configuré.

### Étapes pour configurer le Webhook GitHub

1. **Accédez aux paramètres de votre dépôt GitHub** :

   - Allez sur la page principale de votre dépôt sur GitHub.
   - Cliquez sur l'onglet **Settings** (Paramètres).

2. **Accédez à la section Webhooks** :

   - Dans le menu latéral gauche, cliquez sur **Webhooks**.
   - Cliquez ensuite sur le bouton **Add webhook** (Ajouter un webhook).

3. **Configurez l'URL du Webhook** :

   - Dans le champ **Payload URL**, entrez l'URL de votre serveur suivie du chemin du webhook. Par exemple :
     ```
     https://example.com/webhook/
     ```
   - Cette URL correspond au domaine défini dans la variable `APP_DOMAIN` suivi du chemin défini dans `WEBHOOK_PATH`.

4. **Choisissez le type de contenu** :

   - Dans le champ **Content type**, sélectionnez `application/json`.

5. **Sélectionnez les événements à déclencher** :

   - Sous **Which events would you like to trigger this webhook?** (Quels événements souhaitez-vous utiliser pour déclencher ce webhook ?), sélectionnez l'option **Just the push event.** (Seulement l'événement push).
   - Cela signifie que le webhook ne se déclenchera que lorsque vous poussez de nouveaux commits dans votre dépôt.

6. **Configurez un secret** :

   - Vous devez définir un secret dans le champ **Secret** pour sécuriser les requêtes du webhook.
   - Vous devez utiliser le même que dans la variable d'env `GITHUB_SECRET`

7. **Enregistrez le Webhook** :

   - Cliquez sur **Add webhook** (Ajouter un webhook) pour enregistrer les paramètres.

## Variables d'environnement pour l'application Next.js

Toutes les variables d'environnement nécessaires pour l'application Next.js peuvent être définies dans un fichier `.env.app`. Ce fichier est chargé automatiquement par le service Docker et peut contenir des variables comme celles pour la configuration de la base de données, des API externes, ou tout autre paramètre spécifique à l'application.

### Exemple de fichier `.env.app` :

```env
# Exemple de configuration pour l'application Next.js

DATABASE_URL=postgresql://user:password@localhost:5432/database
NEXT_PUBLIC_API_URL=https://api.example.com
```

Ce fichier .env.app doit être placé à la racine de votre projet. Il est automatiquement pris en compte lors du déploiement de votre application via Docker Compose.

## Comment utiliser cette configuration

1. Clonez ce dépôt.
2. Créez un fichier `.env` à la racine du projet avec les variables d'environnement définies pour Traefik.
3. Créez un fichier `.env.app` à la racine du projet avec les variables d'environnement nécessaires pour votre application Next.js.
4. Lancez Docker Compose :
   ```bash
   docker-compose up -d
   ```
5.	Traefik et l’application seront lancés automatiquement avec les configurations spécifiées.

### Exemple de fichier .env

Voici un exemple de fichier .env que vous pouvez utiliser pour configurer Traefik :

```.env
# url du dépot github à cloner
REPO_URL=git@github.com:exemple/exemple.git

# Branch à cloner
BRANCH=main

# Clé ssh pour pourvoir clone le projet depuis github
SSH_PRIVATE_KEY="-----BEGIN OPENSSH PRIVATE KEY-----
.....
.....
.....
.....
.....
.....
-----END OPENSSH PRIVATE KEY-----"

# Secret utilisé dans le webhook de github
GITHUB_SECRET="mon github secret"

# Chemin pour le webhook GitHub
WEBHOOK_PATH=/webhook

# Commande à passer après le build des sources
POST_BUILD_COMMANDS=pnpm prisma migrate deploy

# Configuration de l'email pour Let's Encrypt
ACME_EMAIL=example@example.com

# Adresses IP de confiance pour les en-têtes de forwarding
TRUSTED_IPS=127.0.0.1/32,192.168.1.1

# Domaine de l'application
APP_DOMAIN=example.com
```

### Exemple de fichier .env.app

Voici un exemple de fichier .env.app pour votre application Next.js :

```.env
DATABASE_URL=postgresql://user:password@localhost:5432/database
NEXT_PUBLIC_API_URL=https://api.example.com
```


## Support et Contact

**Offroadlabs** est un studio de développement spécialisé dans les technologies React, TypeScript, Next.js, Symfony, Docker, et bien d'autres. Si vous avez besoin de services de développement ou de support pour vos projets, n'hésitez pas à nous contacter à l'adresse suivante : **`sebastien[at]offroadlabs.com`**.