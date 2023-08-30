# ~~~~~~~~~~~~~~~~~~~~~ #
# PAF 593 Final Project #
# ~~~~~~~~~~~~~~~~~~~~~ #

# This file takes the downloaded file and cleans the data.

# ----
# Clear workspace and load needed libraries

rm( list = ls() )

library( here )  # for accessing local directory
library( dplyr ) # for working with the data


# ----
# load data file

dat <- readRDS( file = here( "PAF-593-wrangling/arrest-raw.rds" ) )


# ----
# clean data and restructure for creating networks

dat2 <- dat %>% 
  select( UNIQUE_NAME_ID, ARST_OFFICER, HUNDREDBLOCKADDR ) %>%  # keep the variables you need
  group_by( HUNDREDBLOCKADDR, ARST_OFFICER ) %>%                # group by address then officer id
  filter( n() > 1 ) %>%                                         # keep cases that involve more than 1 arrest
  arrange( ARST_OFFICER ) %>%                                   # arrange by arresting officer
  mutate( incident_id = cur_group_id() ) %>%
  ungroup() %>% 
  group_by( UNIQUE_NAME_ID ) %>% 
  mutate( person_id = cur_group_id() ) %>% 
  ungroup() %>% 
  select( incident_id, person_id )
  
View( dat2 )

!!!HERE: You have an edgelist, you just need to move to the next step

Note that you will probably need to go in and add the attributes so 
you can link those




# ~~~~~~~~~~~~~ #
# END OF SCRIPT #
# ~~~~~~~~~~~~~ #