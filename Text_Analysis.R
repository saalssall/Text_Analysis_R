# Load tidyverse and the tweets dataset
library(tidyverse)
# Load the wordcloud package
library(wordcloud)
# Load the tidytext package
library(tidytext)
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

word_counts <- tidy_twitter %>%
  filter(complaint_label == "Non-complaint") %>%
  count(word) %>%
  filter(n > 100) %>%
  mutate(word2 = fct_reorder(word, n))

ggplot(word_counts, aes(x = word2, y = n)) +
  geom_col() +
  coord_flip() +
  ggtitle("Non-Complaint Word Counts")

word_counts <- tidy_twitter %>%
  # Count words by whether or not its a complaint
  count(word, complaint_label) %>%
  # Group by whether or not its a complaint
  group_by(complaint_label) %>%
  # Keep the top 20 words
  slice_max(n, n = 20) %>%
  # Ungroup before reordering word as a factor by the count
  ungroup() %>%
  mutate(word2 = fct_reorder(word, n))

# Include a color aesthetic tied to whether or not its a complaint
ggplot(word_counts, aes(x = word2, y = n, fill = complaint_label)) +
  # Don't include the lengend for the column plot
  geom_col(show.legend = FALSE) +
  # Facet by whether or not its a complaint and make the y-axis free
  facet_wrap(~ complaint_label, scales = "free_y") +
  # Flip the coordinates and add a title: "Twitter Word Counts"
  coord_flip() +
  ggtitle("Twitter Word Counts")

# Compute word counts and assign to word_counts
word_counts <- tidy_twitter %>% 
  count(word)

wordcloud(
  # Assign the word column to words
  words = word_counts$word, 
  # Assign the count column to freq
  freq = word_counts$n, 
  max.words = 30
)

# Compute complaint word counts and assign to word_counts
word_counts <- tidy_twitter %>% 
  filter(complaint_label == "Complaint") %>% 
  count(word)

# Create a complaint word cloud of the top 50 terms, colored red
wordcloud(
  words = word_counts$word, 
  freq = word_counts$n, 
  max.words = 50, 
  colors = "red"
)

# 3. Sentiment Analysis

# Count the number of words associated with each sentiment in nrc
get_sentiments("nrc") %>% 
  count(sentiment) %>% 
  # Arrange the counts in descending order
  arrange(desc(n))

# Pull in the nrc dictionary, count the sentiments and reorder them by count
sentiment_counts <- get_sentiments("nrc") %>% 
  count(sentiment) %>% 
  mutate(sentiment2 = fct_reorder(sentiment, n))

# Visualize sentiment_counts using the new sentiment factor column
ggplot(sentiment_counts, aes(x = sentiment2 , y = n)) +
  geom_col() +
  coord_flip() +
  # Change the title to "Sentiment Counts in NRC", x-axis to "Sentiment", and y-axis to "Counts"
  labs(
    title = "Sentiment Counts in NRC",
    x = "Sentiment",
    y = "Counts"
  )