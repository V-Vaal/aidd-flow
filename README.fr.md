> 🇫🇷 Français | 🇬🇧 [Version anglaise](README.md)

# aidd-flow

Une implémentation industrielle et agnostique aux IDE d'un workflow AI-Driven Development (AIDD), axée sur l'orchestration, les points de contrôle et l'auditabilité. Compatible avec OpenCode, Claude Code, Cursor, GitHub Copilot, ou tout agent LLM.

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

`aidd-flow` est une implémentation pratique et agnostique aux IDE d'un workflow AIDD, construite sur un **pattern tripartite de rôles** :

- **Architecte** — réfléchit et planifie avant d'écrire le moindre code
- **Éditeur** — exécute sous les contraintes définies par le plan et les règles
- **Reviewer** — effectue un audit humain obligatoire avant de marquer le travail comme terminé

Ce dépôt fournit :

- **Orchestration** : Un seul point d'entrée `AGENTS.md` chargé automatiquement par n'importe quel agent
- **Points de contrôle** : Scripts de validation imposant la qualité des plans et les verdicts de revue
- **Auditabilité** : Artefacts persistants (AUDIT, INTAKE, PLAN, REVIEW) documentant les décisions
- **Bibliothèque de règles** : 30+ règles Markdown couvrant code propre, sécurité, langages, frameworks, QA
- **Banque de mémoire** : Fichiers de contexte persistants (`projectbrief`, `techContext`, `systemPatterns`, `activeContext`)

---

## Portée

### Ce que ce dépôt aide à faire

- **Développement assisté par IA structuré** : De l'issue/PR à l'implémentation revue
- **Traçabilité des décisions** : Artefacts clairs documentant ce qui a été décidé et pourquoi
- **Portes de qualité** : Validation automatisée des plans et revue humaine obligatoire
- **Continuité du projet** : Banque de mémoire et contexte actif pour le travail multi-sessions
- **Workflows agnostiques aux IDE** : Compatible OpenCode, Claude Code, Cursor, Copilot et autres

### Ce que ce dépôt ne tente pas de résoudre

- **Méthodologie universelle** : C'est un workflow pratique, pas un cadre théorique
- **Collaboration d'équipe** : Conçu pour un usage individuel ou en petite équipe
- **Certification ou formation** : Pas de programme de certification ou de formation officiel

---

## Installation

### Option 1 : Cloner et utiliser directement

```bash
git clone https://github.com/V-Vaal/aidd-flow.git
cd aidd-flow
```

Remplissez les fichiers `aidd/memory/` avec le contexte de votre projet, puis démarrez le workflow via `AGENTS.md`.

### Option 2 : Exporter vers un projet existant

```bash
git clone https://github.com/V-Vaal/aidd-flow.git
cd aidd-flow

bash scripts/aidd-export.sh /chemin/vers/votre/projet-cible
```

Cela exporte le workflow complet dans `/chemin/vers/votre/projet-cible/.aidd-flow/`, crée un `AGENTS.md` à la racine (redirection), et écrit `.aidd-flow/aidd/aidd.lock` pour le suivi de version.

Comportement de sécurité :
- Si `.aidd-flow/` existe et n'est pas vide, le script refuse sauf si vous passez `--force` ou `--backup`.
- Si `AGENTS.md` existe déjà à la racine, le script refuse sauf si vous passez `--force-agents` ou `--backup-agents`.

Après l'export, configurez le serveur MCP GitHub pour votre IDE — voir `mcp.example.json` et `docs/design/architecture.md`.

---

## Démarrage rapide

`AGENTS.md` est le point d'entrée universel. Il est chargé automatiquement par OpenCode et Claude Code. Le dossier `prompts/commands/cursor/` est une archive historique pouvant servir d'inspiration pour recréer des commandes slash Cursor.

### Prérequis

- N'importe quel agent IA (OpenCode, Claude Code, Cursor mode agent, GitHub Copilot Chat, ...)
- Dépôt Git avec le workflow installé (voir [Installation](#installation))
- (Optionnel) Serveur MCP GitHub pour le mode ciblé — voir `mcp.example.json`

### Le workflow en trois phases

**Phase 1 — Architecte** (planifier avant de construire)

1. Lire `aidd/memory/activeContext.md` et `aidd/memory/projectbrief.md`
2. Charger `prompts/intake.md` → produit `aidd/work/INTAKE.md`
3. Charger `prompts/plan.md` → produit `aidd/work/PLAN.md`
4. Lancer la porte : `bash scripts/validate-plan.sh` — ne pas continuer si elle échoue

**Phase 2 — Éditeur** (construire sous contraintes)

5. Charger les règles pertinentes depuis `rules/` (voir `rules/INDEX.md` pour les règles always-apply)
6. Implémenter en suivant `aidd/work/PLAN.md` exactement
7. Lancer : `bash scripts/aidd-check.sh`

**Phase 3 — Reviewer** (audit humain obligatoire)

8. Charger `prompts/review.md` → produit `aidd/work/REVIEW.md`
9. Lancer la porte : `bash scripts/review-check.sh` — tâche non terminée tant que le Verdict n'est pas `APPROVE`

### Points d'entrée par IDE

| Agent | Point d'entrée |
|-------|----------------|
| OpenCode / Claude Code | `AGENTS.md` chargé automatiquement au démarrage de session |
| Cursor | Archive historique dans `prompts/commands/cursor/` (non plug-and-play) |
| Autres agents | Copier le contenu du `prompts/*.md` pertinent dans votre contexte de chat |

---

## Principes de conception fondamentaux

> Si vous voulez un meilleur code, améliorez le système, pas le modèle.

Ce workflow ne cherche pas à "rendre l'IA plus intelligente". Il améliore les conditions dans lesquelles le code est produit : contraintes claires, plans explicites, portes de validation et revue humaine.

### Points de décision humains dans la boucle

Les décisions critiques nécessitent le jugement humain :
- **Validation de l'intake** : L'humain révise et approuve les exigences
- **Approbation du plan** : L'humain valide l'approche technique avant l'implémentation
- **Verdict de revue** : L'humain fournit une approbation formelle (`APPROVE` | `CHANGES_REQUESTED`)

### Séparation claire des rôles

- **Humain comme orchestrateur** : Définit les règles, valide les plans, prend les décisions, fournit les verdicts
- **IA comme exécuteur** : Implémente les plans sous contraintes, suit les règles, génère les artefacts

### Auditabilité et traçabilité

Tout travail assisté par IA produit des artefacts structurés dans `aidd/work/` :
- `AUDIT.md` : État du dépôt et résultats
- `INTAKE.md` : Exigences, contraintes, critères d'acceptation
- `PLAN.md` : Étapes techniques, fichiers à modifier, plan de rollback
- `REVIEW.md` : Résumé de revue, preuves de test, verdict formel

Ces artefacts documentent **ce qui a été décidé**, **pourquoi cela a été décidé**, et **quelle preuve soutient la décision**.

---

## Structure du dépôt

```
aidd-flow/
├── AGENTS.md                  # Point d'entrée universel (3 modes + gates + RTK)
├── mcp.example.json           # Template serveur MCP GitHub
├── .env.example               # Variables d'environnement requises
│
├── aidd/
│   ├── memory/                # Contexte persistant — remplir une fois par projet
│   ├── work/                  # Artefacts runtime — gitignorés (AUDIT, INTAKE, PLAN, REVIEW)
│   └── review/                # Listes de contrôle de revue par domaine (web3, ml)
│
├── rules/                     # 30+ règles Markdown
│   └── INDEX.md               # Catalogue des règles (always-apply, par stack, deprecated)
│
├── prompts/                   # Prompts du workflow (start, intake, plan, audit, review, ...)
│   └── commands/cursor/       # Commandes slash Cursor (référence archivée)
│
├── scripts/                   # Scripts de portes de validation
│   ├── validate-plan.sh       # Porte : bloque l'implémentation si PLAN.md est invalide
│   ├── review-check.sh        # Porte : bloque la complétion si REVIEW.md n'est pas APPROVE
│   ├── aidd-check.sh          # Vérifications post-implémentation
│   ├── aidd-export.sh         # Exporte le framework vers un projet cible
│   └── aidd-cleanup.sh        # Archive les artefacts aidd/work/ de plus de 30 jours
│
└── docs/
    ├── workflow.md             # Référence complète du workflow
    ├── design/architecture.md  # Configuration MCP, guide d'export, ADRs du framework
    └── quality/               # Spécifications des artefacts (intake, technical-plan)
```

---

## Documentation

- [Guide du workflow](docs/workflow/README.md) : Méthode complète du workflow avec gates, gouvernance et dépannage
- [Guide d'architecture](docs/design/architecture.md) : Configuration MCP par IDE, guide d'export, décisions de conception
- [Spécification INTAKE](docs/quality/intake.md) : Structure et exigences de l'artefact INTAKE.md
- [Spécification PLAN](docs/quality/technical-plan.md) : Structure et exigences de l'artefact PLAN.md
- [Index des règles](rules/INDEX.md) : Toutes les règles avec les flags always-apply et deprecated

---

## Suivi de version du workflow

Lorsque vous exportez ce workflow vers un projet cible en utilisant `scripts/aidd-export.sh`, il crée `aidd/aidd.lock` dans le projet cible :

```yaml
# AIDD Lock File
timestamp: 2024-01-15T10:30:00Z
source_remote: https://github.com/owner/aidd-flow
source_commit: abc123def456...
template_version: 1.0.0
```

Ré-exécutez `aidd-export.sh` depuis le dépôt source pour mettre à jour. Utilisez `--backup` pour préserver le répertoire `aidd/` existant.

---

## Inspiration et lignée

Ce workflow est inspiré de l'approche **AI-Driven Development (AIDD)** articulée par Alex Soyes et la communauté `ai-driven-dev` ([github.com/ai-driven-dev](https://github.com/ai-driven-dev)).

**Avertissements importants :**

- Ceci n'est **pas une implémentation officielle** ou littérale de l'AIDD
- C'est une **interprétation personnelle et pratique** adaptée pour un usage agnostique aux IDE
- Toutes opinions, limitations ou erreurs dans cette implémentation sont celles de l'auteur

---

## Non-objectifs

Ce dépôt n'est **pas** :

- **Un cadre AIDD officiel** : Implémentation personnelle, pas un standard officiel
- **Un programme de certification** : Pas de certification, formation ou approbation officielle
- **Une méthodologie universelle** : Conçu pour un usage pratique, pas pour une complétude théorique
- **Une approbation d'outils** : La conception agnostique reflète des choix pratiques, pas une approbation d'outil
- **Une spécification statique** : Ce workflow évolue en fonction de l'usage réel

---

## Licence

Voir le fichier [LICENSE](LICENSE) pour les détails.

---

## Contribution

Ce dépôt représente un instantané stable d'un workflow en évolution. Les contributions qui améliorent la clarté, corrigent les erreurs ou ajoutent des améliorations pratiques sont les bienvenues. Veuillez ouvrir une issue pour discuter des changements significatifs avant de soumettre une pull request.
