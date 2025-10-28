library(here)
library(quarto)

quarto::quarto_render(here::here("test.qmd"), output_file = "docs/test.html")
