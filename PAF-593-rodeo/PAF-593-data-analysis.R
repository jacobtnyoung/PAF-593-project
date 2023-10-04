# ~~~~~~~~~~~~~~~~~~~~~ #
# PAF 593 Final Project #
# ~~~~~~~~~~~~~~~~~~~~~ #

# This files takes the cleaned data and creates objects for analysis.

# ----
# Clear workspace and load needed libraries

rm( list = ls() )

library( here )    # for accessing local directory
library( dplyr )   # for working with the data
library( network ) # needed for creating edgelists
library( tnet )    # for working with two-mode networks


# ----
# execute scripts to build files

# download the data from the website
#source( here( "PAF-593-wrangling/PAF-593-data-download-save.R" ) )

# clean/prep the downloaded data
#source( here( "PAF-593-wrangling/PAF-593-data-cleaning.R" ) )


# ----
# load data file

nets <- readRDS( file = here( "PAF-593-rodeo/arrest-cleaned.rds" ) )


# ----
# create tnet objects for analysis

# create a list to store the tnet objects
tnets <- list()

# run a loop to create the networks
# the warning can be ignored as it is not relevant
for( i in 1: length( nets ) ){
  
  tnets[[i]] <- as.tnet( as.edgelist( nets[[i]] ) )
  
}


# ----
# create the distance scores

# the distance_tm function creates a projection to 
# calculated the distance matrix; in this case tie weights 
# are defined as the number of common nodes that two individuals contact through

# create a vector for the various reachability scores
mean.reach <- NULL
min.reach <- NULL
max.reach <- NULL

# run a loop to create the mean reachability
for( i in 1: length( nets ) ){

  mean.reach[i] <- mean( distance_tm( tnets[[i]] ), na.rm = TRUE )
  min.reach[i] <- min( distance_tm( tnets[[i]] ), na.rm = TRUE )
  max.reach[i] <- max( distance_tm( tnets[[i]] ), na.rm = TRUE )
  
}


# ----
# create the clustering scores

# the reinforcement_tm function creates a global measure of clustering
# that is defined as the the ratio of 4-cycles X 4, divided by the number of 3-paths

# create a vector for the clustering scores
reinforcement.values <- NULL

# run a loop to create the clustering scores
for( i in 1: length( nets ) ){
  
  reinforcement.values[i] <- reinforcement_tm( tnets[[i]] )
  
}


# ----
# create objects that represent the number of events, individuals, and edges

event.count <- NULL

for( i in 1: length( nets ) ){
  
  event.count[i] <- length( unique( tnets[[i]][,1] ) )
  
}

person.count <- NULL

for( i in 1: length( nets ) ){
  
  person.count[i] <- length( unique( tnets[[i]][,2] ) )
  
}

edges.count <- NULL

for( i in 1: length( nets ) ){
  
  edges.count[i] <- dim( tnets[[i]] )[1]
  
}


# ----
# create a dataframe from the objects created

net.data.frame <- data.frame(
  Year = 2018:2023,
  Events = event.count,
  Individuals = person.count,
  Edges = edges.count,
  Mean.Reachability = mean.reach,
  Min.Reachability = min.reach,
  Max.Reachability = max.reach,
  Reinforcement = reinforcement.values
  
)


# ~~~~~~~~~~~~~ #
# END OF SCRIPT #
# ~~~~~~~~~~~~~ #