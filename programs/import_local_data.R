dt_aspifaune <- data.table::fread(here::here("data", "aspifaune_export_donnes_a_plat.csv"), encoding = "Latin-1") %>%
  rename(session_id = participation_id,
         session_date = date_debut,
         user_id = participant_id,
         taxon_count = abondance) %>%
  tidyr::separate_wider_delim(site_coordonnees_GPS, delim = ", ", names = c("latitude", "longitude"))
dt_aspifaune$taxon[dt_aspifaune$taxon == "NULL"] <- NA
dt_noctambules <- data.table::fread(here::here("data", "noctembules_export_donnees_a_plat.csv"), encoding = "Latin-1") %>%
  rename(session_id = participation_id,
         session_date = date_debut,
         user_id = participant_id,
         taxon_count = abondance) %>%
  tidyr::separate_wider_delim(site_coordonnees_GPS, delim = ", ", names = c("latitude", "longitude"))
dt_noctambules$taxon[dt_noctambules$taxon == "NULL"] <- NA
dt_escargots <- data.table::fread(here::here("data", "escargots_export_donnes_a_plat.csv"), encoding = "Latin-1") %>%
  rename(session_id = participation_id,
         session_date = date,
         user_id = participant_id,
         taxon_count = abondance) %>%
  tidyr::separate_wider_delim(site_coordonnees_GPS, delim = ", ", names = c("latitude", "longitude"))
dt_escargots$taxon[dt_escargots$taxon == "NULL"] <- NA
dt_vers <- data.table::fread(here::here("data", "en_quete_de_vers_export_donnes_a_plat.csv"), encoding = "Latin-1") %>%
  rename(session_id = participation_id,
         session_date = date_debut,
         user_id = participant_id,
         taxon_count = abondance) %>%
  tidyr::separate_wider_delim(site_coordonnees_GPS, delim = ", ", names = c("latitude", "longitude"))
dt_vers$taxon[dt_vers$taxon == "NULL"] <- NA
