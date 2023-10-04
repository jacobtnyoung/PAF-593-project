# ~~~~~~~~~~~~~~~~~~~~~ #
# PAF 593 Final Project #
# ~~~~~~~~~~~~~~~~~~~~~ #

# This file takes the downloaded file and cleans the data.

# ----
# Clear workspace and load needed libraries

rm( list = ls() )

library( here )    # for accessing local directory
library( dplyr )   # for working with the data
library( network ) # for building the networks

# ----
# load data file

dat <- readRDS( file = here( "PAF-593-wrangling/arrest-raw.rds" ) )


# ----
# clean data and restructure for creating networks

dat.edgelist <- dat %>% 
  select( YEAR, UNIQUE_NAME_ID, ARST_OFFICER, HUNDREDBLOCKADDR ) %>%  # keep the variables you need
  group_by( HUNDREDBLOCKADDR, ARST_OFFICER ) %>%                # group by address then officer id
  filter( n() > 1 ) %>%                                         # only keep cases that involve more than 1 person arrested
  arrange( ARST_OFFICER ) %>%                                   # arrange by arresting officer
  mutate( incident_id = cur_group_id() ) %>%                    # create unique id for event
  ungroup() %>%                                                 # un-group the data
  group_by( UNIQUE_NAME_ID ) %>%                                # group by unique person id
  mutate( person_id = cur_group_id() ) %>%                      # create a unique person id that is numeric
  ungroup() 
#View( dat.edgelist )


# create the edgelists for each year ----

# check the years
table( dat.edgelist$YEAR )

year.network <- function( edgelist, year ) {

  dat.edgelist.year <- edgelist %>% 
    select( YEAR, incident_id, UNIQUE_NAME_ID ) %>%               # keep the year, incident, and person id for the edgelist
    arrange( YEAR ) %>%                                           # arrange by year
    filter( YEAR == year ) %>%                                    # keep based on year
    select( incident_id, UNIQUE_NAME_ID ) %>%                     # keep the incident and person id for the edgelist
    arrange( incident_id, UNIQUE_NAME_ID )                        # arrange by incident then person id
  
  mat.edgelist.year <- as.matrix( dat.edgelist.year )             # coerce to an object of class matrix
  mat <- matrix(                                                  # initialize zeroed matrix.
    0, 
    length( unique( mat.edgelist.year[,1] ) ),                    # set dimensions to be events and persons
    length( unique( mat.edgelist.year[,2] ) )
    )
  rownames( mat ) <- unique( mat.edgelist.year[,1] )              # name the rows
  colnames( mat ) <- unique( mat.edgelist.year[,2] )              # name the columns
  mat[mat.edgelist.year] <- 1                                     # fill edgelist indexed edges with a 1
  diag( mat ) <- 0                                                # set the diagonal to zero
  
  net.year <- as.network(                                         # create the network
    mat, bipartite=TRUE, matrix.type="adjacency"
    )
  
  return( net.year )                                              # function returns an object of class network
  
}

# ----
# Execute the function for each year

net.2018 <- year.network( edgelist = dat.edgelist, year = 2018 )
net.2019 <- year.network( edgelist = dat.edgelist, year = 2019 )
net.2020 <- year.network( edgelist = dat.edgelist, year = 2020 )
net.2021 <- year.network( edgelist = dat.edgelist, year = 2021 )
net.2022 <- year.network( edgelist = dat.edgelist, year = 2022 )
net.2023 <- year.network( edgelist = dat.edgelist, year = 2023 )


# ----
# Save the file

net.list <- list( net.2018, net.2019, net.2020, net.2021, net.2022, net.2023 )

saveRDS( net.list, 
         file = here( "PAF-593-rodeo/arrest-cleaned.rds" ) 
         )

# readRDS( file = here( "PAF-593-rodeo/arrest-cleaned.rds" ) )


# ~~~~~~~~~~~~~ #
# END OF SCRIPT #
# ~~~~~~~~~~~~~ #