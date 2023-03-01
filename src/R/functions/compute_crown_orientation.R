# modeling tree canopies by ellipsoids requires the orientation and dimensions of the ellipse to be known.
# compute antipodal pair of the ellipse as longest distance between two vertices of convex hull
# compute orientation of the line connecting the antipodal pair

compute_crown_orientation <- function(tree_crowns_poly) {
  #create list of treeIDs to iterate over single crowns
  #extract attribute table
  attrib_table <- terra::values(tree_crowns_poly, dataframe = TRUE)
  
  # subset to column tree id
  treeID_list <- as.list(attrib_table[, "treeID"])
  
  # create empty data.frame
  df <- data.frame()
  
  # iterate over tree crowns
  for (treeID in treeID_list) {
    
    # subset datset to single crown
    crown_subset <- terra::subset(tree_crowns_poly, tree_crowns_poly$treeID == treeID, c("treeID"))
    
    # extract crown vertices as points
    points_subset <- terra::as.points(crown_subset)
    
    # create ID from row number
    points_subset[, "pointID"] <- 1:nrow(points_subset)
    
    # calculate distance matrix between all vertices
    points_subset_dist <- terra::distance(points_subset, pairs = TRUE)
    
    # sort by decreasing distance
    points_subset_dist_sorted <- points_subset_dist[order(points_subset_dist[,3],decreasing=TRUE),]
    
    # store IDs of Antipode Pair
    point1_ID <- points_subset_dist_sorted[1,1]
    point2_ID <- points_subset_dist_sorted[1,2]
    
    # extract Antipodes by subsetting vertices
    point1 <- terra::subset(points_subset, points_subset$pointID == point1_ID)
    point2 <- terra::subset(points_subset, points_subset$pointID == point2_ID)
    
    # create line between both points
    max_dist_line <- terra::vect(rbind(c(terra::xmin(point1), terra::ymin(point1)), c(terra::xmin(point2), terra::ymin(point2))), type = "lines", crs = tile_crs)
    
    # calculate length
    ch_length <- terra::perim(max_dist_line)
    
    # calculate arctan - orientation azimuth
    radians <- atan2(terra::ymin(point2) - terra::ymin(point1), terra::xmax(point2) - terra::xmin(point1))

    # append to data.frame
    df <- rbind(df, c(treeID, ch_length, radians))
    
  }
  
  # rename columns
  colnames(df)=c("treeID", "ch_length", "ch_orientation")
  
  return(df)
  
  
}