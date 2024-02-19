## Copyright (C) 2020-2024 Vincent Goulet
##
## Ce fichier fait partie de la formation «Introduction à la
## programmation avec R pour l'analyse de données» offerte par
## la Formation continue FSG

###
### IMPORTATION DES DONNÉES
###

## Les données ouvertes BIXI uniformes se présentent sous forme de
## fichiers CSV. Si vous cliquez sur un de ces fichiers dans votre
## gestionnaire de fichiers (Explorateur Windows sous Windows; Finder
## sous macOS), il s'ouvrira sans doute dans Excel.
##
## Les fichiers CSV ne sont pourtant que de simples fichiers en format
## texte brut que vous pouvez ouvrir avec n'importe quel éditeur de
## texte... ici compris RStudio.
##
## Question de voir à quoi il ressemble, je vous invite à d'abord
## ouvrir le fichier 'Stations_2021u.csv' dans RStudio. Utilisez pour
## ce faire le menu 'File|Open File...'. Vous constaterez que le
## fichier de données contient quatre colonnes, séparées par des
## virgules:
##
##   pk: code de station;
##   name: noms des stations sous forme de lieu ou de coin de rue;
##   latitude: latitude des positions géographiques précises;
##   longitude: longitude des positions géographiques précises.
##
## Nous allons conserver uniquement les deux premières colonnes. La
## latitude et la longitude seraient utiles pour positionner les
## stations sur une carte, chose tout à fait possible avec R, mais
## hors de la portée de cette formation.
##
## Pour importer les données dans R, nous allons utiliser la fonction
## 'read.csv'.
##
## - Le premier argument est le chemin d'accès complet vers le fichier
##   de données. Le répertoire par défaut est le répertoire de travail
##   de R.
## - L'argument 'colClasses' permet de spécifier le type de chaque
##   colonne. Nous allons utiliser le type 'integer' (entier) pour le
##   code de la station; 'character' (caractères) pour le nom; NULL
##   pour la latitude et la longitude pour ne pas importer ces deux
##   colonnes.
## - L'argument 'encoding' permet de spécifier le codage de caractères
##   du fichier, ici UTF-8. C'est une bonne idée de le préciser,
##   surtout sous Windows.
##
## L'expression suivante permet d'importer les données d'état des
## stations de 2021.
stations <- read.csv("data/Stations_2021u.csv",
                     colClasses = c(pk = "integer",
                                    name = "character",
                                    latitude = "NULL",
                                    longitude = "NULL"),
                     encoding = "UTF-8")

## Le résultat est un tableau de données.
class(stations)            # tableau de données
dim(stations)              # dimensions
head(stations)             # premières lignes du tableau
tail(stations)             # dernières lignes du tableau
stations$pk                # vecteur des codes de stations
stations$name              # vecteur des noms de stations

## Au tour des données d'historique des déplacements (ou d'utilisation
## des vélos). Attention, ces données sont très volumineuses!
##
## Il y a un fichier par mois. Le seul qui nous intéressera sera celui
## du mois de juin 2021, donc le fichier nommé 'OD_2021-06u.csv'. Or,
## il compte plus de 800 000 enregistrements! Tellement qu'il est trop
## gros pour RStudio. Un éditeur plus puissant est en mesure
## d'afficher le fichier.
##
## Qu'à cela ne tienne, voici la liste des colonnes du fichier:
##
##   start_date: date du début de la location;
##   emplacement_pk_start: code de la station de départ;
##   end_date: date de fin de la location;
##   emplacement_pk_end: code de la station d'arrivée;
##   duration_sec: durée de la location en secondes;
##   is_member: statut membre BIXI (0 ou 1).
##
## Nous aurons besoin de toutes ces informations. Nous allons utiliser
## le type 'Date' (que nous n'avons pas vu durant la formation) pour
## les dates de début et de fin d'une location; le type 'factor'
## (facteur) pour les codes de stations et pour le statut membre BIXI;
## le type 'numeric' (numérique) pour la durée de la location.
##
## La conversion des dates lors de l'importation des données sera
## *beaucoup* plus rapide si le fuseau horaire du système est "UTC"
## (ou, de manière équivalente, "GMT"). Nous allons donc modifier la
## variable d'environnement 'TZ' tout en sauvegardant sa valeur
## actuelle afin de la rétablir par la suite.
otz <- Sys.getenv("TZ")
Sys.setenv(TZ = "UTC")

## L'expression suivante permet d'importer les données d'historique
## des déplacements du mois de juin 2021.
##
## Note: comme le fichier ne comporte aucun accent, il n'y a pas de
## souci de codage des caractères.
rentals <- read.csv("data/OD_2021-06u.csv",
                    colClasses = c(start_date           = "Date",
                                   emplacement_pk_start = "factor",
                                   end_date             = "Date",
                                   emplacement_pk_end   = "factor",
                                   duration_sec         = "numeric",
                                   is_member            = "factor"))

## Le résultat est, ici encore, un tableau de données. Ne faites pas
## afficher tout le contenu du tableau car c'est très long! C'est là
## que les fonctions 'head' et 'tail' s'avèrent vraiment pratiques.
class(rentals)             # tableau de données
dim(rentals)               # dimensions
head(rentals)              # premières lignes du tableau
head(rentals, 25)          # quelques lignes de plus
tail(rentals)              # dernières lignes du tableau
tail(rentals, 25)          # quelques lignes de plus

## La fonction 'subset' permet d'extraire un sous-ensemble d'un
## tableau de données de manière assez intuitive. Nous pouvons
## spécifier les lignes, les colonnes ou une combinaison des deux.
##
## Voici quelques exemples (comme les réponses sont volumineuses, je
## ne fais qu'afficher le nombre de lignes).
##
## Locations entre le 1er et le 3 juin 2021, inclusivement.
nrow(subset(rentals, start_date <= "2021-06-03"))

## Locations entre le 3 et le 5 juin 2021, inclusivement.
nrow(subset(rentals, start_date >= "2021-06-03" &
                     start_date <= "2021-06-05"))

## Locations débutant ou se terminant à la station 274 (Gare
## d'autocars de Montréal).
nrow(subset(rentals, emplacement_pk_start == 274 |
                     emplacement_pk_end   == 274))

## Durées uniquement des locations précédentes.
dim(subset(rentals,
           subset = emplacement_pk_start == 274 |
                    emplacement_pk_end   == 274,
           select = duration_sec))

## Même chose, mais sous forme de vecteur de durées.
(x <- subset(rentals,
             subset = emplacement_pk_start == 274 |
                      emplacement_pk_end   == 274,
             select = duration_sec,
             drop = TRUE))
length(x)                  # == nombre de lignes ci-dessus

## Variante de la même idée avec plusieurs choix de stations de départ
## et d'arrivée possibles. Nous ne pouvons utiliser l'opérateur
## d'égalité, dans ce cas. Ce qu'il nous faut, c'est un opérateur
## d'appartenance à un ensemble. Dans R, c'est '%in%'.
c(4, 3, 12, 23, 10) %in% 1:10 # exemple

## Durées des locations ayant comme point de départ ou d'arrivée l'une
## ou l'autre des stations 304, 491, 530, 1000.
codes <- c(304, 491, 530, 1000)
x <- subset(rentals,
            subset = emplacement_pk_start %in% codes |
                     emplacement_pk_end   %in% codes,
            select = duration_sec,
            drop = TRUE)
length(x)                  # nombre de locations
summary(x)                 # statistiques descriptives
hist(x)                    # histogramme des durées

###
### EXERCICE 1
###

## Les fonctions sont utiles pour masquer les détails d'une ou
## plusieurs expressions que l'on utilise à répétition. On dit
## qu'elles agissent comme des «couches d'abstraction».
##
## Votre premier exercice consiste à rédiger deux fonctions: une pour
## importer des données de stations et une autre pour importer des
## données d'historique des déplacements. Leurs signatures doivent
## être:
##
##   importStations(file)
##   importRentals(file)
##
## Dans les deux cas, 'file' est le nom du fichier de données à
## importer. Le résultat des fonctions est un tableau de données.


importStations <- function(file) {
  csv <- read.csv(file,
                  colClasses = c(pk = "integer",
                                 name = "character",
                                 latitude = "NULL",
                                 longitude = "NULL"),
                  encoding = "UTF-8")
}

stations <- importStations("data/Stations_2021u.csv")

importRentals <- function(file) {
  csv <- read.csv(file, colClasses = c(start_date           = "Date",
                                       emplacement_pk_start = "factor",
                                       end_date             = "Date",
                                       emplacement_pk_end   = "factor",
                                       duration_sec         = "numeric",
                                       is_member            = "factor"),
                  encoding = "UTF-8")
}

rentals <- importRentals("data/OD_2021-06u.csv")


  
###
### EXTRACTION DES CODES DE STATIONS
###

## Pour répondre au mandat qui nous a été confié, il faudra extraire
## des données 'stations' les codes des stations qui se trouvent sur
## ou à une intersection de la rue Rachel afin de les identifier
## dans les données 'rentals'.
##
## Nous allons supposer que les stations visées sont uniqument celles
## dont le nom contient le nom "Rachel". (Il pourrait nous manquer les
## stations identifiées uniquement par le nom d'un lieu qui s'avère se
## trouver sur la rue Rachel. Pas grave.)
##
## Nous voulons extraire le *code* d'une station si son *nom*
## correspond à un critère, ici contenir le mot "Rachel".
##
## C'est un travail d'indiçage du tableau de données 'stations': il
## s'agit d'extraire les éléments de la colonne 'code' dont l'élément
## correspondant de la colonne 'name' satisfait le critère.
##
## Supposons que le mot "Rachel" se trouve dans les noms de stations
## aux positions 7, 42, 111 et 433. Nous obtiendrions les codes de
## stations avec l'expression suivante.
stations$pk[c(7, 42, 111, 433)]

## Reste donc à construire une expression pour obtenir le vecteur des
## positions.
##
## Pour identifier "Rachel" à l'intérieur des noms de stations, nous
## allons devoir avoir recours à une «expression régulière». Une
## expression régulière (regular expression; souvent abrégé «regex» ou
## «regexp») est une suite de caractères typographiques qui décrit,
## selon une syntaxe précise, un ensemble de chaines de caractères
## possibles (Wikipedia). C'est un sujet d'étude assez fascinant. Si
## vous ne connaissez pas le sujet, je vous invite à lire le chapitre
## 11 de «Programmer avec R».
##
## Heureusement, nous n'aurons pas besoin d'une expression régulière
## compliquée pour notre mandat. En fait, le simple motif "Rachel"
## suffit. Tout ça pour ça.
##
## Il existe dans R plusieurs fonctions pour effectuer des recherches
## dans du texte à l'aide d'expressions régulières. Nous aurons
## recours à 'grep'.
##
## La fonction prend en argument un motif d'expression régulière et un
## vecteur, puis retourne les positions des éléments du vecteur qui
## correspondent au motif.
grep("Rachel", stations$name)

## Vérifions les noms de ces stations qui contiennent "Rachel" en
## demandant à 'grep' de nous retourner les éléments qui correspondent
## au motif, plutôt que leur position.
grep("Rachel", stations$name, value = TRUE)

## Il ne nous reste plus qu'à assembler les morceaux pour obtenir les
## codes des stations de la rue Rachel.
stations$pk[grep("Rachel", stations$name)]

###
### EXERCICE 2
###

## Rédiger une fonction 'getStationCode' qui extrait le code des
## stations qui se trouvent sur une rue donnée ou à une intersection
## de cette rue. La signature de la fonction est:
##
##   getStationCode(data, pattern)
##
## L'argument 'data' est un tableau de données des codes des noms
## complets de stations. L'argument 'pattern' est un motif d'expression
## régulière (une chaine de caractères) décrivant une rue ou une
## intersection. Le résultat est un vecteur de code de stations.

getStationCode <- function(data, pattern){
  result <- data$pk[grep(pattern, data$name)]
  return(result)
}

getStationCode(stations, "Rachel")
getStationCode(stations, "1")


###
### EXERCICE 3
###

## Allons-y immédiatement avec un autre exercice --- un peu plus
## difficile, mais que vous pouvez résoudre avec les exemples de
## 'subset' ci-haut.
##
## Rédiger une fonction 'getRentals' qui extrait les données des
## déplacements entre deux dates (au jour près et inclusivement) qui
## s'amorcent ou se terminent dans des stations données (identifiées
## par leur code). La signature de la fonction est:
##
##   getRentals(data, start, end, code)
##
## L'argument 'data' est un tableau de données d'historique des
## déplacements. Les arguments 'start' et 'end' sont des chaines de
## caractères contenant des dates dans le format AAAA-MM-JJ.
## L'argument 'code' est un vecteur de codes de stations. Le résultat
## est un tableau de données sous-ensemble de l'argument 'data'.

getRentals <- function(data, start, end, code) {
  result.rentals <- subset(data, subset = start_date >= start & 
                             end_date <= end & emplacement_pk_end == code)
  return(result.rentals)
}

getRentals(rentals, "2021-06-29", "2021-06-30", 10)


###
### CALCUL DES REVENUS DE LOCATION
###

## Nous pouvons calculer les revenus de location de BIXI pour une
## période donnée à partir des durées des locations durant la période
## et de la grille de tarification de BIXI qui était en vigueur en
## 2021. (Nous allons supposer que toutes les locations sont réglées à
## l'unité, donc sans tenir compte des abonnements, des forfaits ou
## autres.)
##
## La grille de tarification de 2021 est la suivante:
##
## - 2,99 $ pour une location de moins de 30 minutes;
## - frais supplémentaires de 1,80 $ pour une location de 30 à 45
##   minutes;
## - frais supplémentaires de 3,00 $ par tranche de 15 minutes pour
##   une location plus de 45 minutes.
##
## Soit t la durée d'une location en secondes. Nous pouvons exprimer
## le coût d'une location sous forme mathématique ainsi:
##
##          | 2,99,                            si t < 1800
##   coût = | 4,79,                            si 1800 <= t <= 2700
##          | 4,79 + 3 * [(t - 2700)/900 + 1], si t > 2700.
##
## (Notes: [x + 1] est le petit entier supérieur à x; 900 = 15 * 60;
## 1800 = 30 * 60; 2700 = 30 * 60.)
##
## Vous regardez cette fonction définie en branches et vous vous
## dites: «facile à faire dans R avec des 'if... else'!» En effet,
## c'est assez simple pour une seule durée. (Pour calculer le plus
## petit entier supérieur à un nombre réel, nous allons utiliser la
## fonction 'ceiling' (plafond).)
cost <- function(t)
{
    if (t < 1800)
        2.99
    else if (t <= 2700)
        4.79
    else
        4.79 + 3 * ceiling((t - 2700)/900)
}
cost(12 * 60)              # location de 12 minutes
cost(42 * 60)              # location de 42 minutes
cost(52 * 60)              # location de 52 minutes
cost(72 * 60)              # location de 72 minutes

## L'ennui avec la fonction 'cost' ci-dessus, c'est qu'elle n'est pas
## vectorielle puisque la clause 'if' n'accepte pas un vecteur de
## durées dans la condition.
cost(c(12, 42, 52, 72) * 60)

## Comment vectoriser ces calculs?
##
## Une solution consisterait à créer une fonction auxiliaire bonne
## pour une seule durée et l'appliquer ensuite sur toutes les durées.
## C'est une bonne solution, mais nous pouvons faire mieux.
##
## Dans le cas présent, il est possible de composer directement une
## fonction vectorielle sans passer par des fonctions d'application
## ou, pire, par des boucles.
##
## La clé réside dans la décomposition de la structure de tarification
## en tranches «horizontales» plutôt qu'en tranches «verticales» comme
## ci-dessus. Ce que cela signifie, c'est que nous pouvons remarquer
## que le montant de base de 2,99 $ est toujours présent; le montant
## additionnel de 1,80 $ s'ajoute à partir de 30 minutes et, par la
## suite, des montants de 3,00 $ s'ajoutent toutes les 15 minutes.
##
## La fonction de coût d'une location peut donc se réécrire ainsi:
##
##   coût = 2,95 + 1,80 * I(t >= 1800)
##               + 3,00 * [max(0, t - 2700)/900 + 1],
##
## où I() est une fonction indicatrice qui vaut 1 lorsque son
## argument est vrai et zéro sinon.
##
## Les fonctions indicatrices sont très simples à écrire en R: il
## suffit d'utiliser une expression (possiblement vectorielle) qui
## évalue à TRUE ou FALSE et effectuer le calcul avec le vecteur de
## résultats. Les valeurs booléennes seront automatiquement converties
## en 1 et 0 dans les calculs. Quant à la fonction mathématique 'max',
## son équivalent vectoriel dans R est 'pmax'.
t <- c(12, 42, 52, 72) * 60    # vecteur de durées
t > 1800                       # locations de plus de 30 minutes
pmax(0, t - 2700)              # excédent de 45 minutes
ceiling(pmax(0, t - 2700)/900) # tranches de 15 minutes en excédent

## L'expression suivante permet de calculer le coût de plusieurs
## locations à partir d'un vecteur de durées.
2.99 + 1.80 * (t > 1800) + 3 * pmax(0, ceiling((t - 2700)/900))

###
### EXERCICE 4
###

## Rédiger une fonction 'cost' qui calcule le coût, selon la grille de
## tarification 2018 de BIXI, des locations à partir d'un vecteur de
## durées en secondes. La signature de la fonction est:
##
##   cost(x)
##
## L'argument 'x' est un vecteur de durées de locations en secondes.
## Le résultat est un vecteur coûts de location.

cost <- function(x) {
  sapply(x, function(t) {
    if (t < 1800) {
      cost <- 2.99
    } else if (t <= 2700) {
      cost <- 4.79
    } else {
      
      plus <- ceiling((t - 2700) / 900)
      cost <- 4.79 + 3 * plus
    }
    return(cost)
  })
}

cost(2900)
couts <- cost(c(90, 92, 82, 72) * 60)
###
### CALCUL DES REVENUS TOTAUX
###

## Il ne nous reste que deux choses à faire pour pouvoir compléter
## notre mandat: calculer les revenus de location totaux et les
## ventiler par le statut des personnes effectuant la location: membre
## BIXI ou non membre.

###
### EXERCICE 5
###

## Je vous laisse immédiatement sur le dernier exercice, non sans
## d'abord vous donner trois indices:
##
## 1. la fonction 'sum' effectue la somme des éléments d'un vecteur;
## 2. suite à l'importation des données d'historique des déplacements,
##    la colonne 'is_member' est un facteur;
## 3. la fonction pour tester si une valeur est 'NULL' est 'is.null'.
##
## Rédiger une fonction 'revenues' qui calcule les revenus totaux
## d'une série de locations, revenus possiblement ventilés par le
## statut (membre ou non membre) des personnes effectuant la location.
## La signature de la fonction est:
##
##   revenues(x, status = NULL)
##
## L'argument 'x' est un vecteur de coûts de location. L'argument
## 'status', est un facteur de la même longueur que 'x', identifiant
## le statut de la personne qui effectue une location (membre ou non
## membre). Le résultat est un vecteur d'un ou de deux montants totaux
## de revenus de location.

revenues <- function(x, status = NULL) {
  if (is.null(status)) {
    return(sum(x))
  } else {
    # On crée une liste vide
    revenus <- numeric(length(levels(status)))
    names(revenus) <- levels(status)
    
    # Calculer les revenus pour chaque statut
    for (niv in levels(status)) {
      revenus[niv] <- sum(x[status == niv])
    }
    
    return(revenus)
  }
}

revenues(couts)
revenues(couts, status = as.factor(c(1,1,0,1)))

###
### SOLUTION DU MANDAT
###

## Nous avons maintenant en main une série de fonctions qui, mises
## bout à bout, permettent de répondre à la question du mandat, soit
## de calculer les revenus totaux générés par les stations qui se
## trouvent sur ou à une intersection de la rue Rachel entre le 7 et
## le 23 juin 2021 (inclusivement), puis de ventiler ces revenus entre
## ceux provenant des membres BIXI et ceux provenant des non membres.
##
## Si vos fonctions respectent les spécifications, la suite d'appels
## de fonctions ci-dessous devrait permettre d'effectuer les calculs
## demandés. Cette façon de faire est --- du moins en partie --- de la
## programmation fonctionnelle.
##
## C'est le moment de vérité...

## Importation des données des stations BIXI de 2021.
stations <- importStations("data/Stations_2021u.csv")

## Importation des données d'historique des déplacement du mois de
## juin 2021.
rentals <- importRentals("data/OD_2021-06u.csv")

## Extraction des codes des stations se trouvant sur ou à une
## intersection de la rue Rachel.
code <- getStationCode(stations, "Rachel")

## Extraction des données de location des déplacements effectués entre
## le 7 et le 23 juin 2021 (inclusivement) et impliquant une station
## de la rue Rachel.
myrentals <- getRentals(rentals,
                        start = "2021-06-07", end = "2021-06-23",
                        code = code)

## Calcul du coût des locations retenues. Les durées se trouvent dans
## la colonne 'duration_sec' du tableau de données.
mycost <- cost(myrentals$duration_sec)

## Calcul des revenus totaux et des revenus totaux ventilés par le
## statut des personnes effectuant la location. Les statuts se
## trouvent dans la colonne 'is_member' du tableau de données.
revenues(mycost)                      # total général
revenues(mycost, myrentals$is_member) # total ventilé par statut

###
### SOLUTIONNAIRE
###

## Le fichier 'fonctions.R' livré avec la formation contient mes
## versions des fonctions demandées dans les exercices.
##
## Vous pouvez définir mes versions dans l'espace de travail avec la
## fonction 'source' qui évalue en lot un fichier de script.
source("fonctions.R")

## Avez-vous obtenu la même réponse que moi?
stations <- importStations("Stations_2021u.csv")
rentals <- importRentals("OD_2021-06u.csv")
code <- getStationCode(stations, "Rachel")
myrentals <- getRentals(rentals,
                        start = "2021-06-07", end = "2021-06-23",
                        code = code)
mycost <- cost(myrentals$duration_sec)
revenues(mycost)                      # total général
revenues(mycost, myrentals$is_member) # total ventilé par statut

## Rétablir la variable d'environnement 'TZ'.
Sys.setenv(TZ = otz)
