library(here)
library(quarto)

quarto::quarto_render(input =  here::here("test.qmd"),
                      output_file = "test.html")

file.rename("test.html", file.path("docs", "test.html"))
