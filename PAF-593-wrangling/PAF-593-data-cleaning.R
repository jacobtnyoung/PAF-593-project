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
  select( UNIQUE_NAME_ID, ARST_OFFICER, HUNDREDBLOCKADDR ) %>%  # keep the variables you need
  group_by( HUNDREDBLOCKADDR, ARST_OFFICER ) %>%                # group by address then officer id
  filter( n() > 1 ) %>%                                         # only keep cases that involve more than 1 arrest
  arrange( ARST_OFFICER ) %>%                                   # arrange by arresting officer
  mutate( incident_id = cur_group_id() ) %>%                    # create unique id for event
  ungroup() %>%                                                 # un-group the data
  group_by( UNIQUE_NAME_ID ) %>%                                # group by unique person id
  mutate( person_id = cur_group_id() ) %>%                      # create a unique person id that is numeric
  ungroup() %>%                                                 # un-group the data 
  select( incident_id, UNIQUE_NAME_ID ) %>%                          # keep the incident and person id for the edgelist
  #select( incident_id, person_id ) %>%                          # keep the incident and person id for the edgelist
  #arrange( incident_id, person_id )                             # arrange by incident then person id
  arrange( incident_id, UNIQUE_NAME_ID )                             # arrange by incident then person id
View( dat.edgelist )

# coerce to an object of class matrix
mat.edgelist <- as.matrix( dat.edgelist )
dim( mat.edgelist ) # 34263 edges in the network.
length( unique( mat.edgelist[,1] ) ) # 14,788 unique events
length( unique( mat.edgelist[,2] ) ) # 10,773 unique individuals


!!!NEED TO:
  Clean this up
  Do it by year I think because the adj matrix is too large


officer.event.edgelist <- mat.edgelist

# First, create the adjacency matrix
uR <-unique(officer.event.edgelist[,1])   # all unique row labels.
uC <- unique(officer.event.edgelist[,2])  # all unique column labels.
mat <- matrix(0, length(uR), length(uC))  # initialize zeroed matrix.
rownames(mat) <- uR  # name the rows.
colnames(mat) <- uC  # name the columns.
mat[officer.event.edgelist] <- 1   # fill edgelist indexed edges with a 1.
diag(mat) <- 0

# Take a look at the matrix.
sum(mat) # 343 edges.
dim(mat) # 81 officers by 153 events.

mat2 <- mat[1:500,1:500]


officer.event.net <- as.network(mat2,bipartite=TRUE,matrix.type="adjacency")



# ----
# create the network

net <- network( dat.edgelist, 
                matrix.type = "edgelist",
                bipartite = TRUE
                )




!!!HERE: You have an edgelist, you just need to move to the next step

Note that you will probably need to go in and add the attributes so 
you can link those




# ~~~~~~~~~~~~~ #
# END OF SCRIPT #
# ~~~~~~~~~~~~~ #