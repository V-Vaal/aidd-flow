> 🇫🇷 Français | 🇬🇧 [Version anglaise](README.md)

# aidd-flow

Une implémentation structurée et agnostique aux IDE d'un workflow AI-Driven Development (AIDD), axée sur l'orchestration, les points de contrôle et l'auditabilité. Compatible avec OpenCode, Claude Code, Cursor, GitHub Copilot, ou tout agent LLM.

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

Cela installe le moteur du workflow dans `/.aidd-flow/`, crée un `AGENTS.md` à la racine du projet cible (depuis template), et écrit `.aidd-flow/aidd/aidd.lock` pour le suivi de version.

Après l'export, authentifiez GitHub CLI (`gh auth login`) et consultez `docs/design/architecture.md`.

---

## Démarrage rapide

`AGENTS.md` est le point d'entrée universel. Il est chargé automatiquement par OpenCode et Claude Code. Le dossier `prompts/commands/cursor/` est une archive de référence — non plug-and-play, à utiliser comme inspiration pour recréer des commandes slash Cursor.

### Prérequis

- N'importe quel agent IA (OpenCode, Claude Code, Cursor mode agent, GitHub Copilot Chat, ...)
- Dépôt Git avec le workflow installé (voir [Installation](#installation))
- GitHub CLI authentifié (`gh auth login`) pour le mode ciblé
- `curl` disponible pour Context7 (`scripts/c7-docs.sh`)
- Optionnel : définir `CONTEXT_BUDGET=low|medium|high` dans `.env` pour contrôler la taille du contexte (défaut : `low`)

### Le workflow en trois phases

**Phase 1 — Architecte** (planifier avant de construire)

1. Lire `aidd/memory/activeContext.md` et `aidd/memory/projectbrief.md`
2. Charger `prompts/intake.md` → produit `aidd/work/INTAKE.md`
3. Charger `prompts/plan.md` → produit `aidd/work/PLAN.md`
4. Lancer la gate : `bash scripts/validate-plan.sh` — ne pas continuer si elle échoue

**Phase 2 — Éditeur** (construire sous contraintes)

5. Lancer `bash scripts/aidd-rules-jit.sh` → produit `aidd/work/RULES_JIT.md` avec les règles minimales pertinentes
6. Implémenter en suivant `aidd/work/PLAN.md` exactement — pas de scope creep
7. Lancer : `bash scripts/aidd-check.sh`

**Phase 3 — Reviewer** (audit humain obligatoire)

8. Charger `prompts/review.md` → produit `aidd/work/REVIEW.md`
9. Lancer la gate : `bash scripts/review-check.sh` — tâche non terminée tant que le Verdict n'est pas `APPROVE`
10. Clôture optionnelle : `bash scripts/aidd-finish.sh` (commit/push/PR guidé + nettoyage + handoff)

### Points d'entrée par IDE

| Agent | Point d'entrée |
|-------|----------------|
| OpenCode / Claude Code | `AGENTS.md` chargé automatiquement au démarrage de session |
| Cursor | Archive de référence dans `prompts/commands/cursor/` — non plug-and-play, à adapter en commandes slash |
| Autres agents | Copier le contenu du `prompts/*.md` pertinent dans votre contexte de chat |

**Note Claude Code :** `AGENTS.md` est le point d'entrée de portée projet. Claude Code maintient également sa propre mémoire inter-projets dans `~/.claude/` — les deux couches sont complémentaires : `aidd/memory/` porte le contexte projet, `~/.claude/` les préférences et patterns de l'agent. Utilisez `prompts/compact-response.md` comme gabarit de référence pour les sorties économes en tokens.

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
├── .env.example               # Variables d'environnement optionnelles
│
├── aidd/
│   ├── memory/                # Contexte persistant — remplir une fois par projet
│   ├── work/                  # Artefacts runtime — gitignorés (AUDIT, INTAKE, PLAN, REVIEW, SUMMARY, HANDOFF)
│   └── review/                # Listes de contrôle de revue par domaine (web3, ml, general)
│
├── rules/                     # 30+ règles Markdown
│   └── INDEX.md               # Catalogue des règles (always-apply, par stack, deprecated)
│
├── prompts/                   # Prompts du workflow (start, intake, plan, audit, review, ...)
│   ├── compact-response.md    # Gabarit de sortie économe en tokens
│   └── commands/cursor/       # Commandes slash Cursor (référence archivée)
│
├── scripts/                   # Scripts de portes de validation
│   ├── validate-plan.sh       # Porte : bloque l'implémentation si PLAN.md est invalide
│   ├── review-check.sh        # Porte : bloque la complétion si REVIEW.md n'est pas APPROVE
│   ├── aidd-check.sh          # Vérifications post-implémentation
│   ├── aidd-finish.sh         # Commit/push/PR guidé + nettoyage + handoff
│   ├── aidd-export.sh         # Exporte le framework vers un projet cible
│   ├── gh-context.sh          # Signaux GitHub factuels via gh CLI
│   ├── c7-docs.sh             # Documentation Context7 via curl (preuve obligatoire)
│   ├── aidd-rules-jit.sh      # Sélection des règles juste-à-temps
│   ├── aidd-diff-digest.sh    # Digest compact des diffs pour review
│   ├── aidd-verify-ui.sh      # Vérification des changements UI
│   └── aidd-cleanup.sh        # Archive les artefacts aidd/work/ de plus de 30 jours
│
└── docs/
    ├── workflow/              # Référence complète du workflow (overview, gates, gouvernance, debug, ...)
    ├── design/architecture.md  # Modèle d'export et décisions d'architecture
    ├── templates/AGENTS.root.md  # Template AGENTS racine utilisé par l'export
    └── quality/               # Spécifications des artefacts (intake, technical-plan)
```

---

## Documentation

- [Guide du workflow](docs/workflow/README.md) : Méthode complète du workflow avec gates, gouvernance et dépannage
- [Guide d'architecture](docs/design/architecture.md) : Modèle d'export, décisions de conception
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

Ré-exécutez `aidd-export.sh` depuis le dépôt source pour mettre à jour. Utilisez `--backup` pour préserver le répertoire `.aidd-flow/` existant.

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
