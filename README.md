# Text Mining in R

This repository contains a pair of R-based text analysis projects focused on Twitter and social-media text mining. The scripts demonstrate common workflows for preprocessing text, extracting word frequencies, creating word clouds, and exploring sentiment and topic patterns.

## Repository structure

```text
Text_Mining_R/
├── LICENSE
├── README.md
├── Text_Analysis/
│   ├── Text_Analysis.R
│   ├── Tweets.csv
│   └── Text_Analysis_Figures/
├── Text_Mining/
│   ├── Text_Mining.R
│   ├── twitter_data.csv
│   └── Text_Mining_Figures/
└── .gitignore
```

## Project folders

### Text_Analysis

The `Text_Analysis` folder contains a larger airline tweet analysis workflow. It explores:

- loading tweet data from CSV
- text cleaning and preprocessing
- complaint vs. non-complaint classification
- word frequency analysis
- sentiment analysis using lexicons such as `nrc`, `afinn`, and `bing`
- topic modeling with LDA
- plot generation for finding patterns in airline-related social posts

Run it from the repository root with:

```r
setwd("Text_Analysis")
source("Text_Analysis.R")
```

### Text_Mining

The `Text_Mining` folder contains a focused text-mining tutorial using the `tm` and `qdap` packages. It covers:

- corpus creation from vectors and data frames
- text cleaning, stop-word removal, and stemming
- term-document and document-term matrices
- term frequency summaries
- word clouds and color palette examples
- visual exploration of frequent terms in tweets

Run it from the repository root with:

```r
setwd("Text_Mining")
source("Text_Mining.R")
```

## Requirements

This project uses R and the following packages:

```r
install.packages(c(
  "tm",
  "qdap",
  "wordcloud",
  "RColorBrewer",
  "tidyverse",
  "tidytext",
  "topicmodels",
  "viridisLite"
))
```

## Notes

- The scripts are educational and exploratory in nature.
- Generated plots and figure outputs are saved in the corresponding `*_Figures` folders.
- The exact results may vary depending on package versions, text preprocessing decisions, and the dataset used.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
