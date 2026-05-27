library(here)
library(dplyr)
library(ggplot2)
library(sf)
library(tmap)
library(DT)
library(reshape2)
library(data.table)

#Add new .env variables (access to database)
readRenviron(here::here(".env"))
#load functions to fetch data
source(here::here("functions", "function_import_from_mosaic.R"))
source(here::here("functions", "function_encoding_utf8.R"))

## data noctambules
query <- read_sql_query(here::here("sql", "export_a_plat_noctambules.sql"))
dt_noctambules <- import_from_mosaic(query,
                                     database_name = "qubs",
                                     force_UTF8 = TRUE)
## data escargots
query <- read_sql_query(here::here("sql", "export_a_plat_escargots.sql"))
dt_escargots <- import_from_mosaic(query,
                                   database_name = "qubs",
                                   force_UTF8 = TRUE)
## data aspifaune
query <- read_sql_query(here::here("sql", "export_a_plat_aspifaune.sql"))
dt_aspifaune <- import_from_mosaic(query,
                                   database_name = "qubs",
                                   force_UTF8 = TRUE)
## data vers de terre
query <- read_sql_query(here::here("sql", "export_a_plat_vers_de_terre.sql"))
dt_vers <- import_from_mosaic(query,
                              database_name = "qubs",
                              force_UTF8 = TRUE)
#identifier les champs communs aux differents dataframe
champs_communs <- Reduce(intersect, list(colnames(dt_aspifaune),
                                         colnames(dt_noctambules),
                                         colnames(dt_escargots),
                                         colnames(dt_vers)))
#rbind des donnees des 4 protocoles
dt_qubs <- rbind(dt_aspifaune %>% select(all_of(champs_communs)),
                 dt_noctambules %>% select(all_of(champs_communs)),
                 dt_escargots %>% select(all_of(champs_communs)),
                 dt_vers %>% select(all_of(champs_communs)))

# Ajouter la taxonomie et les regroupements d'especes
taxo <- data.table::fread(here::here("data", "thesaurus_V1V2.csv")) %>% 
  select(`Nom français V1`, `Regroupement2a`, `Regroupement2b`, `Regroupement3`)
colnames(taxo) <- c("taxon", "Regroupement2a", "Regroupement2b", "Regroupement3")

dt_qubs <- dt_qubs %>% left_join(taxo, by = "taxon")


#coordonnees sites
coord_qubs <- dt_qubs %>%
  select(session_id, latitude, longitude) %>%
  distinct() %>%
  sf::st_as_sf(coords = c("longitude", 
                          "latitude"),
               crs = 4326) %>%
  st_transform(crs = 2154)



#shapefile de la France pour carto
communes <- sf::read_sf(here::here("maps", "communes_france.geojson"))
st_crs(communes) <- 2154

liste_communes <- c("Ahuy", "Bressey-sur-Tille", "Bretenière", "Chenôve",
                    "Chevigny-Saint-Sauveur", "Corcelles-les-Monts", "Daix",
                    "Dijon", "Fénay", "Flavignerot", "Fontaine-lès-Dijon",
                    "Hauteville-lès-Dijon", "Longvic", "Magny-sur-Tille",
                    "Marsannay-la-Côte", "Neuilly-Crimolois",
                    "Ouges", "Perrigny-lès-Dijon", "Plombières-lès-Dijon","Quetigny",
                    "Saint-Apollinaire", "Sennecey-lès-Dijon", "Talant")
communes <- communes %>% filter(libgeo %in% liste_communes & dep == 21)

agregat.polygon <- communes %>% summarise(geometry = sf::st_union(communes)) 
dt_qubs_agregat <- sf::st_filter(coord_qubs, agregat.polygon)


#on applique le filtre sur les participations dans la surface considérée
dt_qubs <- dt_qubs %>% filter(session_id %in% dt_qubs_agregat$session_id)
dt_noctambules <- dt_noctambules %>% 
  filter(session_id %in% dt_qubs_agregat$session_id)
dt_aspifaune <- dt_aspifaune %>% 
  filter(session_id %in% dt_qubs_agregat$session_id)
dt_escargots <- dt_escargots %>% 
  filter(session_id %in% dt_qubs_agregat$session_id)
dt_vers <- dt_vers %>%
  filter(session_id %in% dt_qubs_agregat$session_id)

## Palettes graphiques

palette_qubs <- c("#ff8800",
                  "#3c24a6",
                  "#50FFB1",
                  "#aa1256",
                  "#2baca6",
                  "#1a702d",
                  "#0f0608")

palette_camemberts <- c("Les Insectes" = "#377eb8",
                        "Les Gastéropodes" = "#e41a1c",
                        "Les Collemboles et diploures" = "#4daf4a",
                        "Arachnides" = "#984ea3",
                        "Les Crustacés terrestres" = "#ff7f00",
                        "Les Vers sens large" = "#ffff33",
                        "Les Milles-pattes" = "#a25427",
                        "Les Escargots" = "#43185d",
                        "Les Limaces" = "#c99de5")

dir.create(here::here("reporting"))

readr::write_excel_csv2(dt_qubs, "qubs_dijon_20250226.csv")
