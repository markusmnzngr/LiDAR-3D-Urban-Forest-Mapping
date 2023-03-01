-- select all roof geometries to new table 
drop table if exists tmp_roof_geoms;

create temp table tmp_roof_geoms as
select ts.id as ts_cityobject_id, ts.building_id as ts_building_id, ts.lod2_multi_surface_id as ts_lod2_multi_surface_id, 
sg.id as sg_id, sg.root_id as sg_root_id, sg.geometry as geom
from thematic_surface ts
inner join surface_geometry sg
on ts.id = sg.cityobject_id
where ts.objectclass_id = 33 and  sg.geometry is not null ;

-- select all ground geometries to new table and calculate z_values
drop table if exists tmp_ground_geoms;
create temp table tmp_ground_geoms as
select ts.id as ts_cityobject_id, ts.building_id as ts_building_id, ts.lod2_multi_surface_id as ts_lod2_multi_surface_id, 
sg.id as sg_id, sg.root_id as sg_root_id, sg.geometry as geom, st_zmax(sg.geometry) as z_max, st_zmin(sg.geometry) as z_min
from thematic_surface ts
inner join surface_geometry sg
on ts.id = sg.cityobject_id
where ts.objectclass_id = 35 and  sg.geometry is not null ;

alter table tmp_roof_geoms
add column z_ground double precision;

-- calculate bldg_ground height for each roof
update tmp_roof_geoms
set z_ground = (z_max + z_min)/2
from tmp_ground_geoms
where tmp_roof_geoms.ts_building_id = tmp_ground_geoms.ts_building_id;

-- add spatial index
create index tmp_roof_geoms_geom_idx
  on tmp_roof_geoms
  using GIST (geom);

-- delete duplicate geometries
drop table if exists tmp_roof_geoms_unique; 
create temp table tmp_roof_geoms_unique as 
with unique_geoms (id, ts_cityobject_id, geom) as (
    select
        row_number() over (partition by ST_AsBinary(geom)) as id,
        ts_cityobject_id, geom
    from tmp_roof_geoms
    )
select
    ts_cityobject_id, geom
from
    unique_geoms 
where
    id=1;

-- add extra vertices to polygons to avoid triangulation errors for long and thin polygons
drop table if exists tmp_roof_geoms_segmentize;
create temp table tmp_roof_geoms_segmentize as
select ts_cityobject_id, st_segmentize(geom, 20) as geom 
from tmp_roof_geoms_unique;

-- add spatial index
drop index if exists tmp_roof_geoms_segmentize_geom_idx;
create index tmp_roof_geoms_segmentize_geom_idx
  on tmp_roof_geoms_segmentize
  using GIST (geom);

-- store bounding box extents in new table
-- extend bounding box with buffer size 
drop table if exists tmp_bbox;
create temp table tmp_bbox as
select st_xmax(ST_3DExtent(geom)) as x_max, 
round(st_xmax(ST_3DExtent(geom))) + 1 as x_max_grid, 
st_xmin(ST_3DExtent(geom)) as x_min,
round(st_xmin(ST_3DExtent(geom))) - 1 as x_min_grid, 
st_ymax(ST_3DExtent(geom)) as y_max,
round(st_ymax(ST_3DExtent(geom))) + 1 as y_max_grid, 
st_ymin(ST_3DExtent(geom)) as y_min,
round(st_ymin(ST_3DExtent(geom))) - 1 as y_min_grid,
st_zmax(ST_3DExtent(geom)) as z_max, 
round(st_zmax(ST_3DExtent(geom))) + 1 as z_max_grid, 
st_zmin(ST_3DExtent(geom)) as z_min,
round(st_zmin(ST_3DExtent(geom))) - 1 as z_min_grid
from tmp_roof_geoms_segmentize;

-- derive maximum extents
alter table tmp_bbox
add column delta_x_grid int,
add column delta_y_grid int;

update tmp_bbox
set delta_x_grid = x_max_grid - x_min_grid,
delta_y_grid = y_max_grid - y_min_grid;

-- declare cell size as variables
drop table if exists tmp_raster_parameters;
create temp table tmp_raster_parameters as                                     
with t (cell_size, raster_width_x, raster_width_y) as (
 values
 (0.5::numeric, 99999::int,  99999::int)
)
select * from t;

-- 
update tmp_raster_parameters
set raster_width_x = (select delta_x_grid from tmp_bbox)*(1/cell_size),
raster_width_y = (select delta_y_grid from tmp_bbox)*(1/cell_size);

-- create empty raster with derived extents
drop table if exists tmp_grid;
create temp table tmp_grid as 
select st_addband(ST_MakeEmptyRaster((select raster_width_x from tmp_raster_parameters), (select raster_width_y from tmp_raster_parameters), 
(select x_min_grid from tmp_bbox), (select y_min_grid from tmp_bbox), 
0.5, 0.5, 0, 0,(select st_srid(geom) from tmp_roof_geoms limit 1)), array[row(1, '8BUI'::text, 6, 255)]::addbandarg[]) as rast;

-- raster in kleine kacheln konvertieren
drop table if exists tmp_grid_tiled;
create temp table tmp_grid_tiled as
select ST_Tile(rast, 1, 50, 50) as rast 
from tmp_grid;																  
																		  
-- convert raster to points
drop table if exists tmp_grid_points;
create temp table tmp_grid_points as
select (ST_PixelAsCentroids(rast, 1, TRUE)).geom
from tmp_grid_tiled;

-- add spatial index
create index tmp_grid_points_geom_idx
  on tmp_grid_points
  using GIST (geom);

--intersect points with roof surfaces in 2d
drop table if exists tmp_roof_points;
create temp table tmp_roof_points as
select tmp_grid_points.geom, tmp_roof_geoms_segmentize.ts_cityobject_id 
from tmp_grid_points,tmp_roof_geoms_segmentize
where st_intersects(tmp_grid_points.geom, tmp_roof_geoms_segmentize.geom);

-- create vertical lines for all point positions that intersect with roof geometries
-- vertical extent from roofs bounding box
drop table if exists tmp_lines;
create temp table tmp_lines as
select ts_cityobject_id, ST_SetSRID(ST_MakeLine(ST_MakePoint(ST_X(geom),ST_Y(geom), (select z_min_grid from tmp_bbox)), ST_MakePoint(ST_X(geom),ST_Y(geom), (select z_max_grid from tmp_bbox))), (select st_srid(rast) from tmp_grid)) as geom 
from tmp_roof_points;

-- add spatial index
drop index if exists tmp_lines_geom_idx;
create index tmp_lines_geom_idx
  on tmp_lines
  using GIST(geom);

-- intersect with original roof polygons fails if they are not planar 
-- conversion to tin without surface_tolarance
drop table if exists tmp_tin_roofs;
create temp table tmp_tin_roofs as
select ts_cityobject_id, st_delaunaytriangles(geom, 0.0, 0) as geom 
from tmp_roof_geoms_segmentize;

-- add spatial index
drop index if exists tmp_tin_roofs_geom_idx;
create index tmp_tin_roofs_geom_idx
  on tmp_tin_roofs
  using GIST (geom);

-- subdivide tin to smaller junks
drop table if exists tmp_tin_roofs_subdivide;
create temp table tmp_tin_roofs_subdivide as
select ts_cityobject_id, st_subdivide(geom, 20) as geom 
from tmp_tin_roofs;

-- add spatial index
drop index if exists tmp_tin_roofs_subdivide_geom_idx;
create index tmp_tin_roofs_subdivide_geom_idx
  on tmp_tin_roofs_subdivide
  using GIST (geom);

-- 3d intersect between tin and lines
drop table if exists tmp_intersection;
create temp table tmp_intersection as
select tmp_lines.ts_cityobject_id, st_3dintersection(tmp_lines.geom, tmp_tin_roofs_subdivide.geom) as geom
from tmp_tin_roofs_subdivide
join tmp_lines 
on st_3dintersects(tmp_lines.geom, tmp_tin_roofs_subdivide.geom) and tmp_lines.ts_cityobject_id = tmp_tin_roofs_subdivide.ts_cityobject_id;

-- add spatial index
create index tmp_intersection_geom_idx
  on tmp_intersection
  using GIST (geom);

-- add xyz columns
alter table tmp_intersection 
add column x float,
add column y float,
add column z_nn float,
add column z_ground float;

-- retrieve z-value of intersecting point
update tmp_intersection
set x = st_x(geom), 
y = st_y(geom), 
z_nn = round(cast(st_z(geom) as numeric), 2);

-- calculate height relative to ground
update tmp_intersection
SET z_ground = round(cast((tmp_intersection.z_nn - tmp_roof_geoms.z_ground) as numeric), 2) 
FROM tmp_roof_geoms
WHERE tmp_intersection.ts_cityobject_id = tmp_roof_geoms.ts_cityobject_id;

-- aggregate by x and y to delete overlapping roof parts 
drop table if exists _lod2_roof_heights;
create table _lod2_roof_heights as
select x,y, max(z_nn) as z_nn, max(z_ground) as z_ground
from tmp_intersection
group by x,y
order by x,y;