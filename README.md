# Text Analysis in R

A small R project for analyzing airline-related Twitter data using text mining, sentiment analysis, and topic modeling.

This project reads a CSV of tweets, cleans and transforms the text, identifies complaint vs. non-complaint tweets, explores common words, and applies sentiment and topic-modeling techniques to uncover patterns in customer feedback.

## Project Highlights

- Text cleaning and preprocessing for tweet data
- Complaint classification using sentiment labels
- Word frequency analysis and word clouds
- Sentiment analysis with `tidytext` dictionaries (`nrc`, `afinn`, `bing`)
- Topic modeling using Latent Dirichlet Allocation (LDA)
- Visualization of common words and sentiment trends

## Repository Structure

```text
Text_Analysis_R/
├── Text_Analysis.R     # Main analysis script
├── Tweets.csv          # Airline sentiment tweet dataset
├── Figures/            # Output folder for generated plots
├── .gitignore
└── README.md           # Project documentation
```

## Data

The project uses a tweet dataset stored in `Tweets.csv`, containing airline-related social media posts and associated metadata such as:

- airline name
- tweet text
- sentiment labels
- tweet location and timezone
- retweet counts
- complaint indicators

## Requirements

This project requires R and the following packages:

```r
install.packages(c(
  "tidyverse",
  "wordcloud",
  "tidytext",
  "topicmodels"
))
```

## Running the Analysis

1. Open R or RStudio.
2. Set the working directory to the project folder.
3. Run the script:

```r
source("Text_Analysis.R")
```

The script will:

- load the tweet data
- clean and prepare the dataset
- compute complaint labels
- generate word frequency summaries
- create visualizations
- perform sentiment analysis
- run LDA topic models

## Example Analyses Included

The script explores:

- complaint vs. non-complaint tweet volumes
- most common words among complaint tweets
- sentiment frequencies using NRC and Bing lexicons
- airline-level sentiment trends
- LDA topic extraction for tweet themes

## Notes

- The project is intended for learning and exploratory data analysis in R.
- Some outputs are created as plots and can be stored in the `Figures/` directory.
- Word and sentiment conclusions depend on the chosen sentiment dictionaries and may vary depending on the corpus.

## License

This project does not currently include a license file. If you plan to share or reuse it publicly, consider adding an open-source license such as MIT.

## Author

Created for text-analysis and sentiment-mining exploration in R.
