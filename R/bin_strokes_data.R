bin_strokes_data <- function(data) {
  data |>
    mutate(
      bin = case_when(
        # Tee
        sex == "Men" & from_location == "Tee" & from_distance < 80 ~ 0,
        sex == "Men" & from_location == "Tee" & from_distance >= 560 ~ 560,
        sex == "Women" & from_location == "Tee" & from_distance < 80 ~ 0,
        sex == "Women" & from_location == "Tee" & from_distance >= 520 ~ 520,
        from_location == "Tee" ~ floor(from_distance / 20) * 20,

        # Fairway
        from_location == "Fairway" & from_distance < 20 ~ floor(from_distance / 5) * 5,
        sex == "Men" & from_location == "Fairway" & from_distance >= 330 ~ 330,
        sex == "Women" & from_location == "Fairway" & from_distance >= 310 ~ 310,
        from_location == "Fairway" ~ floor(from_distance / 10) * 10,

        # Ruff
        from_location == "Ruff" & from_distance < 20 ~ floor(from_distance / 5) * 5,
        sex == "Men" & from_location == "Ruff" & from_distance >= 370 ~ 370,
        sex == "Women" & from_location == "Ruff" & from_distance >= 310 ~ 310,
        from_location == "Ruff" ~ floor(from_distance / 10) * 10,

        # Bunker
        from_location == "Bunker" & from_distance < 20 ~ floor(from_distance / 10) * 10,
        sex == "Men" & from_location == "Bunker" & from_distance >= 280 ~ 280,
        sex == "Women" & from_location == "Bunker" & from_distance >= 220 ~ 220,
        from_location == "Bunker" ~ floor(from_distance / 20) * 20,

        # Green
        from_location == "Green" & from_distance < 5 ~ floor(from_distance / .5) * .5,
        from_location == "Green" & from_distance < 20 ~ floor(from_distance / 1) * 1,
        sex == "Men" & from_location == "Green" & from_distance >= 30 ~ 30,
        sex == "Women" & from_location == "Green" & from_distance >= 30 ~ 30,
        from_location == "Green" ~ floor(from_distance / 5) * 5
      ),
      strata = paste(comp_level, from_location, bin)
    )
}
