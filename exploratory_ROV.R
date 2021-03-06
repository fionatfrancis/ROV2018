## START ------------
dir.workspace <- "/Users/FrancisF/Documents/ROV analysis"
setwd(dir.workspace)
fish <- read_csv("2018_Vector_fish_with_coords.csv")
habitat <-read_csv("ROV2018_Vector_SpeciesData.csv")
status<- read_csv("Station_ID_RCA.csv")

## SETUP -----------

#install.packages("tidyverse")
#install.packages("janitor")
library(janitor)
library(tidyverse)


## DATA CLEANING -----

head(fish)
summary(fish)
head(habitat)
summary(habitat)
summary(habitat$Species)
unique(habitat$Species)
unique(fish$Species)
unique(fish$GPS_time)
duplicated(fish$GPS_time)

#remove non-fish entries from habitat dataset
habitat <- habitat %>% filter(Species != "crab/shrimp pot" & Species != "marine debris" 
                              & Species != "cable/line" & Species != "fishing debris")

#after ground truthing some of the duplicate rows by watching the videos I am changing the count of quillback on survey H119 at 08:11:17 from 2 to 1 in each of the two duplicated rows. Doing this in here so that there is a record and it can be changed back.

habitat <-habitat %>% mutate(Count = replace(Count, SurveyID == "H119-CA-V" & Species == "Quillback rockfish" & MicroSub1 == "R", 1))

#check to see if it worked, yay!

habitat %>% filter(SurveyID == "H119-CA-V" & Species == "Quillback rockfish" & MicroSub1 == "R")

# make habitat dataframe smaller by only selecting columns we care about (surveyid, species, depth, count, microsub, biocover, complex)
habitat <- habitat %>% select(SurveyID, GPS_time, Species, Count, MicroSub1, MicroSub2, Biocover1, Biocover2, Complexity, Depth_m)

# rename SurveyID in fish to match habitat dataset
fish <- fish %>% mutate(SurveyID = sub("Exp", "Explore", SurveyID))

#add columns from habitat to fish to circumvent problem outlined below

## combine the two datasets so that we have habitat and fish together, need to merge by survey, time and species because
#you can have more than one species at any given time (i.e. multiple species in the same frame). 
  #nope this also doesn't work because species at the same time are written in a differetn order in each dataset
  #for some reason

data <- fish %>% mutate(Substrate = habitat$MicroSub1, Substrate2 = habitat$MicroSub2, Count = habitat$Count, Biocover = habitat$Biocover1, Complexity = habitat$Complexity, Depth = habitat$Depth_m)

summary(data)

# add in RCA status from RCA csv

# need to change survey site names with P1 and P2 to V to match (need to check with Dana that this is okay but I think they are just seperate because of jumps in the ROV?)

data <- data %>% mutate(SurveyID = sub("P1", "V", SurveyID))
data <- data %>% mutate(SurveyID = sub("P2", "V", SurveyID))

# change survey names to match 

status <- status %>% mutate(Station_ID = sub("Exploration ", "Explore", Station_ID))

# oops this dataset uses underscores instead of hyphens lol. Fix that. hmm okay still not merging properly because there are part 1 and part 2's for some of the transects...what does that mean?

status <- status %>% mutate(Station_ID = sub("_", "-", Station_ID))
status <- status %>% mutate(Station_ID = sub("_", "-", Station_ID))#why does this not always sub them all?

# only keep the RCA status column and station ID

status <- status %>% select(Station_ID, RCA)

# rename station ID to survey ID

status <- status %>% rename(SurveyID = Station_ID)

# remove stations that aren't in fish data

status <- status %>% filter(!SurveyID %in% c("H021-CA-V", "H084-CA-V", "H104-CA-V", "H044-CA-V","H172-CA-V", "H069-CA-V"))

# merge status with data

new <- left_join(data, status, by = "SurveyID")

# what is happening with this join? Why are more rows getting added?

nrow(new)
nrow(distinct(new))
nrow(data)  
nrow(distinct(data))

# look at the duplicated rows in data to see if they are mistakes

janitor::get_dupes(data)

print(janitor::get_dupes(new), n = Inf)

# okay we want to keep the duplicates that are in data and remove the ones that somehow got added into new. Gonna do this in a hack way haha

#save duplicates from new
new2 <- print(janitor::get_dupes(new), n = Inf)

#only keep the ones we want to keep
new2 <- new2 %>% filter(SurveyID %in% c("H119-CA-V", "H126-CA-V", "H028-CA-V"))

new2 <- select(new2, -dupe_count)

new2 <- slice(new2, -c(2,4,6))

# take out duplicates from new
new <- distinct(new)

# add on the duplicates we saved in new2

all.data <- rbind(new,new2)

all.data

# Transects with no fish -----------------------------
# from looking at transect lines and fish observations in qgis there are 4 transects that don't seem to have fish  but a couple of them are listed in this dataset namely H113, H052, and L029. H044 is also showing no fish but it isn't in this dataset so maybe it is acutally the only one with no fish?

all.data %>% filter(SurveyID == "H113-CA-V")

all.data %>% filter(SurveyID == "H052-CA-V")

all.data %>% filter(SurveyID == "L029-CA-V")
## SUMMARY STATS --------

# counts of species
fish.counts <- all.data %>% group_by(Species) %>% summarise(total = sum(Count)) %>% arrange(desc(total))

#counts of species in and out of RCAs

all.data %>% group_by(RCA) %>% summarise(totalfish = sum(Count))


# types of primary substrate
all.data %>% group_by(Substrate) %>% summarise(total = sum(Count))


#summary of species counts by transect
all.data %>% group_by(SurveyID) %>% summarise(total = sum(Count))
 
## EXPLORATORY PLOTTING ----------

# counts of species
fish.counts <- all.data %>% group_by(Species) %>% summarise(total = sum(Count)) %>% arrange(desc(total))
ggplot(fish.counts) + geom_point(aes(Species, total))


#count against depth by species
ggplot(data, aes(Count)) + geom_histogram(alpha = 0.4)

#count per depth
ggplot(data) + geom_point(aes(Depth, Count),alpha = 0.4) +facet_wrap(~Species)
ggplot(data) + geom_point(aes(Depth, Count, colour = Species, alpha = 0.4))

#speices by substrate
ggplot(data, aes(Microsub1,Count)) +geom_point(alpha = 0.4) + facet_wrap(~Species)

#count per transect
ggplot(data) + geom_histogram(aes(Count), alpha = 0.4) + facet_wrap(~SurveyID)

