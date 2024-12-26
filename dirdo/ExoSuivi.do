/*******************************************************************************
*                          TP1 STATISTIQUES AGRICOLES                          *
********************************************************************************
*                                                                              *
*   OBJECTIF:  Utiliser Stata pour le traitement des données agricoles.        *
*			   Dans ce TP, nous analysons des données agricoles provenant de   *
*			   différents villages, en mettant l'accent sur les statistiques   *
*			   liées à la production, à la superficie et aux rendements.       *
*                                                                              *
*                                                                              *
*   PLAN:     PART 1:  Préparation de l'environnement de travail               *
*		      PART 2:  Préparation des données                                 *
*             PART 3:  Calculs et analyses            					       *                                        									    *
*                                                                              *
********************************************************************************
    PART 1:  Préparation de l'environnement de travail
********************************************************************************/
	
	capture clear // vider la mémoire
	set dp comma // Définir le point comme séparateur de milliers
	set more off // Afficher les résultats complets
	
	*** Définir et fixer les répertoires de travail ***
	global reptrav = "E:\Ecole\AS2\Semestre1\Stat_agricole\Tp\TP1" 
	global dirdata = "$reptrav\dirdata" // répertoire pour les données en input
	global dirdo = "$reptrav\dirdo" // repertoire pour les do-files
	global diroutput = "$reptrav\diroutput" // repertoire pour les sorties
	
	capture log close
	log using "$diroutput\ExoSuivi.smcl", replace
	

/*******************************************************************************
    PART 2:  Préparation des données
********************************************************************************/
	
	cd "$dirdo" // On spécifie le répertoire de travail
	
	// On importe la base de données excel, contenue dans la "Feuil1" et  
	// en spécifiant que la ligne 1 correspond aux variables
	import excel "$dirdata\Kawteef.xlsx", sheet("Feuil1") firstrow clear
	
	// Nombre d'observations et de variables
	display "Nombre d'observations: `c(N)', Nombre de variables: `c(k)'"
	
	// On labelise les variables de la base
	la var Village "Village"
	la var Pop "Population du village"
	la var Suptot "Superficie totale du village"
	
/*******************************************************************************
    PART 3:  Calculs et analyses
********************************************************************************/

	** 1. Superficie moyenne par ménage, dans chaque village **
	gen superficie_moyenne = Suptot/Pop
	la var superficie_moyenne "Superfie moyenne"
	
	list Village superficie_moyenne
	
	** 2. Rendement moyen du mil **
	gen r =Prod/Suptot
	la var r "Rendement moyen"
	
	** 3. Trier les villages par production totale, puis par rendement moyen **
	sort Prod r
	list Village Prod r
	
	** 4. Superficie totale emblavée dans la zone A (villages: 2, 7, 13, 47, 38) **
	gen Zone_A = inlist(Village,"Village2","Village7","Village13","Village47","Village38")
	egen sup_zoneA = total(Suptot) if Zone_A == 1
	la var sup_zoneA "Superficie totale Zone A"
	
	list Village Zone_A sup_zoneA
	
	** 5. Production totale dans la zone B **
	egen prod_zoneB = total(Prod) if Zone_A == 0
	la var prod_zoneB "Production totale Zone B"
	
	list Village Zone_A prod_zoneB
	
	** 6. Rendement moyen du mil dans chaque zone **
	// Dans la zone A
	egen prod_zoneA = total(Prod) if Zone_A == 1
	gen r_A = prod_zoneA/sup_zoneA
	
	la var r_A "Rendement moyen de la zone A"
	la var prod_zoneA "Production totale Zone A"
	
	// Dans la zone B
	egen sup_zoneB = total(Suptot) if Zone_A == 0
	gen r_B = prod_zoneB/sup_zoneB
	
	la var r_B "Rendement moyen de la zone B"
	la var sup_zoneB "Superficie totale Zone B"
	
	list Village Zone_A r_A r_B
	
	** 7. Créer une variable Subvention pour indiquer si un village a une population ≥ 450 **
	gen Subvention = Pop >= 450
	la var Subvention "Subvention"
	
	list Village Pop Subvention
	
	** 8. Conserver uniquement les villages où la superficie moyenne par ménage 
	** est < 1 hectare et enregistrer sous pauvres_villages.dta **
	keep if superficie_moyenne < 4
	save "$diroutput\pauvres_villages.dta", replace
	
	list Village Pop Zone_A superficie_moyenne
	
	** 9. Calculer la taille moyenne par zone et exporter sur Word **
	asdoc tabstat (Pop), by(Zone_A) stat(mean) save ("taille_moyenne_par_zone.doc")
	
	