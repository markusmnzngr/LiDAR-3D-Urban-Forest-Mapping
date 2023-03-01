# Rasterize roof heights 
Creation of building roof heights raster from semantic 3D city models.   
Roof heights are calculated as absolute height value as well as normalized to the ground. 

## Algorithm description

* Creation of regular point grid for the area covered by roofs 
  + Raster cell size is predefined with 0.5 m, can be changed in temporary table *tmp_raster_parameters*
* Conversion of cell centroids to points
* Extrusion of points to vertical lines and 
* Intersection between vertical lines and roof geometries
* Intersection results in points with roof height at given positions
* Storage of intersection points as table with x,y,z-values


## Workflow

* Setup 3D City Database as described in this [tutorial](https://3dcitydb-docs.readthedocs.io/en/release-v4.2.3/intro/index.html)
* [Import](https://3dcitydb-docs.readthedocs.io/en/release-v4.2.3/impexp/index.html) CityGML data to 3D City Database
  + if necessary, use tiled export to generate smaller tiles
* Run [rasterize roof heights](/src/postgresql/3DCityDB_rasterize_lod2_roof_heights.pgsql) script on database
* Export table to space delimited CSV 

## Requirements

* 3D building model stored in a 3D City Database instance
* PostgreSQL database extensions *postgis* and *postgis_sfcgal*

