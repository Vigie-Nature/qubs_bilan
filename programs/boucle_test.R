library(here)
library(quarto)

quarto::quarto_render(input =  here::here("test.qmd"), output_file = here::here("docs", "test.html"))
