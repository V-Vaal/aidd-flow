> 🇫🇷 Français | 🇬🇧 [Version anglaise](README.md)

# aidd-flow

Implémentation d'un workflow AI-Driven Development (AIDD) optimisée pour Cursor et axée sur l'orchestration, les points de contrôle et l'auditabilité.

---

## Qu'est-ce que l'AI-Driven Development (AIDD) ?

L'AI-Driven Development est un workflow de développement et un processus de prise de décision où l'IA assiste le jugement humain plutôt que d'opérer de manière autonome. Dans l'AIDD :

- **L'IA est un assistant**, pas un agent autonome
- **L'humain prend les décisions** aux points de contrôle critiques
- **L'IA exécute** sous contraintes et règles explicites
- **Le travail est auditable** grâce à des artefacts structurés et des décisions traçables

L'AIDD privilégie la méthode à l'automatisation : règles claires, plans explicites, vérifications automatisées et revue humaine obligatoire avant d'accepter les changements.

---

## Qu'est-ce que aidd-flow ?

`aidd-flow` est une implémentation pratique, optimisée pour Cursor, d'un workflow AIDD. Ce dépôt fournit :

- **Orchestration** : Commandes et prompts structurés qui guident le workflow
- **Points de contrôle** : Portes de validation qui imposent la qualité des plans et les verdicts de revue
- **Auditabilité** : Artefacts persistants (AUDIT, INTAKE, PLAN, REVIEW) qui documentent les décisions et la justification
- **Intégration Cursor** : Commandes et règles optimisées pour le mode agent de Cursor IDE

Ce workflow se concentre sur **comment structurer le travail assisté par IA** plutôt que sur la génération de code seule. Il fournit un processus répétable pour passer des exigences à une implémentation revue, avec une séparation claire entre exploration, planification, exécution et publication.

---

## Portée de ce workflow

### Ce que ce dépôt aide à faire

- **Développement assisté par IA structuré** : De l'issue/PR à l'implémentation revue
- **Traçabilité des décisions** : Artefacts clairs documentant ce qui a été décidé et pourquoi
- **Portes de qualité** : Validation automatisée des plans et revue humaine obligatoire
- **Continuité du projet** : Banque de mémoire et contexte actif pour le travail multi-sessions
- **Workflows optimisés pour Cursor** : Commandes et prompts optimisés pour Cursor IDE

### Ce que ce dépôt ne tente pas de résoudre

- **Méthodologie universelle** : C'est un workflow pratique, pas un cadre théorique
- **Workflows agnostiques aux outils** : Optimisé pour Cursor, pas conçu pour d'autres IDE dans cette version (évolution future possible)
- **Collaboration d'équipe** : Conçu pour un usage individuel ou en petite équipe, pas pour des processus à l'échelle entreprise
- **Certification ou formation** : Pas de programme de certification ou de formation officiel

---

## Installation

### Option 1 : Utiliser ce dépôt directement

Si vous voulez utiliser `aidd-flow` comme template ou référence :

```bash
git clone <url-de-ce-repo>
cd aidd-flow
```

Ensuite, ouvrez le dépôt dans Cursor et utilisez `@aidd.start` directement.

### Option 2 : Exporter le workflow vers un projet existant

Si vous voulez appliquer ce workflow à un projet existant :

```bash
# Cloner ce dépôt
git clone <url-de-ce-repo>
cd aidd-flow

# Exporter le workflow vers votre projet cible
bash scripts/aidd-export.sh /chemin/vers/votre/projet-cible
```

Le script d'export copie tous les fichiers du workflow (commandes, prompts, règles, scripts) dans le répertoire `.cursor/` de votre projet cible. Après l'export, ouvrez votre projet cible dans Cursor et utilisez `@aidd.start`.

**Note** : Le script d'export crée un fichier `.cursor/aidd.lock` pour suivre la version du workflow installée dans votre projet.

---

## Démarrage rapide

Le point d'entrée est la commande `aidd.start` dans Cursor.

### Prérequis

- Cursor IDE avec mode agent
- Dépôt Git (local ou distant) avec le workflow installé (voir [Installation](#installation))
- (Optionnel) GitHub MCP pour le mode ciblé

### Démarrer le workflow

1. **Ouvrez Cursor** dans votre répertoire de projet

2. **Exécutez la commande start** :
   ```
   @aidd.start
   ```

3. **Sélectionnez un mode** :
   - **Ciblé (Issue/PR)** : Récupérer les signaux GitHub pour une issue ou PR spécifique, puis exécuter le workflow complet
   - **Exploratoire (Scan de dépôt)** : Exécuter un audit de dépôt pour produire des résultats

4. **Suivez le flux interactif** : La commande vous guide à travers les étapes spécifiques au mode

5. **Revoyez les artefacts** : Les artefacts générés apparaissent dans `.cursor/work/` :
   - `AUDIT.md` : Analyse du dépôt et résultats
   - `INTAKE.md` : Exigences et contraintes (mode ciblé)
   - `PLAN.md` : Plan d'implémentation technique (mode ciblé)
   - `REVIEW.md` : Verdict de revue et preuves (après implémentation)

### Prochaines étapes après le démarrage

- **Mode ciblé** : Revoyez AUDIT → INTAKE → PLAN, puis procédez à l'implémentation
- **Mode exploratoire** : Revoyez les résultats, sélectionnez un résultat à convertir en exécution ciblée

Pour les étapes détaillées du workflow, voir la [documentation du workflow](docs/workflow.md).

---

## Principes de conception fondamentaux

Si vous voulez un meilleur code, améliorez le système, pas le modèle.

Ce workflow ne cherche pas à "rendre l’IA plus intelligente".
Il améliore les conditions de production du code :
contraintes claires, plans explicites, portes de validation et revue humaine.

### Points de décision humains dans la boucle

Les décisions critiques nécessitent le jugement humain :
- **Validation de l'intake** : L'humain révise et approuve les exigences
- **Approbation du plan** : L'humain valide l'approche technique avant l'implémentation
- **Verdict de revue** : L'humain fournit une approbation formelle (APPROVE | CHANGES_REQUESTED)

### Séparation claire entre exploration, exécution et publication

- **Exploration** : Audit et découverte (mode exploratoire)
- **Planification** : Exigences et conception technique (mode ciblé)
- **Exécution** : Implémentation avec assistance IA
- **Vérification** : Vérifications automatisées et revue humaine
- **Publication** : Changements approuvés uniquement

### Auditabilité et traçabilité

Tout travail assisté par IA produit des artefacts structurés :
- **AUDIT.md** : État du dépôt et résultats
- **INTAKE.md** : Exigences, contraintes, critères d'acceptation
- **PLAN.md** : Étapes techniques, fichiers à modifier, plan de rollback
- **REVIEW.md** : Résumé de revue, preuves de test, verdict formel

Ces artefacts documentent **ce qui a été décidé**, **pourquoi cela a été décidé**, et **quelle preuve soutient la décision**.

### Séparation explicite des rôles

- **Humain comme orchestrateur** : Définit les règles, valide les plans, prend les décisions, fournit les verdicts
- **IA comme exécuteur** : Implémente les plans sous contraintes, suit les règles, génère les artefacts

---

## Inspiration et lignée

Ce workflow est inspiré de l'approche **AI-Driven Development (AIDD)** articulée par Alex Soyes et la communauté `ai-driven-dev`.

**Avertissements importants :**

- Ceci n'est **pas une implémentation officielle** ou littérale de l'AIDD
- C'est une **interprétation personnelle et pratique** optimisée pour Cursor IDE
- Toutes opinions, limitations ou erreurs dans cette implémentation sont celles de l'auteur
- Ce dépôt représente un **instantané stable** extrait d'un sandbox interne

L'approche AIDD originale privilégie le leadership humain, les contraintes explicites et les workflows structurés. Ce dépôt adapte ces principes en un workflow optimisé pour Cursor, piloté par commandes, avec des portes de validation et l'auditabilité.

---

## Non-objectifs

Ce dépôt n'est **pas** :

- **Un cadre AIDD officiel** : C'est une implémentation personnelle, pas un standard officiel
- **Un programme de certification** : Pas de certification, formation ou approbation officielle
- **Une méthodologie universelle** : Conçu pour un usage pratique, pas pour une complétude théorique
- **Une approbation d'outils** : La conception optimisée pour Cursor reflète des choix pratiques, pas une approbation d'outil
- **Un produit marketing** : Documentation factuelle, pas de langage promotionnel
- **Une spécification statique** : Ce workflow évolue en fonction de l'usage réel

---

## Structure du dépôt

```
aidd-flow/
├── .cursor/
│   ├── commands/          # Commandes Cursor (aidd.start, aidd.intake, etc.)
│   ├── prompts/          # Prompts du workflow (start, intake, plan, review)
│   ├── rules/            # Règles Cursor (architecture, conventions, sécurité)
│   ├── memory/            # Fichiers template de la banque de mémoire
│   ├── review/            # Listes de contrôle de revue spécifiques au domaine
│   └── work/              # Artefacts générés (AUDIT, INTAKE, PLAN, REVIEW)
├── scripts/              # Portes de validation et scripts utilitaires
│   └── aidd-export.sh     # Exporter le workflow vers un projet cible (voir Installation)
├── docs/                 # Documentation du workflow
└── README.md
```

---

## Documentation

- [Guide du workflow](docs/workflow.md) : Méthode complète du workflow avec portes, dépannage et vérifications
- [Spécification INTAKE](docs/intake.md) : Structure et exigences de l'artefact INTAKE.md
- [Spécification PLAN](docs/technical-plan.md) : Structure et exigences de l'artefact PLAN.md

---

## Suivi de version du workflow

Lorsque vous exportez ce workflow vers un projet cible en utilisant `scripts/aidd-export.sh`, il crée `.cursor/aidd.lock` dans le projet cible :

```yaml
# AIDD Lock File
timestamp: 2024-01-15T10:30:00Z
source_remote: https://github.com/owner/aidd-flow
source_commit: abc123def456...
template_version: 1.0.0
```

**Objectif :**
- Suit quelle version du workflow est installée dans le projet cible
- Enregistre le dépôt source et le SHA de commit
- Permet les mises à jour conscientes de la version et le dépannage

**Mise à jour du workflow dans le projet cible :**
- Ré-exécutez `aidd-export.sh` depuis le dépôt source
- Le fichier lock est mis à jour avec les nouvelles informations de version
- Utilisez le flag `--backup` pour préserver le répertoire `.cursor/` existant

**Informations de version :**
- `source_commit` : SHA Git quand disponible, ou "uncommitted" si aucun commit valide
- `source_remote` : URL du dépôt si le remote est configuré, sinon omis
- `template_version` : Identifiant de version (si suivi dans le dépôt source)

---

## Licence

Voir le fichier [LICENSE](LICENSE) pour les détails.

---

## Contribution

Ce dépôt représente un instantané stable d'un workflow en évolution. Les contributions qui améliorent la clarté, corrigent les erreurs ou ajoutent des améliorations pratiques sont les bienvenues. Veuillez ouvrir une issue pour discuter des changements significatifs avant de soumettre une pull request.
