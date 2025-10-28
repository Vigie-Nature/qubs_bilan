library(here)
library(quarto)

quarto::quarto_render(here::here("programs", "test.qmd"))
