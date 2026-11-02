# 💰 Dépensia

**Dépensia** (anciennement Geldverwalten) est une application mobile Flutter moderne de gestion financière personnelle (*"Gérez • Analysez • Atteignez vos objectifs"*).

L'application permet de suivre ses dépenses au quotidien, d'analyser ses habitudes de consommation par catégorie et de planifier ses projets d'épargne. Elle est conçue sur les principes de la **Clean Architecture** et adopte une approche **Offline-First**.

---

## ✨ Fonctionnalités Principales

- 📱 **Mode Hors-ligne (Offline-First)** : L'application est immédiatement fonctionnelle sans obligation d'ouvrir un compte. Les données sont sauvegardées localement via `SharedPreferences`.
- 🔐 **Authentification & Synchronisation** : Création de compte et connexion sécurisées avec gestion de jeton JWT pour la synchronisation des données en ligne.
- 📊 **Tableau de bord interactif (Accueil)** :
  - Aperçu rapide des dépenses du mois (ex: `215 500 FCFA`).
  - Filtrage par période (*Jour, Semaine, Mois, Événement*).
  - Graphique d'évolution et répartition visuelle par catégorie (*Alimentation, Transport, Loisirs, Santé, Maison, Autre*).
- 💸 **Ajout Rapide de Dépense** :
  - Sélection visuelle par catégorie avec icônes dédiées.
  - Saisie du montant en **FCFA**, sélecteur de date et commentaires optionnels.
- 📈 **Analyse & Rapports** :
  - Comparatif Dépenses / Revenus.
  - Filtre mensuel et histogramme d'analyse par semaine.
- 🎯 **Objectifs & Projets d'Épargne** :
  - Indicateur circulaire de progression global.
  - Suivi des objectifs individuels avec barre d'avancement.
- ⚙️ **Paramètres & Profil** :
  - Gestion du profil, statut de synchronisation, thème, export de données et options.

---

## 🏛️ Architecture du Projet : Clean Architecture (Offline-First)

```
lib/
├── core/                                    # Utilitaires globaux & Infrastructure
│   ├── constants/                           # API Endpoints
│   ├── di/                                  # Service Locator (Dependency Injection)
│   ├── errors/                              # Failures & Exceptions
│   ├── presentation/widgets/                # Custom Logo & Widgets réutilisables
│   └── theme/                               # Palette de couleurs Dépensia & ThemeData
│
├── features/                                # Fonctionnalités Métier
│   ├── auth/                                # Authentification & Gestion de compte / Invité
│   │   ├── data/ (datasources, models, repos)
│   │   ├── domain/ (entities, repos, usecases)
│   │   └── presentation/ (Onboarding, Login, Register)
│   │
│   ├── balance/                             # Suivi du Solde & Accueil
│   │   ├── data/ (solde_local_datasource, etc.)
│   │   ├── domain/
│   │   └── presentation/ (AccueilTab)
│   │
│   ├── entree/                              # Revenus / Entrées d'argent
│   ├── projet/                              # Objectifs d'Épargne & Projets
│   ├── sortie/                              # Dépenses, Catégories & Rapports
│   ├── profile/                             # Paramètres & Configuration
│   └── shell/                               # Barre de Navigation Principale
│
└── main.dart                                # Point d'entrée de l'application
```

---

## 🎨 Palette de Couleurs (Dépensia)

- 🟢 **Vert Confiance & Stabilité** : `#006837`
- 🔴 **Rouge Passion & Dynamisme** : `#CE1126`
- 🟡 **Jaune Optimisme & Énergie** : `#FCD116`
- 🔵 **Bleu Sérénité & Fiabilité** : `#0A2540`
- ⚪ **Fond & Cartes** : `#F4F6F8` / `#FFFFFF`

---

## 🧪 Tests

Les tests unitaires et d'intégration de widgets couvrent les cas d'utilisation (Clean Architecture) ainsi que le rendu de l'interface d'accueil.

Pour exécuter l'ensemble des tests :

```bash
flutter test
```

---

## 🚀 Installation & Lancement

```bash
flutter pub get
flutter run
```
