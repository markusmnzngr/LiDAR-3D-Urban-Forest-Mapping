setup 3d city db as described in this tutorial
import citygml data to 3dcitydb
if necessary, use tiled export to generate smaller tiles
run rasterize roof heights script on database
generates roof heights raster


calculation of abolute roof heights in original coordinate system and heights normalized to the ground. 


creates regular point grid for the area covered by roofs 
raster cell size is predefined with 0.5 m, can be changed in cll to create _tmp_raster_params
extrusion of points to vertical lines and intersection with roof geometries
intersection defines roof height at given positions
storage in table with x,y,z values
export to csv

extensions die benötigt werrden:
postgis
postgis_sfcgal


export to space delimited CSV recommended



B:\muenzinger\R_Studio\R_Project_Test\data\tree_prototypes\crown_1_trunk_9.skp,B:\muenzinger\R_Studio\R_Project_Test\data\tree_prototypes\crown_2_trunk_8.skp,B:\muenzinger\R_Studio\R_Project_Test\data\tree_prototypes\crown_3_trunk_7.skp,B:\muenzinger\R_Studio\R_Project_Test\data\tree_prototypes\crown_4_trunk_6.skp,B:\muenzinger\R_Studio\R_Project_Test\data\tree_prototypes\crown_5_trunk_5.skp,B:\muenzinger\R_Studio\R_Project_Test\data\tree_prototypes\crown_6_trunk_4.skp,B:\muenzinger\R_Studio\R_Project_Test\data\tree_prototypes\crown_7_trunk_3.skp,B:\muenzinger\R_Studio\R_Project_Test\data\tree_prototypes\crown_8_trunk_2.skp,B:\muenzinger\R_Studio\R_Project_Test\data\tree_prototypes\crown_9_trunk_1.skp,B:\muenzinger\R_Studio\R_Project_Test\data\tree_prototypes\crown_10_trunk_0.skp