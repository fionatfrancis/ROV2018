## SETUP -----------

#install.packages("tidyverse")
#install.packages("janitor")
library(janitor)
library(tidyverse)

## START ------------
width <- read_csv("ROV2018_Vector_TransectSegmentData.csv")
transects <-read_csv("2018_Vector_pass2_points_clipped.csv")
lengths <- read_csv("2018_Vector_transect_length.csv")


# I need to calculate the area of each transect so that I can calculate a density of fish on each one. The simple way to do this would be to take the total distance of the transect and multiple it by the average width pf the lasers (width was measured every 20 seconds). However, it would be nice to be able to calculate the areas every 30 seconds instead. This requires knowing the trackline for that 30 seconds and then drawing a polygon of the appropriate width around that thrack line and summing all of the track line 30 segments up. We know the position of the track every 1 second so should be able to draw a line over these using the sp and rgeos packages according to J. Nephin. The plan is to give each segment of 30 second GPS coordinate an individual ID that we then turn into a line segment using sp. Then I can use the glength funtion in rgeos to calculate the length of this line and can multiply it by the appropriate width. In theory I should be able to make a loop that runs through the ID column, loop through and add a 1 every time that I hit a new date


# Let's first see how similar the widths are across a transect ----------------------------
width

# add a column of the actual width
width <- width %>% mutate(actual.width = (Screen_width*(10/Laser_width)))

glimpse(width)
summary(width)
# look at average width and SD around that for each transect
avg.width <- width %>% filter(!is.na(actual.width)) %>%  group_by(SurveyID) %>% summarise(mean.width = mean(actual.width), sd.width = (sd(actual.width))) #ugh I feel like there is a lot of variation

# let's just plot all of the widths over a transect, there is quite a lot of variation 

ggplot(width) + geom_point(aes(SurveyID, actual.width),alpha = 0.4)

# hmm but there are 400 missing widths so what do I do with those? There is a lot of variation within a transect but ALL the transects have a lot of variation so maybe it's just worth taking the overall distance and widths for now and worry about this later if I need to?

# okay let's combine average widths with the distance of the transects ----------------------------------

# look at the lengths
lengths

# okay remove first two rows and fix the headings

lengths <- lengths %>% slice(-(1:2)) %>% 
  rename(Transect = "X1",SurveyID = "X2", pass2_5m = "pass2", pass2_10m = "pass2_1", pass2_50m = "pass2_2" ) %>%
  select(!(X6)) %>%
mutate(pass2_5m = as.numeric(pass2_5m), pass2_10m = as.numeric(pass2_10m), pass2_50m = as.numeric(pass2_50m))


# okay make a column with the average length based on pass 2 (average of 2, 5, and 10 m smoothing)

lengths <- lengths %>% rowwise() %>% mutate(mean.length = mean(c(pass2_5m, pass2_10m, pass2_50m))) # needed to add rowwise because mean will just generate one number

#change the length surveyID to match width ones

unique(lengths$SurveyID)
unique(lengths$Transect)
unique(width$SurveyID)

# need to change survey site names with P1 and P2 to V to match (need to check with Dana that this is okay but I think they are just seperate because of jumps in the ROV?)

width <- width %>% mutate(SurveyID = sub("V", "P1", SurveyID))
width <- width %>% mutate(SurveyID = sub("CA", "P1", SurveyID))

# change explore survey names to match 

width <- width %>% mutate(SurveyID = sub("Explore", "Exp", SurveyID))
width <- width %>% mutate(SurveyID = sub("Explore", "Exp", SurveyID))
# rename the explore ones

width %>% 

# change CA to P1

#change V t0 1

#########################
#   Transect distance   # 
#########################
# Create spatial lines, one for each transect
transects <- list()
for (i in unique(dat_images$transect_name)) {
  transects[[i]] <- Lines(ID = i, Line(
    dat_images[dat_images$transect_name == i, 
               c("longitude","latitude")]))
}
sldf <- SpatialLines(transects)
# Set coordinate reference system
proj4string(sldf) <- CRS("+proj=longlat +datum=WGS84")
# Project to BC albers before calculating transect length
bcalbers <- "+proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
sldf <- spTransform(sldf, bcalbers)
# Calculate the length of each transect
distance <- gLength(sldf, byid = TRUE)
distance <- data.frame(transect_name=names(distance), 
                       transect_length_m=distance)