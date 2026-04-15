/* ============================================================
README – Projekt A: SQL-Analyse für Kreditrisiken (ohne WITH)
---------------------------------------------------------------
Dieses Skript ist kompatibel mit MySQL 5.7+ (kein WITH/CTE).
Jede Abfrage arbeitet mit abgeleiteten Tabellen (Subqueries).
Parameter für Red-Flags sind anpassbar:
 - @SCHWELLE_GROSSER_BETRAG (Standard: 20000)
 - @SCHWELLE_NIEDRIGER_ZINS (Standard: 10.00)
============================================================ */


/* ============================================================
AUFGABE 1: Kreditüberwachung – Verteilung der Risikoklassen
---------------------------------------------------------------
Erklärung:
Diese Abfrage liefert Anzahl, Anteil und Ø-DTI je Risikoklasse.
Die Klassifizierung erfolgt direkt in einer Subquery ("t").
============================================================ */
SELECT
  t.risiko_klasse_fuer_kreditueberwachung                    AS risiko_klasse,
  COUNT(*)                                                    AS anzahl_kredite_je_risikoklasse,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM credit_risk_dataset_clean), 2)
                                                             AS anteil_der_risikoklasse_in_prozent,
  ROUND(AVG(t.debt_to_income_quote), 4)                      AS durchschnittliche_debt_to_income_quote
FROM (
  SELECT
    person_einkommen,
    kredit_betrag,
    CASE
      WHEN kredit_status = 1 OR schufa_vormerkung = 'JA' THEN 'HOHES RISIKO'
      WHEN person_einkommen IS NOT NULL AND person_einkommen > 0
           AND (kredit_betrag / person_einkommen) > 0.50     THEN 'MITTLERES RISIKO'
      ELSE 'GERINGES RISIKO'
    END AS risiko_klasse_fuer_kreditueberwachung,
    CASE
      WHEN person_einkommen IS NOT NULL AND person_einkommen > 0
        THEN kredit_betrag / person_einkommen
      ELSE NULL
    END AS debt_to_income_quote
  FROM credit_risk_dataset_clean
) AS t
GROUP BY t.risiko_klasse_fuer_kreditueberwachung
ORDER BY FIELD(t.risiko_klasse_fuer_kreditueberwachung,'HOHES RISIKO','MITTLERES RISIKO','GERINGES RISIKO');


/* ============================================================
AUFGABE 2a: Zinssätze je Kreditnote
---------------------------------------------------------------
Erklärung:
Prüft, ob schlechtere Noten höhere Zinssätze haben.
Zeigt auch Min/Max-Werte für Ausreißer.
============================================================ */
SELECT
  kredit_note                                                  AS kreditnote,
  ROUND(AVG(kredit_zinssatz), 2)                               AS durchschnittlicher_zinssatz_pro_kreditnote,
  ROUND(MIN(kredit_zinssatz), 2)                               AS minimaler_zinssatz_pro_kreditnote,
  ROUND(MAX(kredit_zinssatz), 2)                               AS maximaler_zinssatz_pro_kreditnote,
  COUNT(*)                                                     AS anzahl_kredite_pro_kreditnote
FROM credit_risk_dataset_clean
GROUP BY kredit_note
ORDER BY kredit_note;


/* ============================================================
AUFGABE 2b: Kreditbeträge je Kreditnote
---------------------------------------------------------------
Erklärung:
Analysiert Durchschnitt, Min, Max der Beträge je Kreditnote.
Ein klarer Abwärtstrend bei schlechterer Bonität wäre sinnvoll.
============================================================ */
SELECT
  kredit_note                                                  AS kreditnote,
  ROUND(AVG(kredit_betrag), 0)                                 AS durchschnittlicher_kreditbetrag_pro_kreditnote,
  MIN(kredit_betrag)                                           AS minimaler_kreditbetrag_pro_kreditnote,
  MAX(kredit_betrag)                                           AS maximaler_kreditbetrag_pro_kreditnote,
  COUNT(*)                                                     AS anzahl_kredite_pro_kreditnote
FROM credit_risk_dataset_clean
GROUP BY kredit_note
ORDER BY kredit_note;


/* ============================================================
AUFGABE 2c: Red Flags – große Kredite mit niedrigen Zinssätzen
---------------------------------------------------------------
Erklärung:
Findet auffällige Kredite (hoher Betrag, niedriger Zins).
Schwellenwerte sind anpassbar.
============================================================ */
SET @SCHWELLE_GROSSER_BETRAG = 20000;
SET @SCHWELLE_NIEDRIGER_ZINS = 10.00;

-- Gesamtübersicht
SELECT
  COUNT(*) AS gesamtanzahl_kredite,
  SUM(CASE WHEN kredit_betrag > @SCHWELLE_GROSSER_BETRAG
            AND kredit_zinssatz < @SCHWELLE_NIEDRIGER_ZINS
            THEN 1 ELSE 0 END)                                 AS anzahl_verdaechtiger_kredite,
  ROUND(100.0 * SUM(CASE WHEN kredit_betrag > @SCHWELLE_GROSSER_BETRAG
            AND kredit_zinssatz < @SCHWELLE_NIEDRIGER_ZINS
            THEN 1 ELSE 0 END) / COUNT(*), 2)                  AS anteil_verdaechtiger_kredite_in_prozent
FROM credit_risk_dataset_clean;

-- Nach Kreditnote
SELECT
  kredit_note                                                  AS kreditnote,
  COUNT(*)                                                     AS anzahl_kredite_pro_kreditnote,
  SUM(CASE WHEN kredit_betrag > @SCHWELLE_GROSSER_BETRAG
            AND kredit_zinssatz < @SCHWELLE_NIEDRIGER_ZINS
            THEN 1 ELSE 0 END)                                 AS anzahl_verdaechtiger_kredite_pro_kreditnote,
  ROUND(100.0 * SUM(CASE WHEN kredit_betrag > @SCHWELLE_GROSSER_BETRAG
            AND kredit_zinssatz < @SCHWELLE_NIEDRIGER_ZINS
            THEN 1 ELSE 0 END) / COUNT(*), 2)                  AS anteil_verdaechtiger_kredite_pro_kreditnote_in_prozent
FROM credit_risk_dataset_clean
GROUP BY kredit_note
ORDER BY kredit_note;


/* ============================================================
INSIGHT 1: Durchschnittliches Einkommen (gesamt & je Risikoklasse)
---------------------------------------------------------------
Erklärung:
Zeigt das Einkommen aller Kreditnehmer sowie nach Risiko.
Hilft beim Erkennen, ob Hochrisiko-Kunden einkommensschwächer sind.
============================================================ */
SELECT
  'GESAMT' AS gruppe,
  ROUND(AVG(person_einkommen), 0) AS durchschnittliches_einkommen
FROM credit_risk_dataset_clean
UNION ALL
SELECT
  risiko_klasse, ROUND(AVG(person_einkommen),0)
FROM (
  SELECT
    person_einkommen,
    CASE
      WHEN kredit_status = 1 OR schufa_vormerkung = 'JA' THEN 'HOHES RISIKO'
      WHEN person_einkommen IS NOT NULL AND person_einkommen > 0
           AND (kredit_betrag / person_einkommen) > 0.50 THEN 'MITTLERES RISIKO'
      ELSE 'GERINGES RISIKO'
    END AS risiko_klasse
  FROM credit_risk_dataset_clean
) t
GROUP BY risiko_klasse
ORDER BY gruppe;


/* ============================================================
INSIGHT 2: Kreditvolumen gesamt & Anteil je Kreditnote
---------------------------------------------------------------
Erklärung:
Berechnet das gesamte Kreditvolumen und den Anteil pro Kreditnote.
Zeigt, welche Noten den größten Teil des Portfolios ausmachen.
============================================================ */
SELECT
  s.kredit_note                                                  AS kreditnote,
  ROUND(SUM(s.kredit_betrag),0)                                  AS kreditvolumen_je_kreditnote,
  ROUND(100.0 * SUM(s.kredit_betrag) / (SELECT SUM(kredit_betrag) FROM credit_risk_dataset_clean), 2)
                                                                 AS anteil_am_gesamtvolumen_in_prozent
FROM credit_risk_dataset_clean s
GROUP BY s.kredit_note
ORDER BY s.kredit_note;


/* ============================================================
INSIGHT 3: Ausfallquote (gesamt & je Kreditnote)
---------------------------------------------------------------
Erklärung:
Gibt den prozentualen Anteil der ausgefallenen Kredite an.
Aufgeschlüsselt nach Kreditnote sollte ein klarer Anstieg sichtbar sein.
============================================================ */
SELECT
  'GESAMT' AS kreditnote,
  ROUND(100.0 * AVG(CASE WHEN kredit_status = 1 THEN 1 ELSE 0 END), 2) AS ausfallquote_in_prozent
FROM credit_risk_dataset_clean
UNION ALL
SELECT
  kredit_note,
  ROUND(100.0 * AVG(CASE WHEN kredit_status = 1 THEN 1 ELSE 0 END), 2)
FROM credit_risk_dataset_clean
GROUP BY kredit_note
ORDER BY kreditnote;


/* ============================================================
INSIGHT 4: Wohneigentum je Risikoklasse
---------------------------------------------------------------
Erklärung:
Zeigt Anteile von Miete/Hypothek/Eigentum je Risikoklasse.
Ein hoher Mieteranteil kann auf instabilere Kunden hinweisen.
============================================================ */
SELECT
  risiko_klasse,
  ROUND(100.0 * SUM(CASE WHEN person_wohneigentum='MIETE' THEN 1 ELSE 0 END)/COUNT(*),1) AS anteil_miete_prozent,
  ROUND(100.0 * SUM(CASE WHEN person_wohneigentum='HYPOTHEK' THEN 1 ELSE 0 END)/COUNT(*),1) AS anteil_hypothek_prozent,
  ROUND(100.0 * SUM(CASE WHEN person_wohneigentum='EIGENTUM' THEN 1 ELSE 0 END)/COUNT(*),1) AS anteil_eigentum_prozent,
  ROUND(100.0 * SUM(CASE WHEN person_wohneigentum='ANDERE' THEN 1 ELSE 0 END)/COUNT(*),1) AS anteil_andere_prozent
FROM (
  SELECT
    person_wohneigentum,
    CASE
      WHEN kredit_status = 1 OR schufa_vormerkung = 'JA' THEN 'HOHES RISIKO'
      WHEN person_einkommen IS NOT NULL AND person_einkommen > 0
           AND (kredit_betrag / person_einkommen) > 0.50 THEN 'MITTLERES RISIKO'
      ELSE 'GERINGES RISIKO'
    END AS risiko_klasse
  FROM credit_risk_dataset_clean
) t
GROUP BY risiko_klasse
ORDER BY FIELD(risiko_klasse,'HOHES RISIKO','MITTLERES RISIKO','GERINGES RISIKO');


/* ============================================================
INSIGHT 5: Berufserfahrung je Risikoklasse
---------------------------------------------------------------
Erklärung:
Zeigt die durchschnittliche Berufserfahrung und Streuung je Risikoklasse.
Wenig Erfahrung in Hochrisiko-Gruppen kann Instabilität bedeuten.
============================================================ */
SELECT
  risiko_klasse,
  ROUND(AVG(person_berufserfahrung),2)  AS durchschnittliche_berufserfahrung_jahre,
  ROUND(STDDEV_SAMP(person_berufserfahrung),2) AS streuung_berufserfahrung_jahre,
  COUNT(*)                             AS anzahl_kredite
FROM (
  SELECT
    person_berufserfahrung,
    CASE
      WHEN kredit_status = 1 OR schufa_vormerkung = 'JA' THEN 'HOHES RISIKO'
      WHEN person_einkommen IS NOT NULL AND person_einkommen > 0
           AND (kredit_betrag / person_einkommen) > 0.50 THEN 'MITTLERES RISIKO'
      ELSE 'GERINGES RISIKO'
    END AS risiko_klasse
  FROM credit_risk_dataset_clean
) t
GROUP BY risiko_klasse
ORDER BY FIELD(risiko_klasse,'HOHES RISIKO','MITTLERES RISIKO','GERINGES RISIKO');
