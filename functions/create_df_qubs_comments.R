# HEADER --------------------------------------------
#
# Author:     Charles Thévenin
# Copyright     Copyright 2025 - Charles Thévenin
# Email:      charles.thevenin@mnhn.fr
#
# Date:     2025-10-29
#
# Script Name:    fonctions/create_df_qubs_comments.R
#
# Script Description:   Création du data frame qubs avec les données de l'ensemble
#   des interactions Qubs (validations, commentaires,...). Requête envoyée sur le serveur FTP
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


# Requête sur la base de données ftp
# - Données Vers
# print("Requête des données récentes")
if (!exists("req_comments")) {
  req_comments <- GET(
    paste0(Sys.getenv('SITE_NAME'), "export_qubs_comments.csv"),
    authenticate(Sys.getenv('FTP_USER'), Sys.getenv('FTP_PASSWORD'), type = "basic")
  )
}

dt_comments <- readr::read_csv2(content(req_comments, "raw"))

if (Sys.getenv("MOSAIC") == "true") {
  # recuperer les donnees des interactions sociales via la table qubs.comments
  query <- read_sql_query(here::here("sql", "table_comments_qubs.sql"))
  dt_comments <- import_from_mosaic(query,
                                    database_name = "qubs",
                                    force_UTF8 = TRUE)
}