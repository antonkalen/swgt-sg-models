
# Load packages to run pipeline -------------------------------------------

library(targets)


# Set options -------------------------------------------------------------

tar_option_set(
  packages = c("here", "arrow", "dplyr", "rsample"),
  format = "parquet",
  resources = tar_resources(
    parquet =  tar_resources_parquet(compression = "gzip")
  ),
  seed = 746
)


# Source functions in R/ --------------------------------------------------

tar_source()



# List of targets ---------------------------------------------------------

list(
  ## Reads the raw strokes data into the pipeline -------------------------
  tar_target(strokes_data_file, here("data/swgt-data.csv.gz"), format = "file"),
  tar_target(raw_strokes_data, read_csv_arrow(strokes_data_file)),

  ## Clean data -----------------------------------------------------------
  tar_target(cleaned_strokes_data, clean_strokes_data(raw_strokes_data)),

  ## Classify competition levels and merge back with clean data -----------
  tar_target(comp_levels, create_comp_levels(cleaned_strokes_data)),
  tar_target(
    strokes_data_comp_level,
    left_join(comp_levels, cleaned_strokes_data, by = join_by(user_pk, season))
  ),

  # Split training/validation ---------------------------------------------
  tar_target(strokes_data_binned, bin_strokes_data(strokes_data_comp_level)),
  tar_target(
    train_test_split,
    initial_split(
      strokes_data_binned,
      prop = 3/4,
      strata = strata,
      pool = 0.05
    ),
    format = "qs"
  ),
  tar_target(training_data, training(train_test_split)),
  tar_target(testing_data, testing(train_test_split))
)
