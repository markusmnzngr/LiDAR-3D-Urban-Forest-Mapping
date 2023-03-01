# roof overhangs are usually not modeled in 3D building models
# this function buffers gridded roof heights with a focal window to account for roof overhangs
# the focal window and thus the buffer size are determined depending on the cell size of the input grid

buffer_roof_surfaces <- function(roof_heights_grid){
  
  # define buffer and focal window depending on raster resolution
  # x resolution is assumed to be same as y resolution
  grid_resolution <- terra::xres(roof_heights_grid)
  
  # define matrix for focal buffer
  if (grid_resolution >= 1){
    focal_window <- matrix(c(NA,  1, NA, 
                             1,  1,  1, 
                             NA,  1, NA), nrow=3)
    cell_margin <- 1
    
  } else if (grid_resolution < 1 & grid_resolution >= 0.5){
    focal_window <- matrix(c(NA, NA,  1, NA, NA, 
                             NA,  1,  1,  1, NA, 
                             1,  1,  1,  1,  1, 
                             NA,  1,  1,  1, NA, 
                             NA, NA,  1, NA, NA), nrow=5)
    cell_margin <- 2
    
  } else if (grid_resolution < 0.5 & grid_resolution >= 0.3){
    focal_window <- matrix(c(NA, NA, NA,  1, NA, NA, NA,
                             NA, NA,  1,  1,  1, NA, NA,
                             NA, 1,  1,  1,  1,  1, NA,
                             1, 1,  1,  1,  1,  1, 1,
                             NA, 1,  1,  1,  1,  1, NA,
                             NA, NA,  1,  1,  1, NA, NA,
                             NA, NA, NA,  1, NA, NA, NA), nrow=7)
    cell_margin <- 3
    
  } else if (grid_resolution < 0.3 & grid_resolution >= 0.2){
    focal_window <- matrix(c(NA, NA, NA, NA,  1, NA, NA, NA, NA,
                             NA, NA, NA,  1,  1,  1, NA, NA, NA,
                             NA, NA, 1,  1,  1,  1,  1, NA, NA, 
                             NA, 1, 1,  1,  1,  1,  1, 1, NA, 
                             1, 1, 1,  1,  1,  1,  1, 1, 1, 
                             NA, 1, 1,  1,  1,  1,  1, 1, NA, 
                             NA, NA, 1,  1,  1,  1,  1, NA, NA, 
                             NA, NA, NA,  1,  1,  1, NA, NA, NA,
                             NA, NA, NA, NA,  1, NA, NA, NA, NA), nrow=9)
    cell_margin <- 4
    
  } else if (grid_resolution < 0.2){
    focal_window <- matrix(c(NA, NA, NA, NA, NA,  1, NA, NA, NA, NA, NA,
                             NA, NA, NA, NA,  1,  1,  1, NA, NA, NA, NA,
                             NA, NA, NA, 1,  1,  1,  1,  1, NA, NA, NA,
                             NA, NA, 1, 1,  1,  1,  1,  1, 1, NA, NA,
                             NA, 1, 1, 1,  1,  1,  1,  1, 1, 1, NA,
                             1, 1, 1, 1,  1,  1,  1,  1, 1, 1, 1,
                             NA, 1, 1, 1,  1,  1,  1,  1, 1, 1, NA,
                             NA, NA, 1, 1,  1,  1,  1,  1, 1, NA, NA,
                             NA, NA, NA, 1,  1,  1,  1,  1, NA, NA, NA,
                             NA, NA, NA, NA,  1,  1,  1, NA, NA, NA, NA,
                             NA, NA, NA, NA, NA,  1, NA, NA, NA, NA, NA), nrow=11)
    cell_margin <- 5
    
  }
  
  # calculate buffer size depending on focal window and grid resolution
  buffer_size <- cell_margin * grid_resolution
  
  # enlarge raster extent to facilitate buffering at tile boundaries
  # derive extent of roof raster
  bbox <- terra::ext(roof_heights_grid)
  # define new extent with margin according to buffer size
  bbox_margin <- terra::extend(bbox, c(buffer_size))
  
  # enlarge the spatial extent of the input raster
  roof_heights_grid <- terra::extend(roof_heights_grid, bbox_margin)
  
  # buffer raster by calculating focal values for each cell
  roof_heights_buffered_grid <- terra::focal(roof_heights_grid, focal_window, fun = mean, na.rm = TRUE, pad = TRUE)
  
  # overlay rasters to keep original values where available
  roof_heights_grid <- terra::cover(roof_heights_grid, roof_heights_buffered_grid, values = NA)
  
  return(roof_heights_grid)
}
  







