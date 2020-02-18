##########################################################################################
#
#   Program Name: Week_1_Tutorial.R
#   Purpose: Data wrangling in R
#   Author: ...
#   Description: Tutorial exercises for data wrangling in R
#   Usage: R training tutorials
#
##########################################################################################
#
#   Version 0.1      Date 24-12-2019        Description
#
##########################################################################################

# Go to https://datasets.imdbws.com/ and download the following files
# - title.basics.tsv.gz
# - name.basics.tsv.gz
# - title.ratings.tsv.gz
# - title.principals.tsv.gz
# Create a folder data and store them inside this folder

# Import the necessary libraries
library(dplyr)

# For this tutorial, we use a movie database from IMDB. The datasets we will need provide
# information about titles, actors and ratings. The following code will read the data into
# memory, this may take a while
options(stringsAsFactors = FALSE)
titles <- read.csv(gzfile("data/title.basics.tsv.gz"), sep = "\t")
names <- read.csv(gzfile("data/name.basics.tsv.gz"), sep = "\t")
ratings <- read.csv(gzfile("data/title.ratings.tsv.gz"), sep = "\t")
principals <- read.csv(gzfile("data/title.principals.tsv.gz"), sep = "\t")

# We only want to consider movies, so we select only movies from the titles dataset
titles <- titles[which(titles$titleType == "movie"),]

# Furthermove, we only want to consider actors or actresses in a movie (no crew)
principals <- principals[which(principals$category == "actor" | principals$category == "actress"),]

# A closer look at this dataset shows that there are quite some duplicated. We removes the dupicates
# by applying the duplicated() function
principals <- principals[!duplicated(principals),]

# The data contains two important keys on which the datasets can be merged: nconst (for
# actors/actresses) and tconst (for movie titles). We merge the ratings to the titles 
# dataset
titles <- merge(titles, ratings, by = "tconst", all.x = TRUE)

# We can remove the ratings dataset safely because all information we need is contained
# in titles now
rm(ratings)

# What is the best rated movie of 1974?
titles %>%
  dplyr::group_by(startYear) %>%
  dplyr::top_n(n = 1, wt = averageRating) %>%
  dplyr::filter(startYear == "1974")

# Does the movie seem familiar? Nope, to me neither. If we have a closer look at the movie
# we see it only has five votes, so probably the producer of the movie let his or her 
# family vote to get a top rating. If we restrict the number of votes to be at least 500,
# we will probably find a more familiar movie
best_movie_1974 <- titles %>%
  dplyr::filter(numVotes >= 500) %>%
  dplyr::group_by(startYear) %>%
  dplyr::top_n(n = 1, wt = averageRating) %>%
  dplyr::filter(startYear == "1974")
best_movie_1974

# That seems more familiar to me. What are the main actors in this movie?
godfather_actors_keys <- principals[which(principals$tconst == best_movie_1974$tconst),"nconst"]
names[which(names$nconst %in% godfather_actors_keys),"primaryName"]

# Use this link for a quick overview of the possibilities with dplyr
# https://rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf
# Below are some more questions we can answer during our tutorial or later. For all questions, we
# will only consider movies that have at least 500 votes (hence we can safely subset the data)
titles <- subset(titles, numVotes >= 500)

# To speed up running times, we want principals to only contain movies that are in titles
principals <- subset(principals, tconst %in% titles$tconst)

# Also for names, we only want names that appear in principals
names <- subset(names, nconst %in% principals$nconst)

# 1. What movie has the highest number of votes?

# 2. How many movies are in the dataset that are released in 1988?

# 3. How many movies have "Spartacus" in their title

# 4. What is the main actor in the Spartacus movie released in 1960 (The one called Spartacus)

# 5. What is his age? (He is born on the 9th of December)

# 6. What is the percentage of actors in movies in 1934?

# 7. In what year was the percentage of actors in movies the lowest?

# 8. In what movies does Leonardo DiCaprio appear?

# 9. What is the best rated movie starring Leonardo DiCaprio?

# 10. With whom did Leonardo DiCaprio feature most often in a movie?

# 11. How many movies have "joker" in their title?

# 12. What are the top 10 rated movies from 2007?

# 13. What is the longest movie that featured Uma Thurman?