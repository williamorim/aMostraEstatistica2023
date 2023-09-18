url <- "https://raw.githubusercontent.com/williamorim/brasileirao/master/data-raw/csv/matches.csv"

dados <- readr::read_csv(url)

dados |>
  tidyr::separate_wider_delim(
    cols = score,
    delim = "x",
    names = c("gols_mandante", "gols_visitante"),
    cols_remove = FALSE
  ) |>
  dplyr::mutate(
    dplyr::across(
      c(gols_mandante, gols_visitante),
      as.numeric
    ),
    diferenca_gols = gols_mandante - gols_visitante,
    perdedor = dplyr::case_when(
      diferenca_gols > 0 ~ away,
      diferenca_gols < 0 ~ home,
      TRUE ~ NA
    ),
    flag_goleada = abs(diferenca_gols) >= 3
  ) |>
  dplyr::filter(flag_goleada) |>
  saveRDS("tab_goleadas.rds")


