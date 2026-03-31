# Projet-P05-FinAcces-Scoring-Credit
API Scoring Credit Micro-Finance - AWS Cloud Foundations ISI 2025-2026


## Auteurs
- **YOUME LAM**
- **AHMADY TOURE**

##  Description
API REST de scoring crédit intelligente déployée sur AWS, capable d'évaluer le risque de défaut d'un emprunteur en quelques millisecondes. Le modèle ML est entraîné sur le dataset German Credit (UCI ML Repository) et produit un score entre 0 et 1000.

## Services AWS utilisés
| Service | Rôle |
|---------|------|
| Amazon EC2 | Serveur d'application Flask |
| Amazon Aurora MySQL | Base de données (sous-réseau privé) |
| Amazon S3 | Stockage des modèles ML (.pkl) |
| VPC + Security Groups | Réseau isolé et sécurisé |
| IAM Role | Accès S3 sans credentials hardcodés |

## Endpoints de l'API
| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | /health | Health check de l'API |
| POST | /score | Scoring d'un client (score 0-1000) |
| GET | /historique/<id> | Historique des demandes client |
| GET | /stats | Statistiques globales par pays |

## Logique de Scoring
| Score | Catégorie | Décision |
|-------|-----------|----------|
| 700 - 1000 | FAIBLE RISQUE | Crédit approuvé |
| 500 - 699 | RISQUE MOYEN | Approuvé avec garanties |
| 0 - 499 | RISQUE ÉLEVÉ |  Crédit refusé |

## Structure du projet
```
├── app.py                 # API Flask principale
├── database.sql           # Script création BDD Aurora
├── scoring_model.pkl      # Modèle ML entraîné
├── scaler.pkl             # Normaliseur StandardScaler
├── scoring_credit.ipynb   # Notebook ML
├── german.data.txt        # Dataset German Credit
└── Rapport_P05.docx       # Rapport technique
```

## Responsable pédagogique
M. LAM Sabarane — ISI Dakar
