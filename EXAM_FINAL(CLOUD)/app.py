from flask import Flask, request, jsonify
import joblib
import numpy as np
import boto3
import os
import io
from datetime import datetime
import pymysql
import logging

# ============================================================
# CONFIGURATION LOGGING
# ============================================================
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# ============================================================
# CHARGEMENT DU MODÈLE DEPUIS S3 (via IAM Role EC2)
# Aucune clé AWS hardcodée — boto3 utilise automatiquement
# les credentials du IAM Role attaché à l'instance EC2
# ============================================================
S3_BUCKET = os.environ.get('S3_BUCKET', 'finacces-sahel-models')
MODEL_KEY  = os.environ.get('MODEL_KEY',  'models/scoring_model.pkl')
SCALER_KEY = os.environ.get('SCALER_KEY', 'models/scaler.pkl')

def load_model_from_s3():
    """
    Télécharge les fichiers .pkl depuis S3 et les charge en mémoire.
    boto3 récupère automatiquement les credentials du IAM Role EC2
    (via l'instance metadata — aucune clé AWS dans le code).
    """
    logger.info(f"Chargement du modèle depuis s3://{S3_BUCKET}/{MODEL_KEY}")
    s3 = boto3.client('s3')  # credentials via IAM Role EC2 automatiquement

    # Charger le modèle
    model_buffer = io.BytesIO()
    s3.download_fileobj(S3_BUCKET, MODEL_KEY, model_buffer)
    model_buffer.seek(0)
    model = joblib.load(model_buffer)

    # Charger le scaler
    scaler_buffer = io.BytesIO()
    s3.download_fileobj(S3_BUCKET, SCALER_KEY, scaler_buffer)
    scaler_buffer.seek(0)
    scaler = joblib.load(scaler_buffer)

    logger.info("Modèle et scaler chargés depuis S3 avec succès")
    return model, scaler

# Chargement au démarrage de l'application
try:
    model, scaler = load_model_from_s3()
except Exception as e:
    logger.error(f" Erreur chargement S3 : {e}")
    logger.warning(" Fallback : chargement local (dev uniquement)")
    model  = joblib.load('scoring_model.pkl')
    scaler = joblib.load('scaler.pkl')

# ============================================================
# CONNEXION BASE DE DONNÉES AURORA
# Les paramètres sont injectés via variables d'environnement
# sur l'instance EC2 — jamais hardcodés dans le code
# ============================================================
def get_db_connection():
    return pymysql.connect(
        host=os.environ.get('DB_HOST', 'localhost'),
        user=os.environ.get('DB_USER', 'admin'),
        password=os.environ.get('DB_PASSWORD', ''),
        database=os.environ.get('DB_NAME', 'finacces_db'),
        cursorclass=pymysql.cursors.DictCursor,
        connect_timeout=5
    )

# ============================================================
# ENDPOINT 1 : Health Check
# Utilisé par l'ALB pour vérifier que l'instance est saine
# ============================================================
@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        "status": "healthy",
        "message": "FinAccès Sahel API opérationnelle",
        "model_source": "S3",
        "bucket": S3_BUCKET,
        "timestamp": datetime.now().isoformat()
    }), 200

# ============================================================
# ENDPOINT 2 : POST /score — Scoring d'un client
# Reçoit le profil client en JSON, retourne score 0-1000
# + catégorie de risque + recommandation
# ============================================================
@app.route('/score', methods=['POST'])
def score():
    try:
        data = request.get_json()

        # Validation des champs obligatoires
        required_fields = [
            'statut_compte', 'duree_mois', 'historique_credit', 'objet_credit',
            'montant_credit', 'epargne', 'emploi_depuis', 'taux_remboursement',
            'statut_personnel', 'autres_debiteurs', 'residence_depuis', 'propriete',
            'age', 'autres_credits', 'logement', 'credits_existants', 'emploi',
            'personnes_charge', 'telephone', 'travailleur_etranger'
        ]
        missing = [f for f in required_fields if f not in data]
        if missing:
            return jsonify({"error": f"Champs manquants : {missing}"}), 400

        # Construction du vecteur de features dans le bon ordre
        features = [
            data['statut_compte'],
            data['duree_mois'],
            data['historique_credit'],
            data['objet_credit'],
            data['montant_credit'],
            data['epargne'],
            data['emploi_depuis'],
            data['taux_remboursement'],
            data['statut_personnel'],
            data['autres_debiteurs'],
            data['residence_depuis'],
            data['propriete'],
            data['age'],
            data['autres_credits'],
            data['logement'],
            data['credits_existants'],
            data['emploi'],
            data['personnes_charge'],
            data['telephone'],
            data['travailleur_etranger']
        ]

        # Normalisation et prédiction
        features_scaled = scaler.transform([features])
        proba = model.predict_proba(features_scaled)[0][1]
        score_value = int((1 - proba) * 1000)  # Score 0-1000 (1000 = risque minimal)

        # Catégorie de risque et recommandation
        if score_value >= 700:
            categorie      = "FAIBLE RISQUE"
            recommandation = "Crédit approuvé"
        elif score_value >= 500:
            categorie      = "RISQUE MOYEN"
            recommandation = "Crédit approuvé avec garanties"
        else:
            categorie      = "RISQUE ÉLEVÉ"
            recommandation = "Crédit refusé"

        # Persistance en base Aurora
        try:
            conn = get_db_connection()
            with conn.cursor() as cursor:
                cursor.execute("""
                    INSERT INTO demandes
                    (client_id, montant_demande, score, decision, timestamp)
                    VALUES (%s, %s, %s, %s, %s)
                """, (
                    data.get('client_id', 0),
                    data.get('montant_credit', 0),
                    score_value,
                    recommandation,
                    datetime.now()
                ))
            conn.commit()
            conn.close()
            logger.info(f"Demande client {data.get('client_id')} enregistrée — score {score_value}")
        except Exception as db_error:
            logger.warning(f"DB non disponible : {db_error}")

        return jsonify({
            "score": score_value,
            "probabilite_defaut": round(proba * 100, 2),
            "categorie_risque": categorie,
            "recommandation": recommandation,
            "timestamp": datetime.now().isoformat()
        }), 200

    except Exception as e:
        logger.error(f"Erreur /score : {e}")
        return jsonify({"error": str(e)}), 400

# ============================================================
# ENDPOINT 3 : GET /historique/<client_id>
# Retourne les 10 dernières demandes d'un client
# ============================================================
@app.route('/historique/<int:client_id>', methods=['GET'])
def historique(client_id):
    try:
        conn = get_db_connection()
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT id, montant_demande, score, decision, timestamp
                FROM demandes
                WHERE client_id = %s
                ORDER BY timestamp DESC
                LIMIT 10
            """, (client_id,))
            resultats = cursor.fetchall()
        conn.close()
        # Conversion des datetime en string pour la sérialisation JSON
        for r in resultats:
            if isinstance(r.get('timestamp'), datetime):
                r['timestamp'] = r['timestamp'].isoformat()
        return jsonify({"client_id": client_id, "historique": resultats}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# ============================================================
# ENDPOINT 4 : GET /stats — Statistiques globales par pays
# ============================================================
@app.route('/stats', methods=['GET'])
def stats():
    try:
        conn = get_db_connection()
        with conn.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) as total FROM demandes")
            total = cursor.fetchone()

            cursor.execute("""
                SELECT c.pays,
                       COUNT(d.id)      AS nb_demandes,
                       ROUND(AVG(d.score), 0) AS score_moyen,
                       ROUND(SUM(CASE WHEN d.score >= 700 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS taux_approbation
                FROM clients c
                JOIN demandes d ON c.id = d.client_id
                GROUP BY c.pays
                ORDER BY nb_demandes DESC
            """)
            par_pays = cursor.fetchall()
        conn.close()
        return jsonify({
            "total_demandes": total['total'],
            "stats_par_pays": par_pays
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# ============================================================
# LANCEMENT
# ============================================================
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
