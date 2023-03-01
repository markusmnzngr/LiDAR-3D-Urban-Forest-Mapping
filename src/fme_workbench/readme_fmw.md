# Parameterized 3D tree modeling for CityGML SolitaryVegetationObjects

Creation of CityGML SolitaryVegetationObjects from  parameterized tree positions and prototype tree models. 
3D tree models are created using space-efficient implicit modeling. 
Therefore the geometry of each tree model is stored only once and represented by an anchor point and a transformation matrix that unfolds the trees shape at the given positions. 

## Workflow

* Setup 3D City Database as described in this [tutorial](https://3dcitydb-docs.readthedocs.io/en/release-v4.2.3/intro/index.html)
* Import CityGML data to 3D City Database
  + if necessary, use tiled export to generate smaller tiles
* Run [rasterize roof heights](/src/postgresql/3DCityDB_rasterize_lod2_roof_heights.pgsql) script on database
* Export table to space delimited CSV 

## Required source data 

### Tree positions: 

	- GeoJSON containing parameterized tree positions as points
	- Tree height, crown diameter and x,y,z coordinates are mandatory
	- Crown width and orientation of tree crown enable modelling as ellipsoids
	
### Tree models:

	- Sketchup files with normalized prototypes 
	- Height and diameter of each model are always 1 m  which allows scaling via the transformation matrix
	- Models differ in their ration between crown height and trunk height