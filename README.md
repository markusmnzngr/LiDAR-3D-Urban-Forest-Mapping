
[![DOI](https://zenodo.org/badge/607566763.svg)](https://zenodo.org/badge/latestdoi/607566763)


# LiDAR-3D-Urban-Forest-Mapping
This repository contains scripts for high-resolution area-wide mapping and 3D modeling of urban forests based on LiDAR point clouds. 
The workflow is designed for widely available LiDAR point clouds with a density of at least 4 pts/m². 

Our published research article:

Münzinger, M., Prechtel, N., & Behnisch, M. (2022). *Mapping the Urban Forest in Detail: From LiDAR Point Clouds to 3D Tree Models.* Available at [https://doi.org/10.1016/j.ufug.2022.127637](https://doi.org/10.1016/j.ufug.2022.127637).

**Processing Tasks:** 

* Task 1: Classification of the urban forest in an object-based data fusion approach combining the point cloud with multispectral aerial imagery and a 3D building model
* Task 2: Detection, segmentation and parameterization of individual tree crowns 
* Task 3: Efficient reconstruction and 3D modeling of tree crowns using geometric primitives


Our published research data for a case study area - city of Dresden (Germany) can be found as.

* [Canopy Height Model](https://zenodo.org/record/7536524)
* [Parameterized Tree Positions](https://zenodo.org/record/7536550)
* [Semantic 3D Tree Model](https://zenodo.org/record/7536562)


## Softwares Description 

* The algorithms for urban forest classification up to the parameterization of individual tree crowns are implemented as [ready-to-use workflow](/src/R/urban-forest-classification-and-individual-crown-parameterization.Rmd) in *R*. Detailed instructions how to set up the workflow environment and run the script are given in [this readme](/src/R/readme_rmd.md).  
* Solely for the last step, the 3D modeling of trees in the CityGML schema, the proprietary software *FME* from *Safe Software* is used. The [FME Workbench](/src/fme_workbench/Create_3D_Tree_Models_geojson2citygml.fmw) created to generate the semantic 3D tree models as well as [prototypic 3D tree models](/data/tree_prototypes) are available in this repository.See [this Readme](/src/fme_workbench/readme_fmw.md) for further information.  
* Gridded building roof heights can be used as supplementary data for the identification of roof points. A *PostgreSQL* script to [rasterize roofs heights](/src/postgresql/3DCityDB_rasterize_lod2_roof_heights.pgsql) for 3D city models stored in a [3D City Database](https://www.3dcitydb.org/3dcitydb/) is included in the repository.Information on how to set up the database and run the script is given in [this readme](/src/postgresql/readme_pgsql.md)

## Key Features
### Urban Forest Classification

<img src="images/classification.jpg" height="400">

The classified point cloud and a canopy height model are generated as output.


### Individual Crown Parameterization

<img src="images/parameterization.jpg" height="400">

Tree positions as point features and crown segments as polygon features are generated as output.


### 3D Tree Modeling

<img src="images/modeling.jpg" height="400">

Tree Models as CityGML Solitary Vegetation Objects are generated as output.


## Input Data
The repository contains [test data](/data) for a small area of Berlin (Germany). 

The supplied data was made freely available by the [“Geoportal Berlin”](https://fbinter.stadt-berlin.de/fb/index.jsp) under the license ["Data license Germany - attribution - Version 2.0"](https://www.govdata.de/dl-de/by-2-0) and can be downloaded at the following links:

* [LiDAR](https://fbinter.stadt-berlin.de/fb/berlin/service_intern.jsp?id=a_als@senstadt&type=FEED)
* [3D Building Model](https://fbinter.stadt-berlin.de/fb/berlin/service_intern.jsp?id=a_lod2@senstadt&type=FEED)
* [Aerial Imagery](https://fbinter.stadt-berlin.de/fb/berlin/service_intern.jsp?id=a_luftbild2020_true_cir@senstadt&type=FEED)

In addition to the LiDAR point cloud, the NDVI as multispectral index and roof heights derived from a 3D building model are used for the urban forest classification.   
Both data sets were prepared from raw data. While calculating the NDVI from multispectral imagery can be done in most GIS environments, GIS ususally have limitations when dealing with 3D city models.  
Therefore, a PostgreSQL script to  [rasterize building roof heights](/src/postgresql/3DCityDB_rasterize_lod2_roof_heights.pgsql) from 3D building models stored in a 3D City Database is also available in this repository.  
The [3D City Database](https://www.3dcitydb.org/3dcitydb/) is an Open Source spatial relational database schema to store, represent, and manage semantic 3D city models in the CityGML schema.

