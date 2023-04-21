# Read in libraries
library(tidyverse)

# Read in bechdel data
bechdel_films <- read.csv("../../data/raw/movies.csv") %>%
  rename(
    title_id = imdb
  )

# Read in IMDb data
# Film titles
title.basics <- read.csv(
  "../../data/raw/imdb/title.basics.tsv", sep = '\t'
) %>%
  # Rename columns
  rename(
    title_id = tconst
  ) %>%
  # Drop unnecessary columns
  select(
    c(title_id, primaryTitle, isAdult, runtimeMinutes, genres)
  )

# Principal cast/crew
title.principals <- read.csv(
  "../../data/raw/imdb/title.principals.tsv", sep = '\t'
) %>%
  # Rename columns
  rename(
    title_id = tconst,
    name_id = nconst
  ) %>%
  # Drop unnecessary columns
  select(-c(characters, ordering, job)) %>%
  # Keep only films that are in main dataset
  right_join(bechdel_films %>% select(title_id), by = 'title_id')

# All cast/crew
title.crew <- read.csv(
  "../../data/raw/imdb/title.crew.tsv", sep = '\t'
) %>%
  # Rename columns
  rename(
    title_id = tconst,
    director = directors,
    writer = writers
  ) %>%
  # Pivot to longer
  pivot_longer(!title_id, names_to = "job_title", values_to = "name_id") %>%
  # Filter out missing
  filter(name_id != "\\N") %>%
  # Keep only films that are in main dataset
  right_join(bechdel_films %>% select(title_id), by = 'title_id')

# Cast/crew names
name.basics <- read.csv(
  "../../data/raw/imdb/name.basics.tsv", sep = '\t'
) %>%
  # Rename columns
  rename(
    name_id = nconst
  ) %>%
  # Drop unnecessary columns
  select(-c(birthYear, deathYear, primaryProfession, knownForTitles))

# Film user ratings
title.ratings <- read.csv(
  "../../data/raw/imdb/title.ratings.tsv", sep = '\t'
) %>%
  # Rename columns
  rename(
    title_id = tconst
  )

# Clean cast/crew dataset
films.castcrew <- title.principals %>%
  # Rename columns to match title.crew
  rename(
    job_title = category
  ) %>%
  # Combine datasets
  rbind(title.crew) %>%
  # Drop duplicate rows
  distinct() %>%
  # Add names
  left_join(name.basics, by = 'name_id') 


# Join all data onto bechdel films
films <- bechdel_films %>%
  # Join general film data (title.basics) onto main dataset
  left_join(title.basics, by = 'title_id') %>%
  # Join ratings onto main dataset
  left_join(title.ratings, by = 'title_id') %>%
  # Join cast/crew/actors
  right_join(
    films.castcrew,
    by = 'title_id'
  ) %>%
  # Reorder columns
  select(
    title_id, primaryTitle, year, name_id, primaryName, job_title, 
    budget_2013., domgross_2013., intgross_2013., isAdult, runtimeMinutes, 
    genres, averageRating, numVotes, test, clean_test, binary
  )

# Write new csv
write.csv(films, "../../data/modified/films_ungendered.csv")




  

