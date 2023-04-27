clean_strokes_data <- function(data) {

  cleaned_names <- janitor::clean_names(data)

  calculated_data <- cleaned_names |>
    mutate(
      season = lubridate::year(round_date),
      hole_length = if_else(from_location == "Tee", hole_length, NA),

      # Change hole length into meters
      across(c(hole_length, from_distance, result_distance), \(x) x / 100),

      # Fix too short hole lengths
      across(c(hole_length, from_distance), ~ fix_short_length(.x, hole_par)),

      # # Fix too long hole length and shot distances
      # # (We expect everything over 900 to have a 0 too much.
      # #  Checked manually agains par of the holes)
      # # Do this iteratively to catch with two 0 too much and so forth.
      across(c(hole_length, from_distance, result_distance), ~ fix_long_length(.x)),

      # Estimate drive length
      drive_length = if_else(
        from_location == "Tee" & is.na(shot_type),
        from_distance - result_distance,
        NA
      ),
      drive_length = if_else(drive_length <= 0, NA, drive_length),

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

lengthen <- function(length, par) {
  if_else(
    par == 3 & length < 20 | par == 4 & length < 40 | par >= 5 & length < 100,
    length * 10,
    length
  )
}

fix_short_length <- function(length, par) {
  length_it1 <- lengthen(length, par)
  length_it2 <- lengthen(length_it1, par)
  length_it3 <- lengthen(length_it2, par)
  length_it4 <- lengthen(length_it3, par)
  length_it4
}

# Create function for shortening
fix_long_length <- function(length) {
  length_it1 <- if_else(length >= 900, length / 10, length)
  length_it2 <- if_else(length_it1 >= 1000, length_it1 / 10, length_it1)
  length_it3 <- if_else(length_it2 >= 1000, length_it2 / 10, length_it2)
  length_it4 <- if_else(length_it3 >= 1000, length_it3 / 10, length_it3)
  length_it4
}
