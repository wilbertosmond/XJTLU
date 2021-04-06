# libraries used
install.packages("doBy")
library("doBy")
library(ggplot2)

# This is my source code to demonstrate the BDA process
# The data will be processed according to these steps:
#   1. Data Acquisition: the data will be loaded from the dataset provided
#   2. Data Understanding: the data will be looked at given the business environment of the advertisement shown/clicked
#   3. Data Processing: data will be cleaned and categorized and impossible records will be removed from the analysis
#   4. Data Analysis: the processed data will be represented in graphs and tables. Possibly will go back to step 3 to give clearer results
#   5. Data Interpretation: the results of the data analysis and summary will be analyzed looking for one pattern

### 1. Data acquisition -----------------------------------------------------
## Load all available datasets
setwd("C:/Users/wilbert osmond/Documents/XJTLU/CSE313 Big Data Analytics/Assignment 1/Lab 1") # Set to the same directory
filenames <- list.files (pattern = "*.csv") # list all csv files
main_data <- NULL

## Add the first 10 files to the main dataset
for (day in 1:10) {
  cat("Loading file nyt", day, ".csv\n", sep="")
  dat = read.csv(filenames[day], header=TRUE)
  
  dat$Day <- day # add day column to plot the graphs
  
  if (is.null(main_data)) # first frame is initialized
    main_data <- dat
  else                    # all following frames are joined
    main_data <- rbind(main_data, dat)
}
cat("Data read in successfully\n\n")

### 2a. Data understanding -----------------------------------------------------
# Check if there is any data with age below 0
is.null(subset(main_data, Age<0))
cat("There is data with age below 0. We will remove this later\n\n")

# Add a new property (click-through-rate), which represents the rate of how much a user clicks on the advertisement after they view it
main_data$CTR <- main_data$Clicks / main_data$Impressions
cat("Added Click-Through-Rate attribute to the dataset\n\n")

### 3. Data preprocessing -----------------------------------------------------
## Data cleaning
# Non-signed-in users have assigned default values that will affect the analysis outcome. They will therefore be removed to maintain the analysis quality
main_data <- subset(main_data, Signed_In==1) # extract subset of data with signed-in users as the main data
cat("Non signed-in users have been removed\n\n")

# Remove data with no impressions, because CTR with no impressions must be a mistake since it is not possible for users to click on advertisements that don't show (i.e. wrong data) 
main_data <- subset(main_data, Impressions>0) # extract subset of main_data which has impressions above 0
cat("No-impressions data have been removed\n\n")

# Remove data with ages below 0, as this is impossible and unrealistic
main_data <- subset(main_data, Age>0) # extract subset of main_data which has age above 0
cat("Negative-age data have been removed\n\n")

# Data discretization: grouping age ranges to 0-30 (youngsters), 30-45 (adults), 45-60 (middle-aged adults)
main_data$agecat <- cut(main_data$Age,c(0, 30, 45, 60))
cat("Age has been discretized to three age categories\n\n")

# Create a separate subset, along with the same age category, for CTR > 0 later on
dataCTR <- subset(main_data, CTR>0)

### 2b. Data understanding -----------------------------------------------------
# Take a step back and look at the data again to understand it better

# Print the number of users in the three age groups
cat("Youngsters (0-30):", nrow(subset(main_data, Age>0 & Age<=30)), "\n")     # 860667
cat("Adults (30-45):  ", nrow(subset(main_data, Age>30 & Age<=45)), "\n")     # 923952
cat("Middle-aged adults (45-60): ", nrow(subset(main_data, Age>45 & Age<=60)), "\n")      # 841378

cat("The populations of the three age categories are similar. This enables us to more fairly compare their properties. \n\n")

### 4. Data analysis -----------------------------------------------------
# There are three age categories: youngsters, adults, and middle-aged adults. The thresholds are arbitrarily set to ensure similar population sizes and related to general age category concepts.
# Since the three population sizes are similar, we will compare the three to see which of the age category has the highest response rate to advertisements.

# The best metric is the Click-Through-Rate: the rate of which a user clicks on the advertisement when they see it (impressions)
# I have chosen to consider CTR>0 as being a sign that a user is interested in the advertisements proposed.

# Plot over 10 days
ggplot(subset(main_data, CTR>0), aes(x=factor(Day), fill=factor(agecat))) + 
  geom_histogram(stat="count", position="dodge") + 
  ggtitle("Users of different age groups interested in the advertisements shown") + 
  scale_fill_manual("Age category\n", values = c("green", "hotpink","turquoise"), labels = c("youngsters", "adults", "middle-aged adults")) +
  xlab("Day") + ylab("Number of users")

# Create function metrics that summarize the data for CTR attribute, and compare them with the three different age groups
siterange <- function(x){c(length(x), quantile(x), mean(x), var(x))}
summaryBy(CTR~agecat, data=dataCTR, FUN=siterange)

# CTR quantiles are 0 because clicks quantiles are also 0 (too small)

### 5. Data Interpretation -----------------------------------------------------
# The graph above show how, between ages 30 and 45, users are least interested in the advertisements shown.
# On the other hand, youngsters' (0-30) and middle-aged adults' (45-60) interests do not significantly differ.
cat("\nBetween ages 30 and 45, users are least interested in the advertisements shown.On the other hand, youngsters' (0-30) and middle-aged adults' (45-60) interests do not significantly differ.")