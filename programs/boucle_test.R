# Librairies
library(dplyr)
library(here)
library(quarto)
library(stringr)

# Fonctions
if (Sys.getenv("CI") != "true") {
  readRenviron(".env")
}

quarto::quarto_render(input =  here::here("bilan_qubs.qmd"),
                      output_file = "index.html")

file.rename("index.html", file.path("docs", "index.html"))
