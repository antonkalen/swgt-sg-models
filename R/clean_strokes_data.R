clean_strokes_data <- function(data) {

  cleaned_names <- janitor::clean_names(data)

  calculated_data <- cleaned_names |>
    # Remove penalty shots recorded as row
    tidyr::drop_na(from_location) |>
    mutate(
      season = lubridate::year(round_date),

      # Remove negative distances
      from_distance = abs(from_distance),

      # Convert distance to meters
      from_distance = from_distance / 100,

      # fix too short and long distances
      FromDistance = lengthen(from_distance, hole_par, from_location),
      FromDistance = shorten(from_distance, hole_par, from_location),

      # Update result distance to match next shots from distance
      ResultDistance = if_else(result_location == "Hole", 0.0, lead(from_distance)),

      # Calculate score SG difference
      hole_score_diff = hole_score - hole_par,
      score_sg_diff = hole_score_diff - sg_net
    )


  cleaned_data <- calculated_data |>
    mutate(
      sex = factor(sex, levels = c("m", "w"), labels = c("Men", "Women")),
      from_location = factor(from_location),
      result_location = factor(result_location),
      shot_type = factor(shot_type),
      penalty_reason = factor(penalty_reason)
    )

  cleaned_data
}




# Helper functions --------------------------------------------------------

shorten <- function(length, par, location) {
  x <- case_when(
    location == "Tee" & length > 900 ~ length / 10,
    location %in% c("Ruff", "Fairway", "Bunker") & length > 600 ~ length / 10,
    location == "Green" & length > 50 ~ length / 10,
    TRUE ~ length
  )

  if (!all(x == length)) {
    shorten(x, par, location)
  } else x
}

lengthen <- function(length, par, location) {
  x <- case_when(
    location == "Tee" & par == 3 & length < 20 ~ length * 10,
    location == "Tee" & par == 4 & length < 40 ~ length * 10,
    location == "Tee" & par >= 5 & length < 100 ~ length * 10,
    location %in% c("Ruff", "Fairway", "Bunker") & length < 2 ~ length * 10,
    TRUE ~ length
  )

  if (!all(x == length)) {
    lengthen(x, par, location)
  } else x
}


