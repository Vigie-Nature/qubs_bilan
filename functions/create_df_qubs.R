# HEADER --------------------------------------------
#
# Author:     Maël Pretet
# Copyright     Copyright 2024 - Maël Pretet
# Email:      mael.pretet1@mnhn.fr
#
# Date:     2024-03-26
#
# Script Name:    fonctions/create_df_qubs.R
#
# Script Description:   Création du data frame qubs avec les données de l'ensemble
#   des protocoles Qubs. Interrogation de la base de données mosaic et enregistrement
#   dans un fichier rds. Si le fichier existe déjà et qu'il date de moins d'une
#   semaine, celui-ci est directement lu.
#
#
# ------------------------------------

library(dplyr)
library(here)
require(httr)
library(readr)

if (Sys.getenv("CI") != "true") {
  readRenviron(".env")
}

source("functions/var.R")

# Requête sur la base de données ftp
# - Données Vers
# print("Requête des données récentes")
if (!exists("req_vers")) {
  req_vers <- GET(
    paste0(Sys.getenv('SITE_NAME'), "export_qubs_vers.csv"),
    authenticate(Sys.getenv('FTP_USER'), Sys.getenv('FTP_PASSWORD'), type = "basic")
  )
}

dt_vers <- readr::read_csv2(content(req_vers, "raw"))

# - Données Noctambules
# print("Requête des données ensemble de la période")
if (!exists("req_noctambules")) {
  req_noctambules <- GET(
    paste0(Sys.getenv('SITE_NAME'), "export_qubs_noctambules.csv"),
    authenticate(Sys.getenv('FTP_USER'), Sys.getenv('FTP_PASSWORD'), type = "basic")
  )
}

dt_noctambules <- readr::read_csv2(content(req_noctambules, "raw"))

# - Données Aspifaune
# print("Requête des données ensemble de la période")
if (!exists("req_aspifaune")) {
  req_aspifaune <- GET(
    paste0(Sys.getenv('SITE_NAME'), "export_qubs_aspifaune.csv"),
    authenticate(Sys.getenv('FTP_USER'), Sys.getenv('FTP_PASSWORD'), type = "basic")
  )
}

dt_aspifaune <- readr::read_csv2(content(req_aspifaune, "raw"))

# - Données Escargots
# print("Requête des données ensemble de la période")
if (!exists("req_escargots")) {
  req_escargots <- GET(
    paste0(Sys.getenv('SITE_NAME'), "export_qubs_escargots.csv"),
    authenticate(Sys.getenv('FTP_USER'), Sys.getenv('FTP_PASSWORD'), type = "basic")
  )
}

dt_escargots <- readr::read_csv2(content(req_escargots, "raw"))