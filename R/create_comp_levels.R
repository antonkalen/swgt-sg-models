create_comp_levels <- function(data) {

  # Summarise data to one row per athlete and season
  summarised_data <- data |>
    summarise(
      nr_rounds = n_distinct(round_pk),
      score_sg_diff = mean(score_sg_diff, na.rm = TRUE),
      .by = c(user_pk, sex, season, age)
    )

  # Filter out problematic cases
  summarised_data |> filter(nr_rounds >= 10, age > 10)

  # Categorise athletes
  summarised_data |>
    mutate(
      score_sg_diff = winsorise(score_sg_diff, probs = c(0.025, 0.975)),
      comp_level = cut(score_sg_diff, 4, labels = FALSE),
      .by = sex
    ) |>
    arrange(sex, comp_level) |>
    transmute(
      user_pk,
      season,
      comp_level = factor(paste(sex, comp_level))
    )

}

# Helper function to winsorise data ---------------------------------------

winsorise <- function(x, probs = c(0.05, 0.95), na.rm = FALSE, type = 7) {
  xq <- quantile(x = x, probs = probs, na.rm = na.rm, type = type)
  minval <- xq[1L]
  maxval <- xq[2L]
  x[x < minval] <- minval
  x[x > maxval] <- maxval
  return(x)
}
