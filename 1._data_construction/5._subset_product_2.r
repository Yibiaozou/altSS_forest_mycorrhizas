#Subset p1 and p2 to get a random stratified sampling for fitting models quicky.
rm(list=ls())
source('paths.r')
library(ggplot2)
library(ggalt)
library(data.table)

#set output path.----
output.path <- Product_2.subset.path

#load data.----
p2 <- readRDS(Product_2.path)
states <- read.csv('required_products_utilities/FIA_state_codes_regions.csv')
states.east <- states[states$east_plus == 1,]

#Some final data cleaning (should be moved?).-----
#Would be nice to move these to full data filtering script (#2).
p2 <- p2[p2$REMPER >=4.9 & p2$REMPER <= 5.1,]
p2 <- p2[p2$n.trees >  5,]
#Complete cases of environmental covariates.
env.drop <- p2[,c('PLT_CN','ndep','mat','map')]
env.drop <- env.drop[!complete.cases(env.drop),]
env.drop <- unique(env.drop$PLT_CN)
p2 <- p2[!(p2$PLT_CN %in% env.drop),]

#Grab a plot table with PLT_CN, lat-lon and STATECD.----
d <- p2[,.(PLT_CN,LAT,LON,STATECD,relEM,REMPER)]
setkey(d, 'PLT_CN')
d <- unique(d)

#Subset.----
#subset to eastern US.
d <- d[d$STATECD %in% states.east$STATECD,]
set.seed(42069)
n.plots <- 4000 #set number of plots to subsample.
d <- d[sample(nrow(d), n.plots),]
p2 <- p2[PLT_CN %in% d$PLT_CN,]

#plot subset to make sure its representative.----
plot = F
if(plot == T){
  lon <- d$LON
  lat <- d$LAT
  world <- map_data('usa')
  map <- ggplot() + geom_cartogram(data = world, map = world, 
                                   aes(x=long, y = lat, group = group, map_id=region))
  map <- map + coord_proj("+proj=wintri", ylim = c(25,50), xlim = c(-96,-69))
  map <- map + geom_point(aes(x = lon, y = lat), color = "yellow"    , size = .2)
  map <- map + theme(axis.line=element_blank(),
                     axis.text.x=element_blank(),
                     axis.text.y=element_blank(),
                     axis.ticks=element_blank(),
                     axis.title.x=element_blank(),
                     axis.title.y=element_blank(),
                     legend.position="none",
                     panel.border=element_blank()
  )
  map
}

#Save output.----
saveRDS(p2, output.path)