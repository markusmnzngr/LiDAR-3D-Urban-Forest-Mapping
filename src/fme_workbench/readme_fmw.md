# Parameterized 3D tree modeling for CityGML SolitaryVegetationObjects

Creation of CityGML SolitaryVegetationObjects from  parameterized tree positions and prototype tree models. 
3D tree models are created using space-efficient implicit modeling. 
Therefore the geometry of each tree model is stored only once and represented by an anchor point and a transformation matrix that unfolds the trees shape at the given positions. 

## Workflow

* Open [FME Workbench](/src/fme_workbench/Create_3D_Tree_Models_geojson2citygml.fmw)
* Specify source data paths
  + Select the parameterized tree positions. [Example test data](/results/parameterized_tree_crowns/tree_positions_parameterized.geojson)
  + Select all [tree model prototypes](/data/tree_prototypes)
* Define output path for CityGML-file
* Run the workbench 

## Required source data 

### Tree positions: 

* GeoJSON containing parameterized tree positions as points
* Tree height, crown diameter and x,y,z coordinates are mandatory
*	Crown width and orientation of tree crown enable modelling as ellipsoids
	
### Tree models:

* Sketchup files with normalized prototypes 
* Height and diameter of each model are always 1 m  which allows scaling via the transformation matrix
* Models differ in their ration between crown height and trunk height