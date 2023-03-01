# compute 3D convex hulls around segmented tree points
# define metrics that are to be calculated for 2D convex hulls around tree points


# function wrapper to reshape data and call function to compute 3D convex hull from package rLiDAR
compute_crown_volumes <- function(segmented_point_cloud, id_field_name) {
  
  # function from package rLiDAR takes points as matrix
  # subset data.table from point cloud to 4-columns 
  segmented_point_cloud_dt <- subset(segmented_point_cloud@data, select=c("X","Y","Z", id_field_name))
  
  # convert to matrix
  segmented_point_cloud_matrix <- data.matrix(segmented_point_cloud_dt, rownames.force = NA)
  
  # calculate volumes, turn plot option off
  volumeList <- rLiDAR::chullLiDAR3D(xyzid=segmented_point_cloud_matrix, plotit = FALSE)
  
  # rename automatically named column 
  names(volumeList)[names(volumeList) == 'Tree'] <- id_field_name
  
  # change column data type to integer
  volumeList[,id_field_name] <- as.integer(volumeList[,id_field_name])
  
  return(volumeList)
}


# define metrics to be calculated from point cloud for each crown
# https://r-lidar.github.io/lidRbook/tba.html

calculate_crown_metrics <- function(z, nor, ndvi) { # user-defined function
  crown_metrics <- list(
    z_max = max(z),   # height metrics
    z_min = min(z),
    z_mean = mean(z),
    z_std = sd(z),
    zq1 = quantile(z, 0.01),
    zq2 = quantile(z, 0.02),
    zq5 = quantile(z, 0.05),
    zq95 = quantile(z, 0.95),
    zq99 = quantile(z, 0.99),
    n_pulses = length(z), # number of lidar pulses
    mean_nor = mean(nor), # mean number of returns
    mean_ndvi  = mean(ndvi)   # mean ndvi
  )
  return(crown_metrics) # output
}
