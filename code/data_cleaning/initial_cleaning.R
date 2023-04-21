# Read in libraries
library(tidyverse)

# Read in bechdel data
bechdel_films <- read.csv("../../data/raw/movies.csv") %>%
  # Drop unnecessary columns
  select(-c(test, code, period.code, decade.code)) %>%
  rename(
    title_id = imdb,
    test = clean_test,
    budget_2013_infl = budget_2013.,
    domgross_2013_infl = domgross_2013.,
    intgross_2013_infl = intgross_2013.,
    bechdel_pass = binary
  ) %>%
  # Redefine bechdel_pass to be TRUE or FALSE
  mutate(
    bechdel_pass = ifelse(bechdel_pass == "PASS", TRUE, FALSE)
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
    c(title_id, primaryTitle, runtimeMinutes, genres)
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
  right_join(bechdel_films %>% select(title_id), by = 'title_id') %>%
  # Split name_ids by comma where applicable and generate new rows
  separate_rows(name_id, sep = ",")
  

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
  # Unpack genres column into dummy variables
  # https://stackoverflow.com/a/72638134/17331025
  separate_rows(genres, sep = ",") %>%
  mutate(value = 1) %>%
  pivot_wider(
    names_from = genres,
    values_from = value,
    values_fill = 0
  ) %>%
  # Rename dummy variables
  rename(
    genreComedy = Comedy,
    genreAction = Action,
    genreCrime = Crime,
    genreSciFi = `Sci-Fi`,
    genreBiography = Biography,
    genreDrama = Drama,
    genreHistory = History,
    genreThriller = Thriller,
    genreSport = Sport,
    genreFantasy = Fantasy,
    genreRomance = Romance,
    genreAdventure = Adventure,
    genreHorror = Horror,
    genreAnimation = Animation,
    genreMystery = Mystery,
    genreFamily = `Family`,
    genreWar = War,
    genreWestern = Western,
    genreMusical = Musical,
    genreMusic = Music,
    genreDocumentary = Documentary,
    genreUndefined = `NA`,
    genreAdult = Adult
  ) %>%
  # Reorder columns
  select(
    title_id, primaryTitle, year, name_id, primaryName, job_title, budget, 
    domgross, intgross, budget_2013_infl, domgross_2013_infl, 
    intgross_2013_infl, runtimeMinutes, averageRating, 
    numVotes, genreComedy, genreAction, genreCrime, genreSciFi, genreBiography,
    genreDrama, genreHistory, genreThriller, genreSport, genreFantasy, 
    genreRomance, genreAdventure, genreHorror, genreAnimation, genreMystery,
    genreFamily, genreWar, genreWestern, genreMusical, genreMusic,
    genreDocumentary, genreUndefined, genreAdult, test, bechdel_pass
  ) %>%
  # Drop na from name_id column
  drop_na(name_id)

# Write new csv
write.csv(
  films, "../../data/modified/castcrew_ungendered.csv", row.names = FALSE
)




  

