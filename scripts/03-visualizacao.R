tab_goleadas <- readRDS("tab_goleadas.rds") |>
  tibble::as_tibble()

tab_goleadas |>
  dplyr::count(perdedor) |>
  dplyr::slice_max(n, n = 20) |>
  dplyr::mutate(
    perdedor = forcats::fct_reorder(perdedor, n)
  ) |>
  ggplot2::ggplot(ggplot2::aes(y = perdedor, x = n)) +
  ggplot2::geom_col() +
  ggplot2::geom_label(ggplot2::aes(label = n)) +
  ggplot2::geom_tile()

top_20 <- tab_goleadas |>
  dplyr::count(perdedor) |>
  dplyr::slice_max(n, n = 20)

tab_grafico <- tab_goleadas |>
  dplyr::select(
    perdedor,
    date,
    home,
    score,
    away
  ) |>
  dplyr::group_by(perdedor) |>
  dplyr::mutate(
    contagem = dplyr::row_number(),
    placar = glue::glue(
      "{home} {score} {away}"
    ),
    n = max(contagem)
  ) |>
  dplyr::ungroup() |>
  dplyr::arrange(n, perdedor, date) |>
  dplyr::semi_join(
    top_20,
    by = "perdedor"
  )

tab_grafico |>
  echarts4r::e_chart(x = perdedor) |>
  echarts4r::e_scatter(
    serie = contagem,
    dimensions = c("date", "placar")
  ) |>
  echarts4r::e_legend(show = FALSE) |>
  echarts4r::e_flip_coords() |>
  echarts4r::e_tooltip()

# -------------------------------------------------------------------------

tab_grafico <- tab_goleadas |>
  dplyr::select(
    perdedor,
    date,
    home,
    score,
    away
  ) |>
  dplyr::group_by(perdedor) |>
  dplyr::mutate(
    contagem = dplyr::row_number(),
    placar = glue::glue(
      "{home} {score} {away}"
    ),
    n = max(contagem),
    date = format(date, "%d/%m/%Y"),
    serie = perdedor
  ) |>
  dplyr::ungroup() |>
  dplyr::arrange(n, perdedor, date) |>
  dplyr::semi_join(
    top_20,
    by = "perdedor"
  ) |>
  dplyr::left_join(
    dplyr::select(brasileirao::teams, team, cor = color1),
    by = c("perdedor" = "team")
  ) |>
  dplyr::select(
    serie,
    cor,
    contagem,
    perdedor,
    date,
    placar
  ) |>
  tidyr::nest(data = -c(serie, cor)) |>
  dplyr::mutate(
    cor = dplyr::case_when(
      serie == "Vasco da Gama" ~ "#000000",
      serie == "Flamengo" ~ "#b92218",
      serie == "Athletico PR" ~ "#a50e15",
      serie == "Fluminense" ~ "#7a0423",
      serie == "Ponte Preta" ~ "#000000",
      serie == "Ponte Preta" ~ "#d1171f",
      serie == "Corinthians" ~ "#000000",
      serie == "Vitória" ~ "#f70f02",
      serie == "São Paulo" ~ "#cd0a12",
      serie == "Bahia" ~ "#2367a8",
      TRUE ~ cor
    )
  )


echarts4r::e_charts() |>
  echarts4r::e_list(
    list(
      xAxis = list(
        type = "value"
      ),
      yAxis = list(
        type = "category"
      ),
      series = purrr::map(
        tab_grafico$serie,
        ~ list(
          type = "scatter",
          data = tab_grafico |>
            dplyr::filter(serie == .x) |>
            tidyr::unnest(cols = data) |>
            dplyr::select(-serie, -cor) |>
            unname() |>
            purrr::transpose()
        )
      ),
      tooltip = list(
        show = TRUE,
        formatter = htmlwidgets::JS(
          "function(params) {
            var text = params.value[2] + '<br>';
            text += params.value[3];
            return text;
          }
          "
        )
      ),
      color = tab_grafico$cor
    )
  )


