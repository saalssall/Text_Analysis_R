# Load tidyverse and the tweets dataset
library(tidyverse)
tweet_data <- read_csv("Tweets.csv")
glimpse(tweet_data)

# Build the complaint label (negative sentiment = complaint)
tweet_data <- tweet_data %>%
  mutate(complaint_label = if_else(airline_sentiment == "negative",
                                   "Complaint", "Non-complaint"))

# 1. Data cleaning

# Drop columns with lots of NAs
tweet_data <- tweet_data %>%
  select(-airline_sentiment_gold, -negativereason_gold, -tweet_coord)

# Negativereason is empty for every non-negative tweet, so the value isn't unknown, it just doesn't apply
tweet_data <- tweet_data %>%
  mutate(negativereason = replace_na(negativereason, "Not applicable"))

# Replacing NAs in tweet location and user timezone with Unknown
tweet_data <- tweet_data %>%
  mutate(
    tweet_location = replace_na(tweet_location, "Unknown"),
    user_timezone  = replace_na(user_timezone, "Unknown")
  )

# Impute NAs in negativereason_confidence with the median value
tweet_data <- tweet_data %>%
  mutate(negativereason_confidence =
           replace_na(negativereason_confidence,
                      median(negativereason_confidence, na.rm = TRUE)))

# Total number of missing values in the each column
colSums(is.na(tweet_data))

#Number of missing locations
sum(is.na(tweet_data$tweet_location))

# The number of complaints vs non-complaints
tweet_data %>% count(complaint_label)

# Re-tweets by complaint status
tweet_data %>%
  group_by(complaint_label) %>%
  summarize(
    avg_retweets = mean(retweet_count),
    min_retweets = min(retweet_count),
    max_retweets = max(retweet_count)
  )

# Most common locations among complaints
tweet_data %>%
  filter(complaint_label == "Complaint", !is.na(tweet_location)) %>%
  count(tweet_location, sort = TRUE)

# Labeling confidence and tweet volume by airline
tweet_data %>%
  group_by(airline) %>%
  summarize(
    avg_confidence = mean(airline_sentiment_confidence),
    n_tweets = n()
  ) %>%
  arrange(desc(n_tweets))

library(tidytext)

tidy_twitter <- tweet_data %>%
  # Tokenize the tweet text
  unnest_tokens(word, text)

tidy_twitter %>%
  # Compute word counts
  count(word) %>%
  # Arrange the counts in descending order
  arrange(desc(n))


tidy_twitter <- tweet_data %>% 
  # Tokenize the twitter data
  unnest_tokens(word, text) %>% 
  # Remove stop words
  anti_join(stop_words)

tidy_twitter %>% 
  # Filter to keep complaints only
  filter(complaint_label == "Complaint") %>% 
  # Compute word counts and arrange in descending order
  count(word) %>% 
  arrange(desc(n))

# It looks like complaints include frequent references to flight, cancelled, and service.

# 2.Visualizing text

word_counts <- tidy_twitter %>% 
  filter(complaint_label == "Complaint") %>% 
  count(word) %>% 
  # Keep words with count greater than 100
  filter(n > 500)

# Create a bar plot using word_counts with x = word
ggplot(word_counts, aes(x = word, y = n)) +
  geom_col() +
  # Flip the plot coordinates
  coord_flip()

word_counts <- tidy_twitter %>% 
  # Only keep the non-complaints
  filter(complaint_label != "Complaint") %>% 
  count(word) %>% 
  filter(n > 150)

# Create a bar plot using the new word_counts
ggplot(word_counts, aes(x = word, y = n)) +
  geom_col() +
  coord_flip() +
  # Title the plot "Non-Complaint Word Counts"
  ggtitle('Non-Complaint Word Counts')