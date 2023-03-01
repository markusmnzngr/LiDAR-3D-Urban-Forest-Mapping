# function to clean up small splinter polygons that may result from watershed segmentation
# takes singlepart polygon features 
# merges small polygons with neighboring polygons that have the longest shared border
# fills interior holes in resulting polygon geometries 

clean_segmentation_results <- function(segments_sp_poly) {
  
  # calculate shared paths between neighboring polys
  shared_paths <- terra::sharedPaths(segments_sp_poly)
  shared_paths$length <- terra::perim(shared_paths)

  # aggregate all paths, duplicate rows and change id order
  shared_paths_dt <- data.table::setDT(terra::as.data.frame(shared_paths))
  # reshape DT with melt to combine
  shared_paths_melt_dt <- data.table::melt(shared_paths_dt, id.vars = c("id2", "id1"), measure.vars = "length")
  shared_paths_melt_dt[, variable := NULL]
  
  shared_paths_duplicated_dt = data.table::rbindlist(list(shared_paths_dt, shared_paths_melt_dt), use.names = FALSE)
  
  # aggregate all shared paths for each polygon 
  aggr_paths_dt <- shared_paths_duplicated_dt[, .(count_neighbors = .N, sum_border_length = sum(length), max_border_length = max(length)), by = "id1"]
  
  # save neighboring ID and length of longest shared path for each polygon
  max_path_dt <- data.table::setDT(shared_paths_duplicated_dt)[, .SD[which.max(length)], by="id1"]
  
  # join data.tables
  paths_analysis_dt <- merge(aggr_paths_dt, max_path_dt, all.x = TRUE, by = "id1")
  data.table::setnames(paths_analysis_dt, c("id1", "id2", "length"), c("obj_id_sp", "longest_border_obj_id", "border_length"))
  
  # join path analysis DT to single part polygons
  # convert polygon attribute table to data.table
  segments_sp_dt <- data.table::setDT(terra::as.data.frame(segments_sp_poly))
  # Identify multipart polygons by counting polygon parts when aggreting by multipart id
  segments_sp_dt[, poly_parts := .N, by = "obj_id_mp"]
  
  # merge attribute tables
  segments_sp_dt <- merge(segments_sp_dt, paths_analysis_dt, all.x = TRUE, by = "obj_id_sp")
  
  # aggregate all polygons by their multipart id 
  # define criteria for aggregation 
  # aggregation of neighboring polygons if: 
  # - area less than 3 m²
  # - has neighbor (count poly parts)
  # - has shared borders and length of border is >= than half of the polygons perimeter
  segments_sp_dt[, obj_id_aggr := data.table::fifelse(area <=3 & poly_parts > 1 & !is.na(border_length) & (max_border_length/perim) >= 0.5, longest_border_obj_id, obj_id_sp)]
  
  # subset attribute table columns to avoid duplicates after join
  segments_sp_dt <- segments_sp_dt[, !c("obj_id_mp", "area", "perim")]
  
  # merge attributes to polygons
  segments_sp_poly <- terra:::merge(segments_sp_poly, as.data.frame(segments_sp_dt), all.x = TRUE, by = "obj_id_sp")
  
  # check for invalid polygons and try to fix them
  terra::is.valid(segments_sp_poly, messages = TRUE, as.points = TRUE)
  segments_sp_poly <- terra::makeValid(segments_sp_poly)
  
  # remove all attributes besides aggregation ID
  segments_sp_poly <- segments_sp_poly[, ("obj_id_aggr")]
  
  # dissolve polygons 
  segments_sp_poly <- terra::aggregate(segments_sp_poly, by = "obj_id_aggr", dissolve = TRUE)
  
  # fill polygon holes
  segments_sp_poly <- terra::fillHoles(segments_sp_poly, inverse = FALSE)
  
  # recalculate area and perim
  segments_sp_poly$area <- terra::expanse(segments_sp_poly, unit = "m", transform = FALSE)
  segments_sp_poly$perim <- terra::perim(segments_sp_poly)
  
  return(segments_sp_poly)
}


