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
# Input working directory containing .png grayscale stacks of masked muscles,
# Define the sequence of threshold levels to be explored (range between 0 and 1)
# Also set voxel size, number of fibers to be modeled and whether to show plots
# (much slower)
#-------------------------------------------------------------------------------

WD <- readline(prompt = "Input working directory (without quotes): ")
setwd(WD)

sq_thrs <- seq(from = 0.3, # Threshold values to explore can be modified here.
               to = 0.9,   # Max range is from 0 to 1.
               by = 0.1)

resolution <- as.numeric(readline(prompt = "Input voxel size: "))
nfibers <- as.numeric(readline(prompt = "Input number of fibers to reconstruct: "))
show.plot <- F

#-------------------------------------------------------------------------------
# File name manipulation
#-------------------------------------------------------------------------------

all_fil <- list.files() #list all files in folder
sl <- rm.last.chr(all_fil, 9) #remove "_XXXX.png" at the end of file names
usl <- unique(sl) #unique abbreviations of anatomical structures
un_structures <- usl

if (length(grep(pattern = "apo", usl)) > 0) {
  un_structures <- usl[-grep(pattern = "apo", usl)] #remove aponeuroses
}

#-------------------------------------------------------------------------------
# Loop through all muscles/segments to define the best threshold value and 
# starting slice for each.
#-------------------------------------------------------------------------------

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
    #x11()
    thresholdPlot(images = f,
                  n = mid_slice,
                  threshold = j)
    title(main = paste(un_structures[i], "Threshold =", j))
    }
  
  thrs[i] <- as.numeric(readline(prompt = "Input best threshold value: "))

  while (dev.cur() > 1) dev.off()
}

write.table(rbind(un_structures, sslice, thrs), 
            row.names = c("muscle", "mid_slice", "threshold"),
            col.names = F,
            file = "../parameters_goodfibes.csv",
            sep = ",",
            dec = ".")

#-------------------------------------------------------------------------------
# Run the goodfibes main functions automatically based on the values prepared
# in the previous section.
#-------------------------------------------------------------------------------

#ls_results <- vector("list", length = length(un_structures))

#names(ls_results) <- un_structures
stm <- Sys.time()
print(paste("Started:", stm))

for (i in 1:length(un_structures)) {
  
  print(paste("Analyzing muscle:", un_structures[i]))
  
  f <- all_fil[which(sl == un_structures[i])]
  
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
  
  fax <- fiber.angle(fib.list = g, 
                     axis = 1)
  fay <- fiber.angle(fib.list = g, 
                     axis = 2)
  faz <- fiber.angle(fib.list = g, 
                     axis = 3)
  
  ls <- list(fibers = g, 
             lengths = fl, 
             x_angle = fax, 
             y_angle = fay, 
             z_angle = faz)
  
  save(ls,
       file = paste("../", 
                    un_structures[i], 
                    "_goodfibes_output.RData", 
                    sep = ""))
  
  #ls_results[[i]] <- ls
  
}
etm <- Sys.time()
rtm <- difftime(etm, stm)
print(paste("Runtime:", rtm))

#save(ls_results, file = "../goodfibes_output.RData")

#-------------------------------------------------------------------------------
# export fibes as surfaces
#-------------------------------------------------------------------------------

setwd("..")

if (!dir.exists("./fibers_stl/")) {dir.create("./fibers_stl/")}

rdata_files <- list.files(pattern = "_goodfibes_output.RData")  

for (i in 1:length(rdata_files)) {
  
  load(rdata_files[i])
  
  o <- ls$fibers
    
  struct <- gsub(pattern = "_goodfibes_output.RData", 
                 replacement = "",
                 rdata_files[i])
  
  fil <- paste("./fibers_stl/", struct, "_fibers.stl", sep = "")
  
  muscle.plot.stl(fiber.list = o, 
                  res = resolution, 
                  df = 2, 
                  save.plot = T, 
                  file.name = fil, 
                  mirror.axis = F)
}

