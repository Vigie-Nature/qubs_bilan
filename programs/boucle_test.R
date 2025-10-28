library(here)
library(quarto)

quarto::quarto_render(input =  here::here("test.qmd"),
                      output_file = "index.html")

file.rename("index.html", file.path("docs", "index.html"))
