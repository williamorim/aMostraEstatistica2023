# Dados 2003 a 2019

# http://www.chancedegol.com.br/br19.htm

url <- "http://www.chancedegol.com.br/br19.htm"

url |>
  httr::GET() |>
  httr::content(encoding = "latin1") |>
  xml2::xml_find_first(".//table") |>
  rvest::html_table(header = TRUE) |>
  janitor::clean_names() |>
  dplyr::mutate(
    season = 2019,
    data = as.Date(data, format = "%d/%m/%Y")
  ) |>
  dplyr::select(
    season,
    date = data,
    home = mandante,
    score = x,
    away = visitante
  )


url |>
  httr::GET() |>
  httr::content(encoding = "latin1") |>
  xml2::xml_find_first(".//table") |>
  rvest::html_table(header = TRUE) |>
  janitor::clean_names() |>
  dplyr::mutate(
    season = 2019,
    data = as.Date(data, format = "%d/%m/%Y")
  ) |>
  dplyr::select(
    season,
    date = data,
    home = mandante,
    score = x,
    away = visitante
  )

# Dados de 2020 em diante

url <- "https://api.globoesporte.globo.com/tabela/d1a37fa4-e948-43a6-ba53-ab24ab3a45b1/fase/fase-unica-campeonato-brasileiro-2023/rodada/10/jogos/"
res <- httr::GET(url)

tab <- res |>
  httr::content(type = "text/json", encoding = "latin1") |>
  jsonlite::fromJSON() |>
  janitor::clean_names() |>
  tibble::as_tibble()

tab |>
  dplyr::mutate(
    dplyr::across(
      .cols = dplyr::starts_with("placar_oficial"),
      ~ .x |> as.character() |> tidyr::replace_na("")
    ),
    season = 2023,
    date = as.Date(data_realizacao),
    home = equipes$mandante$nome_popular,
    away = equipes$visitante$nome_popular,
    score = paste(
      placar_oficial_mandante,
      placar_oficial_visitante,
      sep = "x"
    )
  ) |>
  dplyr::select(
    season,
    date,
    home,
    score,
    away
  )


# Script completo
# https://github.com/williamorim/brasileirao/blob/master/data-raw/scraping_matches.R

# remotes::install_github("williamorim/brasileirao")
