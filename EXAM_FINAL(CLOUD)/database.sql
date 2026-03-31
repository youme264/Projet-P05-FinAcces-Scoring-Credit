-- ============================================================
-- CRÉATION DE LA BASE DE DONNÉES
-- ============================================================
CREATE DATABASE IF NOT EXISTS finacces_db;
USE finacces_db;

-- ============================================================
-- TABLE 1 : CLIENTS
-- ============================================================
CREATE TABLE IF NOT EXISTS clients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom_fictif VARCHAR(100) NOT NULL,
    pays VARCHAR(50) NOT NULL,
    segment VARCHAR(50) NOT NULL,
    date_inscription DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE 2 : DEMANDES
-- ============================================================
CREATE TABLE IF NOT EXISTS demandes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    montant_demande DECIMAL(10,2) NOT NULL,
    score INT NOT NULL,
    decision VARCHAR(100) NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(id)
);

-- ============================================================
-- TABLE 3 : PRODUITS CREDIT
-- ============================================================
CREATE TABLE IF NOT EXISTS produits_credit (
    id INT AUTO_INCREMENT PRIMARY KEY,
    taux DECIMAL(5,2) NOT NULL,
    duree_max INT NOT NULL,
    montant_max DECIMAL(10,2) NOT NULL
);

-- ============================================================
-- INSERTION : 50 CLIENTS FICTIFS
-- ============================================================
INSERT INTO clients (nom_fictif, pays, segment) VALUES
('Amadou Diallo', 'Sénégal', 'PME'),
('Fatou Sow', 'Sénégal', 'Particulier'),
('Moussa Traoré', 'Mali', 'PME'),
('Aissatou Bah', 'Sénégal', 'Particulier'),
('Ibrahim Coulibaly', 'Côte d\'Ivoire', 'PME'),
('Mariama Diop', 'Sénégal', 'Particulier'),
('Ousmane Koné', 'Mali', 'PME'),
('Kadiatou Camara', 'Guinée', 'Particulier'),
('Mamadou Barry', 'Sénégal', 'PME'),
('Rokhaya Ndiaye', 'Sénégal', 'Particulier'),
('Seydou Keita', 'Mali', 'PME'),
('Aminata Touré', 'Sénégal', 'Particulier'),
('Boubacar Diallo', 'Guinée', 'PME'),
('Fatoumata Sylla', 'Mali', 'Particulier'),
('Cheikh Mbaye', 'Sénégal', 'PME'),
('Marième Fall', 'Sénégal', 'Particulier'),
('Lamine Sanogo', 'Côte d\'Ivoire', 'PME'),
('Coumba Sarr', 'Sénégal', 'Particulier'),
('Modibo Coulibaly', 'Mali', 'PME'),
('Ndèye Faye', 'Sénégal', 'Particulier'),
('Alioune Badara Cissé', 'Sénégal', 'PME'),
('Bineta Diouf', 'Sénégal', 'Particulier'),
('Souleymane Diabaté', 'Côte d\'Ivoire', 'PME'),
('Awa Kouyaté', 'Mali', 'Particulier'),
('El Hadji Diouf', 'Sénégal', 'PME'),
('Yacine Tall', 'Sénégal', 'Particulier'),
('Drissa Traoré', 'Burkina Faso', 'PME'),
('Khady Gueye', 'Sénégal', 'Particulier'),
('Adama Coulibaly', 'Mali', 'PME'),
('Binta Diallo', 'Guinée', 'Particulier'),
('Pape Demba Mbaye', 'Sénégal', 'PME'),
('Astou Dème', 'Sénégal', 'Particulier'),
('Oumar Konaré', 'Mali', 'PME'),
('Salimata Koné', 'Côte d\'Ivoire', 'Particulier'),
('Babacar Niang', 'Sénégal', 'PME'),
('Maimouna Balde', 'Guinée', 'Particulier'),
('Tidiane Diallo', 'Sénégal', 'PME'),
('Ramatoulaye Seck', 'Sénégal', 'Particulier'),
('Moussa Diakité', 'Mali', 'PME'),
('Ndeye Fatou Ba', 'Sénégal', 'Particulier'),
('Ibrahima Ly', 'Sénégal', 'PME'),
('Oumou Sangaré', 'Mali', 'Particulier'),
('Serigne Mbaye', 'Sénégal', 'PME'),
('Diariatou Barry', 'Guinée', 'Particulier'),
('Landing Badji', 'Sénégal', 'PME'),
('Mame Diarra Bousso', 'Sénégal', 'Particulier'),
('Souleymane Sow', 'Sénégal', 'PME'),
('Aida Mbodj', 'Sénégal', 'Particulier'),
('Bourama Kouyaté', 'Mali', 'PME'),
('Fatimata Diallo', 'Burkina Faso', 'Particulier');

-- ============================================================
-- INSERTION : PRODUITS CREDIT
-- ============================================================
INSERT INTO produits_credit (taux, duree_max, montant_max) VALUES
(8.5, 12, 500000.00),
(10.0, 24, 2000000.00),
(12.5, 36, 5000000.00);

-- ============================================================
-- INSERTION : 200 DEMANDES FICTIVES
-- ============================================================
INSERT INTO demandes (client_id, montant_demande, score, decision) VALUES
(1, 250000, 720, '✅ Crédit approuvé'),
(2, 150000, 450, '❌ Crédit refusé'),
(3, 500000, 680, '⚠️ Crédit approuvé avec garanties'),
(4, 100000, 750, '✅ Crédit approuvé'),
(5, 800000, 380, '❌ Crédit refusé'),
(6, 200000, 620, '⚠️ Crédit approuvé avec garanties'),
(7, 350000, 710, '✅ Crédit approuvé'),
(8, 120000, 430, '❌ Crédit refusé'),
(9, 600000, 700, '✅ Crédit approuvé'),
(10, 180000, 550, '⚠️ Crédit approuvé avec garanties'),
(11, 400000, 760, '✅ Crédit approuvé'),
(12, 90000, 410, '❌ Crédit refusé'),
(13, 750000, 650, '⚠️ Crédit approuvé avec garanties'),
(14, 130000, 720, '✅ Crédit approuvé'),
(15, 300000, 480, '❌ Crédit refusé'),
(16, 220000, 590, '⚠️ Crédit approuvé avec garanties'),
(17, 450000, 730, '✅ Crédit approuvé'),
(18, 160000, 440, '❌ Crédit refusé'),
(19, 550000, 670, '⚠️ Crédit approuvé avec garanties'),
(20, 190000, 740, '✅ Crédit approuvé'),
(1, 300000, 715, '✅ Crédit approuvé'),
(2, 200000, 460, '❌ Crédit refusé'),
(3, 450000, 690, '⚠️ Crédit approuvé avec garanties'),
(4, 110000, 760, '✅ Crédit approuvé'),
(5, 700000, 390, '❌ Crédit refusé'),
(6, 250000, 610, '⚠️ Crédit approuvé avec garanties'),
(7, 380000, 720, '✅ Crédit approuvé'),
(8, 140000, 420, '❌ Crédit refusé'),
(9, 650000, 710, '✅ Crédit approuvé'),
(10, 170000, 560, '⚠️ Crédit approuvé avec garanties'),
(11, 420000, 770, '✅ Crédit approuvé'),
(12, 95000, 400, '❌ Crédit refusé'),
(13, 800000, 640, '⚠️ Crédit approuvé avec garanties'),
(14, 125000, 730, '✅ Crédit approuvé'),
(15, 320000, 470, '❌ Crédit refusé'),
(16, 240000, 580, '⚠️ Crédit approuvé avec garanties'),
(17, 480000, 740, '✅ Crédit approuvé'),
(18, 155000, 450, '❌ Crédit refusé'),
(19, 570000, 660, '⚠️ Crédit approuvé avec garanties'),
(20, 195000, 750, '✅ Crédit approuvé'),
(21, 280000, 700, '✅ Crédit approuvé'),
(22, 130000, 430, '❌ Crédit refusé'),
(23, 520000, 680, '⚠️ Crédit approuvé avec garanties'),
(24, 115000, 755, '✅ Crédit approuvé'),
(25, 720000, 370, '❌ Crédit refusé'),
(26, 230000, 600, '⚠️ Crédit approuvé avec garanties'),
(27, 360000, 715, '✅ Crédit approuvé'),
(28, 145000, 410, '❌ Crédit refusé'),
(29, 620000, 705, '✅ Crédit approuvé'),
(30, 175000, 545, '⚠️ Crédit approuvé avec garanties');