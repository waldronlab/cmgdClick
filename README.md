
# `cMDClick`

Package with experiemental functions for fetching curatedMetagenomicData v4
hosted on ClickHouse.

## Installation

1. Download the repo. For example with the GH client:

```bash
gh repo clone waldronlab/cMDClick
```

2. Install cMDClick in R with devetools:

```r
devtools::install_local("<path/to/cMDClick/source", dependencies = TRUE)
```

## config file

Currently, you'll need a **config.yml** file in the home or parent directory of
this project with your credentials.

Make sure that the **config.yml** has been added to the .gitignore file if you
decide to place the **config.yml** file in the home directory.

Example of the contents of the **config.yml** file:

```
default:
  host: "hostAddress"
  user: "yourUserName"
  password: "yourPassword"
  db: "databaseName"
```

## Getting started

``` r
library(cMDClick)

## Create connection
## config.yml file must exist
con <- function() {
    DBI::dbConnect(
        drv = ClickHouseHTTP::ClickHouseHTTP(),
        port = 8443,
        https = TRUE,
        host = config::get()$host,
        user = config::get()$user,
        password = config::get()$password,
        dbname = config::get()$db
    )
}

## Get relative abundance, filtering by ncbi ids
relabFeatures <- cmdGetRelab(con(), features = exTaxa)
head(relabFeatures)
#> # A tibble: 6 × 4
#>   relab sample         metaphlan                                           ncbi 
#>   <dbl> <chr>          <chr>                                               <chr>
#> 1 0.590 SAMEA103958113 k__Bacteria|p__Proteobacteria|c__Gammaproteobacter… 562  
#> 2 0.424 SAMEA103958114 k__Bacteria|p__Firmicutes|c__Bacilli|o__Lactobacil… 1301 
#> 3 0.792 SAMEA103958116 k__Bacteria|p__Firmicutes|c__Bacilli|o__Lactobacil… 1301 
#> 4 1.31  SAMEA103958116 k__Bacteria|p__Proteobacteria|c__Gammaproteobacter… 562  
#> 5 7.66  SAMEA103958117 k__Bacteria|p__Proteobacteria|c__Gammaproteobacter… 562  
#> 6 0.634 SAMEA103958120 k__Bacteria|p__Proteobacteria|c__Gammaproteobacter… 562

## Get relative abundance, filtering by sample names
relabSamples <- cmdGetRelab(con(), samples = exSamples)
head(relabSamples)
#> # A tibble: 6 × 4
#>     relab sample         metaphlan                      ncbi  
#>     <dbl> <chr>          <chr>                          <chr> 
#> 1 100     SAMEA103958109 k__Bacteria                    2     
#> 2  82.3   SAMEA103958109 k__Bacteria|p__Firmicutes      1239  
#> 3   8.02  SAMEA103958109 k__Bacteria|p__Bacteroidota    976   
#> 4   7.91  SAMEA103958109 k__Bacteria|p__Actinobacteria  201174
#> 5   1.25  SAMEA103958109 k__Bacteria|p__Proteobacteria  1224  
#> 6   0.542 SAMEA103958109 k__Bacteria|p__Verrucomicrobia 74201

## Get marker abundance data, filtering by marker ids
mAb <- cmdGetMarker(con(), features = exMarkers)
head(mAb)
#> # A tibble: 6 × 3
#>   sample         feature                                abundance
#>   <chr>          <chr>                                      <dbl>
#> 1 SAMEA103958109 UniClust90_GMEPEMOD01001|1__4|SGB72336      2.04
#> 2 SAMEA103958109 UniClust90_MABEGJKF00110|1__5|SGB72336      1.56
#> 3 SAMEA103958109 UniClust90_HPNJJKHE00621|1__5|SGB72336      1.56
#> 4 SAMN02334111   UniClust90_GMEPEMOD01001|1__4|SGB72336      1.99
#> 5 SAMEA2580118   UniClust90_GMEPEMOD01001|1__4|SGB72336      3.97
#> 6 SAMEA2580118   UniClust90_MABEGJKF00110|1__5|SGB72336      1.53

## Get marker presence data, filtering by sample names
mPr <- cmdGetMarker(con(), samples = exSamples, type = "p")
head(mPr)
#> # A tibble: 6 × 3
#>   sample         feature                                presence
#>   <chr>          <chr>                                  <lgl>   
#> 1 SAMEA103958109 UniClust90_GMEPEMOD01001|1__4|SGB72336 TRUE    
#> 2 SAMEA103958109 UniClust90_MABEGJKF00110|1__5|SGB72336 TRUE    
#> 3 SAMEA103958109 UniClust90_HPNJJKHE00621|1__5|SGB72336 TRUE    
#> 4 SAMEA103958109 UniClust90_HPNJJKHE00452|1__5|SGB72336 TRUE    
#> 5 SAMEA103958109 UniClust90_CMOGDLIK00233|1__4|SGB72336 TRUE    
#> 6 SAMEA103958109 UniClust90_CMOGDLIK00463|1__7|SGB72336 TRUE
```
<sup>Created on 2024-12-06 with [reprex v2.1.1](https://reprex.tidyverse.org)</sup>
