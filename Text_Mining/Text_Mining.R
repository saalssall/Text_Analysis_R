# Load qdap
library(qdap)

text <- "Text mining, text data mining (TDM) or text analytics is the process of deriving high-quality information from text. It involves 'the discovery by computer of new, previously unknown information, by automatically extracting information from different written resources.'[1] Written resources may include websites, books, emails, reviews, and articles.[2] High-quality information is typically obtained by devising patterns and trends by means such as statistical pattern learning. According to Hotho et al. (2005), there are three perspectives of text mining: information extraction, data mining, and knowledge discovery in databases (KDD).[3] Text mining usually involves the process of structuring the input text (usually parsing, along with the addition of some derived linguistic features and the removal of others, and subsequent insertion into a database), deriving patterns within the structured data, and finally evaluation and interpretation of the output. 'High quality' in text mining usually refers to some combination of relevance, novelty, and interest. Typical text mining tasks include text categorization, text clustering, concept/entity extraction, production of granular taxonomies, sentiment analysis, document summarization, and entity relation modeling (i.e., learning relations between named entities)."

# Print new_text to the console
text

# Find the 10 most frequent terms: term_count
term_count <- freq_terms(text, 10)

# Plot term_count
plot(term_count)


# Import text data from CSV, no factors
tweet_data <- read.csv("twitter_data.csv", stringsAsFactors = FALSE)

# View the structure of the data
str(tweet_data)

# Isolate the text from the tweets
tech_tweets <- tweet_data$tweet_text

head(tech_tweets)

# Load tm
library(tm)

# Make a vector source from tech_tweets
tech_source <- VectorSource(tech_tweets)
# Make a volatile corpus from tech_source
tech_corpus <- VCorpus(tech_source)
# Print out tech_corpus
print(tech_corpus)
# Print the 15th tweet in tech_corpus
print(tech_corpus[[15]])
# Print the contents of the 15th tweet in tech_corpus
print(content(tech_corpus[[15]]))
# Now use content to review the plain text of the 10th tweet
print(content(tech_corpus[[10]]))

tweets_df <- data.frame(
  doc_id = seq_len(nrow(tweet_data)),
  text   = tweet_data$tweet_text,
  stringsAsFactors = FALSE
)

# Corpus from the data frame
df_source <- DataframeSource(tweets_df)
df_corpus <- VCorpus(df_source)

# Corpus from a plain vector of text
vec_source <- VectorSource(tweet_data$tweet_text)
vec_corpus <- VCorpus(vec_source)

# Compare the number of documents
df_corpus
vec_corpus

# Compare corpus-level metadata
meta(df_corpus)
meta(vec_corpus)


# Create the object: text
text <- "<b>She</b> woke up at       6 A.M. It\'s so early!  She was only 10% awake and began drinking coffee in front of her computer."

# Make lowercase
tolower(text)

# Remove punctuation
removePunctuation(text)

# Remove numbers
removeNumbers(text)

# Remove whitespace
stripWhitespace(text)
