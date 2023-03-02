# Setting up the workflow fo urban forest classification and individual crown parameterization

The *R*-workflow for urban forest classification and individual crown parameterization is implemented as a standalone script containing the individual processing steps and generating output files for the results.

## Prerequisites

* Up-to-date installation of [R](https://cran.r-project.org/index.html) (≥ 3.5.0)
* Installation of [RTools](https://cran.r-project.org/bin/windows/Rtools/) for building R packages
* IDE like [RStudio](https://support--rstudio-com.netlify.app/products/rstudio/) might be helpful

## Setup instructions

* Fork the repository from GitHub
* Open the [RStudio project file](/LiDAR-3D-Urban-Forest-Mapping.Rproj) to start a new R session and set the working directory to the project directory
* In RStudio open the [R Markdown file](/src/R/urban-forest-classification-and-individual-crown-parameterization.Rmd)
* Run either the complete script or individual chunks of code
* The first chunk of codes checks if all required packages are installed 
  + If the installation causes trouble, you might try a stepwise installation of the required packages
* The second chunk of code defines the input paths
  + By default, the paths point to the supplied [test data](/data/readme_data.md)
* The third chunk of code sets the workflow variables
  + Variables may need adjustment according to input LiDAR data specifications or the available multispectral image
* By default, the output paths point to the [results directory](/results)

