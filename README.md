# FinAccès Sahel — API de Scoring de Crédit sur AWS

> Projet P-05 — AWS Cloud Foundations | ISI Dakar | M. LAM Sabarane | 2025-2026

Système automatisé de scoring de crédit déployé sur Amazon Web Services pour **FinAccès Sahel**, institution de micro-finance opérant au Sénégal, Mali et Burkina Faso.

---

## Architecture AWS

```
Internet
    │
    ▼
Internet Gateway
    │
    ▼
Application Load Balancer (finacces-alb)
    │  port 80
    ▼
EC2 t2.micro — Flask API (port 5000)     ──── IAM Role ────▶  S3 (scoring_model.pkl)
    │  port 3306
    ▼
RDS MySQL (finacces-db) — sous-réseau privé
```

### Services AWS utilisés

| Module | Service | Rôle |
|--------|---------|------|
| M5 | VPC 10.0.0.0/16 | Réseau isolé, 2 sous-réseaux |
| M6 | EC2 t2.micro | Serveur API Flask |
| M6 | Application Load Balancer | Équilibrage de charge, health checks |
| M7 | Amazon S3 | Stockage modèle ML (.pkl) |
| M8 | RDS MySQL | Base de données Aurora-compatible |
| M4 | IAM Role | Accès S3 sans credentials hardcodés |
| M10 | CloudWatch | Dashboard + 3 alarmes |

---

##  API REST — Endpoints

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/health` | GET | Health check (utilisé par l'ALB) |
| `/score` | POST | Scoring client → score 0-1000 |
| `/historique/{client_id}` | GET | 10 dernières demandes d'un client |
| `/stats` | GET | Statistiques globales par pays |

### Exemple — POST /score

**Requête :**
```bash
curl -X POST http://<ALB-DNS>/score \
  -H "Content-Type: application/json" \
  -d '{
    "statut_compte": 1,
    "duree_mois": 24,
    "historique_credit": 2,
    "objet_credit": 3,
    "montant_credit": 500000,
    "epargne": 2,
    "emploi_depuis": 3,
    "taux_remboursement": 2,
    "statut_personnel": 2,
    "autres_debiteurs": 1,
    "residence_depuis": 3,
    "propriete": 1,
    "age": 35,
    "autres_credits": 1,
    "logement": 1,
    "credits_existants": 1,
    "emploi": 2,
    "personnes_charge": 1,
    "telephone": 1,
    "travailleur_etranger": 1
  }'
```

**Réponse :**
```json
{
  "score": 641,
  "probabilite_defaut": 35.82,
  "categorie_risque": "RISQUE MOYEN",
  "recommandation": "Credit approuve avec garanties",
  "timestamp": "2026-03-31T19:25:24"
}
```

### Grille de score

| Score | Catégorie | Décision |
|-------|-----------|---------|
| 700 – 1000 |  FAIBLE RISQUE | Crédit approuvé |
| 500 – 699 | RISQUE MOYEN | Approuvé avec garanties |
| 0 – 499 |  RISQUE ÉLEVÉ | Crédit refusé |

---

##  Modèle ML

- **Dataset** : German Credit Dataset (UCI ML Repository) — 1000 clients, 20 features
- **Algorithme** : Random Forest Classifier
- **Accuracy** : 78%
- **ROC-AUC** : 0.81
- **Réduction du taux de défaut** : 30% → 18% (-40%)

---

##  Structure du projet

```
├── app.py                  # API Flask (charge le modèle depuis S3 via IAM Role)
├── database.sql            # Schéma BDD + 50 clients + 200 demandes fictives
├── scoring_model.pkl       # Modèle ML sérialisé
├── scaler.pkl              # StandardScaler sérialisé
├── openapi_finacces.yaml   # Documentation API (Swagger/OpenAPI 3.0)
├── german.data.txt         # Dataset d'entraînement
└── Untitled.ipynb          # Notebook ML (exploration + entraînement)
```

---

##  Déploiement sur EC2

### 1. Cloner le repo sur l'EC2
```bash
git clone https://github.com/<votre-repo>/finacces-sahel.git
cd finacces-sahel
```

### 2. Installer les dépendances
```bash
pip3 install flask joblib numpy boto3 pymysql
```

### 3. Configurer les variables d'environnement
```bash
export S3_BUCKET=finacces-sahel-models
export MODEL_KEY=models/scoring_model.pkl
export SCALER_KEY=models/scaler.pkl
export DB_HOST=<endpoint-rds>
export DB_USER=admin
export DB_PASSWORD=<votre-password>
export DB_NAME=finacces_db
```

### 4. Lancer l'API
```bash
nohup python3 app.py &
```

### 5. Tester
```bash
curl http://localhost:5000/health
```

---

##  Sécurité

- **IAM Role EC2** : `s3:GetObject` uniquement sur le bucket `finacces-sahel-models` — aucune clé AWS dans le code
- **RDS dans sous-réseau privé** : inaccessible depuis Internet
- **RDS-SG** : port 3306 autorisé depuis `EC2-SG` uniquement
- **Chiffrement at rest** : activé sur RDS
- **ALB** : health checks sur `/health` toutes les 30 secondes

---

## Monitoring CloudWatch

| Alarme | Métrique | Seuil |
|--------|---------|-------|
| `finacces-cpu-alarm` | CPUUtilization EC2 | > 80% |
| `finacces-requests-alarm` | RequestCount ALB | > 1000/min |
| `finacces-db-alarm` | DatabaseConnections RDS | > 80 |

---

##  ROI

| Indicateur | Valeur |
|-----------|--------|
| Économie mensuelle | 22 294 500 XOF |
| Réduction des défauts | 30% → 18% |
| Temps de décision | 45 min → < 1 seconde |
| Payback period | 2 mois |
| ROI sur 1 an | +496% |

---

## Auteur

**Ahmady Touré** et **Youme Lam** — Étudiant L3 Data Science & IA  
Institut Supérieur d'Informatique de Dakar (ISI)  
Module AWS Cloud Foundations — M. LAM Sabarane | 2025-2026
