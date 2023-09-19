tab_goleadas <- readr::read_rds("tab_goleadas.rds")

tab_goleadas |>
  dplyr::count(perdedor, sort = TRUE, name = "num_goleadas") |>
  dplyr::slice_max(
    order_by = num_goleadas,
    n = 10
  ) |>
  dplyr::mutate(
    perdedor = forcats::fct_reorder(perdedor, num_goleadas)
  ) |>
  ggplot2::ggplot(ggplot2::aes(x = num_goleadas, y = perdedor)) +
  ggplot2::geom_col() +
  ggplot2::geom_label(ggplot2::aes(label = num_goleadas))


# -------------------------------------------------------------------------

# Echarts

top_10 <- tab_goleadas |>
  dplyr::count(perdedor) |>
  dplyr::slice_max(order_by = n, n = 10)

tab_grafico <- tab_goleadas |>
  dplyr::semi_join(
    top_10,
    by = "perdedor"
  ) |>
  dplyr::arrange(perdedor, date) |>
  dplyr::group_by(perdedor) |>
  dplyr::mutate(
    num_goleada = dplyr::row_number(),
    total_goleadas = dplyr::n()
  ) |>
  dplyr::ungroup() |>
  dplyr::arrange(
    total_goleadas, perdedor, date
  )


tab_grafico |>
  echarts4r::e_charts(x = perdedor) |>
  echarts4r::e_scatter(serie = num_goleada) |>
  echarts4r::e_flip_coords() |>
  echarts4r::e_tooltip()


# -------------------------------------------------------------------------


top_20 <- tab_goleadas |>
  dplyr::count(perdedor) |>
  dplyr::slice_max(order_by = n, n = 20)

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












