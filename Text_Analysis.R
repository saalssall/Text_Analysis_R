# Load tidyverse and the tweets dataset
library(tidyverse)
# Load the wordcloud package
library(wordcloud)
# Load the tidytext package
library(tidytext)
# Load the topic models package
library(topicmodels)

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

# Join tidy_twitter and the NRC sentiment dictionary
sentiment_twitter <- tidy_twitter %>% 
  inner_join(get_sentiments("nrc"))

# Count the sentiments in sentiment_twitter
sentiment_twitter %>% 
  count(sentiment) %>% 
  # Arrange the sentiment counts in descending order
  arrange(desc(n))

word_counts <- tidy_twitter %>% 
  # Append the NRC dictionary and filter for positive, fear, and trust
  inner_join(get_sentiments("nrc")) %>% 
  filter(sentiment %in% c("positive", "fear", "trust")) %>%
  # Count by word and sentiment and take the top 10 of each
  count(word, sentiment) %>% 
  group_by(sentiment) %>% 
  slice_max(n, n = 10) %>% 
  ungroup() %>% 
  # Create a factor called word2 that has each word ordered by the count
  mutate(word2 = fct_reorder(word, n))

# Create a bar plot out of the word counts colored by sentiment
ggplot(word_counts, aes(x = word2, y = n, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  # Create a separate facet for each sentiment with free axes
  facet_wrap(~ sentiment, scales = "free") +
  coord_flip() +
  # Title the plot "Sentiment Word Counts" with "Words" for the x-axis
  labs(
    title = "Sentiment Word Counts",
    x = "Words"
  )

# These word counts by sentiment illustrate a possible mismatch with this particular sentiment dictionary. For example, gate is listed under trust. 
# Pay is listed under both trust and positive. Our sentiment analysis is conditioned on the dictionary we use. 
# It's a tall order, but finding or building a sentiment dictionary that is context-specific would be ideal.

tidy_twitter %>% 
  # Append the NRC sentiment dictionary
  inner_join(get_sentiments('nrc'), relationship = "many-to-many") %>% 
  # Count by complaint label and sentiment
  count(complaint_label, sentiment) %>% 
  # Spread the sentiment and count columns
  pivot_wider(names_from = sentiment, values_from = n)

tidy_twitter %>% 
  # Append the afinn sentiment dictionary
  inner_join(get_sentiments("afinn")) %>% 
  # Group by both complaint label and airline
  group_by(complaint_label, airline) %>% 
  # Summarize the data with an aggregate_value = sum(value)
  summarize(aggregate_value = sum(value)) %>% 
  # Spread the complaint_label and aggregate_value columns
  pivot_wider(names_from = complaint_label, values_from = aggregate_value) %>% 
  mutate(overall_sentiment = Complaint + `Non-complaint`)

sentiment_twitter <- tidy_twitter %>% 
  # Append the bing sentiment dictionary
  inner_join(get_sentiments('bing')) %>% 
  # Count by complaint label and sentiment
  count(complaint_label, sentiment) %>% 
  # Spread the sentiment and count columns
  pivot_wider(names_from = sentiment, values_from = n) %>% 
  # Compute overall_sentiment = positive - negative
  mutate(overall_sentiment = positive - negative)

# Create a bar plot out of overall sentiment by complaint label, colored by complaint label as a factor
ggplot(
  sentiment_twitter, 
  aes(x = complaint_label, y = overall_sentiment, fill = as.factor(complaint_label))
) +
  geom_col(show.legend = FALSE) +
  coord_flip() + 
  # Title the plot "Overall Sentiment by Complaint Label" with an "Airline Twitter Data" subtitle
  labs(
    title = "Overall Sentiment by Complaint Label",
    subtitle = "Airline Twitter Data"
  )

# 4. Topic Modelling

lda_topics <- tidy_twitter %>%
  count(tweet_id, word) %>%
  cast_dtm(tweet_id, word, n) %>%
  LDA(k = 2, control = list(seed = 42)) %>%
  tidy(matrix = "beta")

lda_topics
# Start with the topics output from the LDA run
lda_topics %>% 
  # Arrange the topics by word probabilities in descending order
  arrange(desc(beta))

# Produce a grouped summary of the LDA output by topic
lda_topics %>% 
  group_by(topic) %>% 
  summarize(
    # Calculate the sum of the word probabilities
    sum = sum(beta),
    # Count the number of terms
    n = n()
  )

word_probs <- lda_topics %>%
  # Keep the top 10 highest word probabilities by topic
  group_by(topic) %>% 
  slice_max(beta, n = 10) %>% 
  ungroup() %>%
  # Create term2, a factor ordered by word probability
  mutate(term2 = fct_reorder(term, beta))

# Plot term2 and the word probabilities
ggplot(word_probs, aes(x = term2, y = beta)) +
  geom_col() +
  # Facet the bar plot by topic
  facet_wrap(~topic, scales = "free") +
  coord_flip()

# Start with the tidied Twitter data
tidy_twitter %>% 
  # Count each word used in each tweet
  count(word, tweet_id) %>% 
  # Use the word counts by tweet to create a DTM
  cast_dtm(tweet_id, word, n)

# A subset of the tidy_twitter data
tidy_twitter_subset <- tidy_twitter %>%
  filter(tweet_id %in% sample(unique(tweet_id), 500))

# Assign the DTM to dtm_twitter
dtm_twitter <- tidy_twitter_subset %>% 
  count(word, tweet_id) %>% 
  # Cast the word counts by tweet into a DTM
  cast_dtm(tweet_id, word, n)

# Coerce dtm_twitter into a matrix called matrix_twitter
matrix_twitter <- as.matrix(dtm_twitter)

# Print rows 1 through 5 and columns 90 through 95
matrix_twitter[1:5, 90:95]

# Cast the word counts by tweet into a DTM
dtm_twitter <- tidy_twitter %>% 
  count(word, tweet_id) %>% 
  cast_dtm(tweet_id, word, n)

# Run an LDA with 2 topics and a Gibbs sampler
lda_out <- LDA(
  dtm_twitter,
  k = 2,
  method = "Gibbs",
  control = list(seed = 42)
)

# Glimpse the topic model output
glimpse(lda_out)

# Tidy the matrix of word probabilities
lda_topics <- lda_out %>% 
  tidy(matrix = "beta")

# Arrange the topics by word probabilities in descending order
lda_topics %>% 
  arrange(desc(beta))

# Run an LDA with 3 topics and a Gibbs sampler
lda_out2 <- LDA(
  dtm_twitter,
  k = 3,
  method = "Gibbs",
  control = list(seed = 42)
)

# Tidy the matrix of word probabilities
lda_topics2 <- lda_out2 %>% 
  tidy(matrix = "beta")

# Arrange the topics by word probabilities in descending order
lda_topics2 %>% 
  arrange(desc(beta))


