# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed. # nolint

# Set target options:
tar_option_set(
  packages = c("here", "arrow", "dplyr") # packages that your targets need to run
  # format = "parquet" # default storage format
  # Set other options as needed.
)

# Update used packaged for renv
tar_renv()

# tar_make_clustermq() configuration (okay to leave alone):
options(clustermq.scheduler = "multicore")

# tar_make_future() configuration (okay to leave alone):
# Install packages {{future}}, {{future.callr}}, and {{future.batchtools}} to allow use_targets() to configure tar_make_future() options.

# Run the R scripts in the R/ folder:
tar_source()

# Replace the target list below with your own:
list(
  # Reads the raw strokes data into the pipeline
  tar_target(strokes_data_file, here("data/swgt-data.csv.gz"), format = "file"),
  tar_target(raw_strokes_data, read_csv_arrow(strokes_data_file), format = "parquet"),

  # Clean data
  tar_target(cleaned_strokes_data, clean_strokes_data(raw_strokes_data)),

  # Create classification of competition levels
  tar_target(comp_levels, create_comp_levels(cleaned_strokes_data))

)
