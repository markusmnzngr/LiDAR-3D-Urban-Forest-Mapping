# LiDAR-3D-Urban-Forest-Mapping

## Overview
This repository contains scripts for high-resolution area-wide mapping and 3D modeling of urban forests based on LiDAR point clouds. 
The workflow is designed for widely available LiDAR point clouds with a density of at least 4 pts/m² and has been published in this article.
https://doi.org/10.1016/j.ufug.2022.127637
Processing steps: 
 * Classification of the urban forest in an object-based data fusion approach combining the point cloud with multispectral aerial imagery and a 3D building model
 * Detection, segmentation and parameterization of individual tree crowns 
 * efficient reconstruction and 3D modeling of tree crowns using geometric primitives

## Software 
The algorithms for the urban forest classification up to the parameterization of individual tree crowns are implemented as ready-to-use workflow in *R*.
Solely for the last step, the 3D modeling of the trees in the CityGML schema, the proprietary software *FME* from *Safe Software* is used. The FME Workbench created to generate the semantic 3D tree models as well as prototypic 3D tree models are available in this repository.
Gridded building roof heights can be used as supplementary data for the identification of roof points. A *PostgreSQL* script to rasterize roofs heights for 3D city models stored in a 3DCityDB is included in the repository.

