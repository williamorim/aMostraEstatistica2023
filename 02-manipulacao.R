url <- "https://raw.githubusercontent.com/williamorim/brasileirao/master/data-raw/csv/matches.csv"
dados <- readr::read_csv(url)
# dados <- brasileirao::matches

# goleada: placares com a diferenca de 3 gols ou mais

dados |>
  tidyr::separate_wider_delim(
    cols = score,
    delim = "x",
    names = c("gols_mandante", "gols_visitante"),
    cols_remove = FALSE
  ) |>
  dplyr::mutate(
    gols_mandante = as.numeric(gols_mandante),
    gols_visitante = as.numeric(gols_visitante),
    flag_goleada = abs(gols_mandante - gols_visitante) >= 3,
    perdedor = dplyr::case_when(
      gols_mandante > gols_visitante ~ away,
      gols_visitante > gols_mandante ~ home,
      TRUE ~ NA_character_
    )
  ) |>
  dplyr::filter(flag_goleada) |>
  dplyr::select(
    season,
    date,
    home,
    score,
    away,
    perdedor
  ) |>
  readr::write_rds("tab_goleadas.rds")

