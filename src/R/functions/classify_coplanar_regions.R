# detection of planes in point clouds with a resolution of about 4 points/m² may be fragmentary
# conversion of coplanar points to raster and grouping of adjacent pixels to regions
# calculation of Z-max for each of these regions and classification of all points below Z-max

classify_coplanar_regions <- function(lidar_surface_points){
  
  # filter coplanar points from point cloud 
  lidar_coplanar_points <- lidR::filter_poi(lidar_surface_points, Classification == 31L)
  
  # rasterize coplanar points
  coplanar_zmax_grid  <- lidR::template_metrics(lidar_coplanar_points, max(Z), template)
  # name raster layer
  names(coplanar_zmax_grid)<-"zmax"
  
  
  #### connected component labeling via imager ####
  # conversion to cimg and replacement of NAs
  coplanar_zmax_matrix <- terra::as.matrix(terra::classify(coplanar_zmax_grid, cbind(NA,9999)), wide = TRUE)
  coplanar_zmax_cimg <- imager::as.cimg(coplanar_zmax_matrix)
  
  # connected component labeling
  coplanar_ccn_cimg <- imager::label(coplanar_zmax_cimg, high_connectivity = TRUE, tolerance = 1)
  
  # conversion to matrix and then to SpatRaster 
  coplanar_ccn_matrix <- terra::as.matrix(coplanar_ccn_cimg)
  
  coplanar_ccn_grid <- terra::rast(coplanar_ccn_matrix, crs = tile_crs, extent = tile_ext)
  # name raster layer
  names(coplanar_ccn_grid)<-"ccn_id"
  
  # mask na cells with original coplanar grid
  coplanar_ccn_grid <- terra::mask(coplanar_ccn_grid, coplanar_zmax_grid)
  
  
  #### zonal statistics to calculate z-max for each coplanar region ####
  # as data.frame for a join  with the convex hulls
  # as raster to identify intersecting regions 
  zonal_stats_df <- terra::zonal(coplanar_zmax_grid, coplanar_ccn_grid, fun = max, as.raster = FALSE)
  zonal_stats_grid <- terra::zonal(coplanar_zmax_grid, coplanar_ccn_grid, fun = max, as.raster = TRUE)
  
  
  #### convert identified coplanar regions to polygon as prerequisite for convex hull calculation with terra  ####
  coplanar_ccn_poly <- terra::as.polygons(coplanar_ccn_grid, dissolve = TRUE, values = TRUE, na.rm = TRUE)
  
  # get the convex hull by group
  # hulls may overlap each other
  coplanar_convhull <- terra::convHull(coplanar_ccn_poly, by = "ccn_id")
  
  # join z-max to each convex hull
  coplanar_convhull_zmax <- terra::merge(coplanar_convhull, zonal_stats_df, all.x = FALSE, by.x = "ccn_id", by.y = "ccn_id")
  
  # rasterize the convex hulls with their z-max value
  coplanar_convhull_zmax_grid <- terra::rasterize(coplanar_convhull_zmax, template, field = "zmax", background = NA, touches = FALSE, update = TRUE)
  
  # overlay rasters to identify highest values for overlapping hulls
  coplanar_convhull_union_grid <- terra::ifel(coplanar_convhull_zmax_grid < zonal_stats_grid, zonal_stats_grid, coplanar_convhull_zmax_grid)
  
  # join the heights of coplanar regions to the point clound
  lidar_surface_points <- lidR::merge_spatial(lidar_surface_points, coplanar_convhull_union_grid, "H_Raster")
  
  # assign all points that overlay coplanar region and are not higher as the Z-max of the region to user-defined class 32
  lidar_surface_points@data[Z <= H_Raster, Classification := 32L]
  
  
  return(lidar_surface_points)
  
}