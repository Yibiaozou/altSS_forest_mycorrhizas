#running simulations w/ stand replacing disturbance rate.
rm(list=ls())
source('paths.r')
source('project_functions/gam.int_forest.sim.r')
source('project_functions/tic_toc.r')
source('project_functions/makeitwork.r')
library(mgcv)
library(doParallel)
library(data.table)


#set output path.----
output.path <- rf_initial_condition_hysteresis_simulation.path

#load models and environmental covariates.----
fits <- readRDS(rf_demographic_fits.path)
env.cov <- fits$all.cov

#register parallel environment.----
n.cores <- 28

#Specify Ndep up and down ramp ranges and number of plots.----
ndep.ramp.range <- seq(1,14)
ndep.ramp.range <- seq(1,15, by = 2)
N.PLOTS <- 500 #Must be even!
N.STEPS <- 40  #120 steps = 600 years, longer to make sure it runs to something "stable".

#Run ramp up models.----
cat('Running all EM simulations...\n');tic()
em.nul <- list()
em.alt <- list()

tic() #start timer.
for(i in 1:length(ndep.ramp.range)){
  env.cov$ndep <- ndep.ramp.range[i]
  #Null model.
  em.nul[[i]] <- makeitwork(
    forest.sim(g.mod.am = fits$null.models$grow.mod.am,
               g.mod.em = fits$null.models$grow.mod.em,
               m.mod.am = fits$null.models$mort.mod.am,
               m.mod.em = fits$null.models$mort.mod.em,
               r.mod.am = fits$null.models$recr.mod.am,
               r.mod.em = fits$null.models$recr.mod.em,
               env.cov = env.cov, 
               myco.split = 'all.em', silent = T,
               #disturb_rate = 0.0476/2,
               n.plots = N.PLOTS,
               n.cores = n.cores,
               n.step = N.STEPS)
  )
  #Feedback model.
  em.alt[[i]] <- makeitwork(
    forest.sim(g.mod.am = fits$feedback.models$grow.mod.am,
               g.mod.em = fits$feedback.models$grow.mod.em,
               m.mod.am = fits$feedback.models$mort.mod.am,
               m.mod.em = fits$feedback.models$mort.mod.em,
               r.mod.am = fits$feedback.models$recr.mod.am,
               r.mod.em = fits$feedback.models$recr.mod.em,
               env.cov = env.cov, 
               myco.split = 'all.em', silent = T,
               #disturb_rate = 0.0476/2,
               n.plots = N.PLOTS,
               n.cores = n.cores,
               n.step = N.STEPS)
  )
  #report.
  msg <- paste0(i,' of ',length(ndep.ramp.range),' all EM simulations complete. ')
  cat(msg);toc()
}

#Run all AM simulations.----
#reset env.cov levels.
env.cov <- fits$all.cov
am.nul <- list()
am.alt <- list()

tic() #start timer.
for(i in 1:length(ndep.ramp.range)){
  env.cov$ndep <- ndep.ramp.range[i]
  #Null model.
  am.nul[[i]] <- makeitwork(
    forest.sim(g.mod.am = fits$null.models$grow.mod.am,
               g.mod.em = fits$null.models$grow.mod.em,
               m.mod.am = fits$null.models$mort.mod.am,
               m.mod.em = fits$null.models$mort.mod.em,
               r.mod.am = fits$null.models$recr.mod.am,
               r.mod.em = fits$null.models$recr.mod.em,
               env.cov = env.cov, 
               myco.split = 'all.am', silent = T,
               #disturb_rate = 0.0476/2,
               n.plots = N.PLOTS,
               n.cores = n.cores,
               n.step = N.STEPS)
  )
  #Feedback model.
  am.alt[[i]] <- makeitwork(
    forest.sim(g.mod.am = fits$feedback.models$grow.mod.am,
               g.mod.em = fits$feedback.models$grow.mod.em,
               m.mod.am = fits$feedback.models$mort.mod.am,
               m.mod.em = fits$feedback.models$mort.mod.em,
               r.mod.am = fits$feedback.models$recr.mod.am,
               r.mod.em = fits$feedback.models$recr.mod.em,
               env.cov = env.cov, 
               myco.split = 'all.am', silent = T,
               #disturb_rate = 0.0476/2,
               n.plots = N.PLOTS,
               n.cores = n.cores,
               n.step = N.STEPS)
  )
  #report.
  msg <- paste0(i,' of ',length(ndep.ramp.range),' all AM simulations complete. ')
  cat(msg);toc()
}

#wrap, name and return output.----
cat('Wrapping output and saving...\n')
all.em <- list(em.nul, em.alt)
all.am <- list(am.nul, am.alt)
lab <- paste0('l',ndep.ramp.range)
for(i in 1:length(all.em)){names(all.em[[i]]) <- lab}
for(i in 1:length(all.am)){names(all.am[[i]]) <- lab}
names(all.em) <- c('nul','alt.GRM')
names(all.am) <- c('nul','alt.GRM')
output <- list(all.em, all.am)
names(output) <- c('all.em','all.am')
saveRDS(output, output.path, version = 2) #version=2 makes R 3.6 backwards compatbile with R 3.4.
cat('Script complete. ');toc()

#end script.----
