# Load tidyverse and the tweets dataset
library(tidyverse)
tweet_data <- read_csv("Tweets.csv")
print(tweet_data)

# Build the complaint label (negative sentiment = complaint)
tweet_data <- tweet_data %>%
  mutate(complaint_label = if_else(airline_sentiment == "negative",
                                   "Complaint", "Non-complaint"))
# Summary of retweets by complaint status
tweet_data %>%
  group_by(complaint_label) %>%
  summarize(
    avg_retweets = mean(retweet_count),
    min_retweets = min(retweet_count),
    max_retweets = max(retweet_count)
  )

