## Makes maps in support of Commuting Gap project
## Set the project root to the top project folder: ~\\RacialCommutingGap\\
## Ensure that you are working in a fresh session or are otherwise careful

rm(list = ls())
cdir <- "C:\\Users\\Chris.Severen\\Dropbox\\Data_Projects\\RacialCommutingGap\\"
gdir <- "C:\\GitHub\\RacializedCommutes\\"

## Load packages and functions, set wd, and declare useful variables 
pacman::p_load(tidyverse,
               haven,
               sf,
               tigris,
               ggthemes,
               maps,
               ggplot2)

setwd(cdir)
source(paste0(gdir,"code/map/function.R"))

## Set up mapping 
rawmap <- st_read("./empirics/data/czone_1990/cz1990.shp") %>%
  customCrop() %>%
  st_crop(c(xmin=-175, ymin=10, xmax=-55, ymax=71.44))

from_cz <- c(19600, 33000, 19800, 800, 1001)
to_cz <- c(19400, 33100, 19700, 900, 1100)

merged_czones <- map2_df(from_cz, to_cz, mergeCz, rawmap)
prepmap <- replaceCzWithMergedCz(rawmap, from_cz, to_cz, merged_czones) %>%
  shift_geometry()

breaks = c(-2,-1,0,1,2)
mycolours=c("darkblue", "blue", "white","red","darkred")

## Set up data and merge

#gapdata <- read.csv("./empirics/output/czyrall_blackwhite_cleaned.csv")
gapdata <- read.csv("./empirics/output/czyrall_blackwhite_cleaned.csv") %>%
  filter(min_n_black>50 & min_popemp>=1000 & n_yrs==5) %>%
  subset(select=c(czone,year,largestcity,r6_estimate)) %>%
  reshape(timevar = "year", 
          idvar = c("czone","largestcity"), 
          direction = "wide" ) %>%
  mutate(r6_diff = r6_estimate.2019 - r6_estimate.1980)

  

ready2map <- left_join(prepmap, gapdata, by=c("cz"= "czone"))

stprep <- map_data("state")

states <- st_transform(st_as_sf(map_data("state"), coords=c("long","lat"), crs=4121), st_crs(ready2map)) 
stprep <- st_sf(aggregate(states$geometry,
                list(states$group),
                function(g){
                  st_cast(st_combine(g),"POLYGON")
                }
                ))

## Make maps

testmap80 <- ready2map %>%
  ggplot() +
  geom_sf(aes(fill = r6_estimate.1980), alpha =1, col="grey85", size=0.1) +
  scale_fill_gradient2(low = "blue",
                       mid = "white",
                       high = "red",
                       midpoint = 0,
                       limits = c(-0.5,0.5),
                       na.value = "grey75") +
  geom_sf(data=stprep, aes(group=Group.1), color="grey40", size=0.1, alpha=0.1, fill=NA) +
  theme_map() +
  theme(legend.position = c(0.9,0.30),
        legend.title.align = 0.5) + 
  labs(fill = "RRD\n(1980)") 

ggsave(paste0(gdir,"code/map/gap_R6map_1980.pdf"))
ggsave(paste0(gdir,"code/map/gap_R6map_1980.png"))
knitr::plot_crop(paste0(gdir,"code/map/gap_R6map_1980.png"))

testmap00 <- ready2map %>%
  ggplot()+
  geom_sf(aes(fill = r6_estimate.2000), alpha =1, col="lightgrey", size=0.1) +
  scale_fill_gradient2(low = "blue",
                       mid = "white",
                       high = "red",
                       midpoint = 0,
                       limits = c(-0.5,0.5),
                       na.value = "grey70") +
  geom_sf(data=stprep, aes(group=Group.1), color="grey40", size=0.1, alpha=0.1, fill=NA) +
  theme_map() +
  theme(legend.position = c(0.9,0.30),
        legend.title.align = 0.5) + 
  labs(fill = "RRD\n(2000)")

ggsave(paste0(gdir,"code/map/gap_R6map_2000.pdf"))
ggsave(paste0(gdir,"code/map/gap_R6map_2000.png"))
knitr::plot_crop(paste0(gdir,"code/map/gap_R6map_2000.png"))

testmap19 <- ready2map %>%
  ggplot()+
  geom_sf(aes(fill = r6_estimate.2019), alpha =1, col="lightgrey", size=0.1) +
  scale_fill_gradient2(low = "blue",
                       mid = "white",
                       high = "red",
                       midpoint = 0,
                       limits = c(-0.5,0.5),
                       na.value = "grey70") +
  geom_sf(data=stprep, aes(group=Group.1), color="grey40", size=0.1, alpha=0.1, fill=NA) +
  theme_map() +
  theme(legend.position = c(0.9,0.30),
        legend.title.align = 0.5) + 
  labs(fill = "RRD\n(2019)")

ggsave(paste0(gdir,"code/map/gap_R6map_2019.pdf"))
ggsave(paste0(gdir,"code/map/gap_R6map_2019.png"))
knitr::plot_crop(paste0(gdir,"code/map/gap_R6map_2019.png"))

testmap8019 <- ready2map %>%
  ggplot()+
  theme_map() +
  theme(legend.position = c(0.9,0.30),
        legend.title.align = 0.5) + 
  labs(fill = "RRD\nChange\n2019-\n1980") +
  geom_sf(aes(fill = r6_diff), alpha =1, col="lightgrey", size=0.1) +
  scale_fill_gradient2(low = "blue",
                       mid = "white",
                       high = "red",
                       midpoint = 0,
                       limits = c(-0.5,0.5),
                       na.value = "grey70") +
  geom_sf(data=stprep, aes(group=Group.1), color="grey40", size=0.1, alpha=0.1, fill=NA) 


ggsave(paste0(gdir,"code/map/gap_R6map_DIFF.pdf"))
ggsave(paste0(gdir,"code/map/gap_R6map_DIFF.png"))
knitr::plot_crop(paste0(gdir,"code/map/gap_R6map_DIFF.png"))


