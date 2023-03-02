# Test Data

The supplied data for a small test area in Berlin is structured in 3 directories. 

[Raw](/data/raw) contains the 3 input data products as they are usually available.

* LiDAR point cloud
* Multispectral aerial imagery
* 3D building model (LoD2)

[Processed](/data/processed) contains products derived from the input data.
* Multispectral aerial imagery -> NDVI
* 3D building model (LoD2) -> Gridded roof heights

[Tree Prototype](/data/tree_prototypes) contains 10 pre-defined tree prototypes.   

All of them are normalized to a height/width/depth of 1 m. In this way they can be scaled individually depending on specific parameters.  
The prototypes differ in their ratio of crown height to trunk height. The variety ranges from only crown to almost exclusively trunk. 

## Data License
The supplied data was made freely available by the [“Geoportal Berlin”](https://fbinter.stadt-berlin.de/fb/index.jsp) under the license ["Data license Germany - attribution - Version 2.0"](https://www.govdata.de/dl-de/by-2-0) and can be downloaded at the following links:

* [LiDAR](https://fbinter.stadt-berlin.de/fb/berlin/service_intern.jsp?id=a_als@senstadt&type=FEED)
* [3D Building Model](https://fbinter.stadt-berlin.de/fb/berlin/service_intern.jsp?id=a_lod2@senstadt&type=FEED)
* [Aerial Imagery](https://fbinter.stadt-berlin.de/fb/berlin/service_intern.jsp?id=a_luftbild2020_true_cir@senstadt&type=FEED)
