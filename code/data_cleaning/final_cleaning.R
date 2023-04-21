# Read in libraries
library(tidyverse)

# Read in data
films_gendered <- read.csv("../../data/modified/castcrew_gendered.csv") %>%
  # Drop first name column
  select(-firstname) %>%
  # Drop rows with job_title composer, cinematographer, production designer,
  # self, and archive footage
  filter(
    job_title != "composer" & job_title != "cinematographer" &
      job_title != "production_designer" & job_title != "self" &
      job_title != "archive_footage" & job_title != "editor"
  ) %>%
  mutate(
    # Quantify predicted gender to generate percents of females in production
    gender_pred_female = ifelse(
      gender_pred == "female" | gender_pred == "mostly_female",
      yes = 1,
      no = 0
    ),
    # Consolidate actors and actresses in job_title column into "cast"
    job_title = paste0(job_title, "s"),
    job_title = ifelse(
      job_title == "actors" | job_title == "actresss",
      yes = "castmembers",
      no = job_title
    )
  ) %>%
  # Group by movie and job_title
  group_by(title_id, job_title) %>%
  # Calculate num females/grp, grp totals, and pct of females/grp
  mutate(
    num_female = sum(gender_pred_female),
    `total` = n(),
    pct_female = num_female / `total`
  ) %>%
  # Ungroup
  ungroup() %>%
  # Drop all unique individual/person data so movie job groups are constant
  select(-c(name_id, primaryName, gender_pred, gender_pred_female)) %>%
  # Drop duplicates so each row becomes movie job group
  distinct() %>%
  # Pivot wider so job groups become columns and each row is a movie
  pivot_wider(
    names_from = job_title,
    values_from = c(num_female, `total`, pct_female)
  ) %>%
  # Move test and bechdel_pass columns to back
  relocate(c(test, bechdel_pass), .after = last_col()) %>%
  # Reorder job group columns
  relocate(
    c(
      num_female_producers, total_producers, pct_female_producers,
      num_female_castmembers, total_castmembers, pct_female_castmembers,
      num_female_directors, total_directors, pct_female_directors,
      num_female_writers, total_writers, pct_female_writers,
    ),
    .after = genreAdult
  )

# Write to csv
write.csv(
  films_gendered, "../../data/modified/films_gendered.csv", row.names = FALSE
)
