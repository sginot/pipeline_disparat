library(GoodFibes)

#-------------------------------------------------------------------------------
# Define custom functions for regular expression manipulation
#-------------------------------------------------------------------------------

substrRight <- function(x, n){substr(x, nchar(x) - n + 1, nchar(x))}

rm.last.chr <- function(x, n) {
  nc <- nchar(x)
  brk <- nc - n
  substr(x, 1, brk)
}

#-------------------------------------------------------------------------------
# Input working directory containing .png grayscale stacks of masked muscles
#-------------------------------------------------------------------------------

WD <- readline(prompt = "Input working directory (without quotes): ")
setwd(WD)

#-------------------------------------------------------------------------------
# File name manipulation
#-------------------------------------------------------------------------------

all_fil <- list.files()
sl <- rm.last.chr(all_fil, 9)
un_structures <- unique(sl)

#-------------------------------------------------------------------------------
# Loop through all muscles/segments to define the best threshold value and 
# starting slice for each.
#-------------------------------------------------------------------------------

sq_thrs <- seq(from = 0.5, # Threshold values to explore can be modified here.
               to = 0.9,   # Max range is from 0 to 1.
               by = 0.1)

sslice <- thrs <- rep(NA, length(un_structures))

for (i in 1:length(un_structures)) {
  
  f <- all_fil[which(sl == un_structures[i])]
  fi <- file.info(f)
  min_fi <- min(fi$size)
  wmf <- which(fi$size > min_fi)
  #start_slice <- wmf[1]
  #end_slice <- wmf[length(wmf)]
  mid_slice <- wmf[length(wmf)/2]
  sslice[i] <- mid_slice
  
  for (j in sq_thrs) {
    thresholdPlot(images = f,
                  n = mid_slice,
                  threshold = j)
    title(main = paste(un_structures[i], "Threshold =", j))}
  
  thrs[i] <- as.numeric(readline(prompt = "Input best threshold value: "))
  dev.off()
}

#-------------------------------------------------------------------------------
# Run the goodfibes main functions automatically based on the values prepared
# in the previous section.
#-------------------------------------------------------------------------------

resolution <- as.numeric(readline(prompt = "Input voxel size: "))
nfibers <- as.numeric(readline(prompt = "Input number of fibers to reconstruct: "))
show.plot <- F

ls_results <- vector("list", 
                     length = length(un_structures))

names(ls_results) <- un_structures

for (i in 1:length(un_structures)) {
  
  print(paste("Analyzing muscle:", un_structures[i]))
  
  f <- list.files(pattern = un_structures[i])
  
  g <- good.fibes(images = f,
                  radius = 7,
                  zero.image = sslice[i], 
                  threshold = thrs[i],
                  cutoff = thrs[i] - 0.05,
                  seeds = nfibers,
                  show.plot = show.plot)
  
  fl <- fiber.lengths(fib.list = g, 
                      res = resolution, 
                      df = 2)
  
  fa <- fiber.angle(fib.list = g, 
                    axis = 1)
  
  ls <- list(fibers = g, lengths = fl, angles = fa)
  
  ls_results[[i]] <- ls
  
}

save(ls_results,
     file = "../goodfibes_output.RData")

#-------------------------------------------------------------------------------
# export fibes as surfaces
#-------------------------------------------------------------------------------

for (i in 1:length(un_structures)) {
  
  o <- ls_results[[i]][[1]]
  
  fil <- paste("../", un_structures[i], "_fibers.stl", sep = "")
  
  muscle.plot.stl(fiber.list = o, 
                  res = resolution, 
                  df = 2, 
                  save.plot = T, 
                  file.name = fil, 
                  mirror.axis = F)
}

