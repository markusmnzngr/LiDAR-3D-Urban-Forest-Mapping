# calculate raster based zonal statistics and return as data.frame
# function takes polygons as input for zone definition
# conversion to raster with cell size according to value raster
# output statistics as data.frame

zonal_stats_as_df <- function(zones_poly, zone_id_field_name, value_raster, value_field_name, stats_fun) {
  
  # compute zone raster 
  zones_grid <- terra::rasterize(zones_poly, terra::rast(extent = terra::ext(value_raster), crs = terra::crs(value_raster), resolution = terra::res(value_raster)), field = zone_id_field_name)
  
  # secure correct name after conversion
  names(zones_grid) <- zone_id_field_name
  
  # execute zonal statistics - results as data.frame
  zonal_stats_df <- terra::zonal(value_raster, zones_grid, fun = stats_fun, na.rm = TRUE, as.raster = FALSE)
  
  # replace NAs
  zonal_stats_df[is.na(zonal_stats_df)] <- 0
  
  # rename data.frame column 
  names(zonal_stats_df)[2] <- value_field_name
  
  return(zonal_stats_df)
}