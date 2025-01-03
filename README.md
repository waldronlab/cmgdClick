
# `cMDClick`

Package with experimental functions for fetching curatedMetagenomicData
v4 data hosted on ClickHouse.

# Installation

Note that `cMDClick` uses `odbc` and `DBI` to connect to ClickHouse.
Ensure that the `odbc` drivers are installed for your operating system.
See <https://clickhouse.com/docs/en/interfaces/odbc> for more details.

Installation of the R package from the GitHub repository:

``` r
remotes::install_github("waldronlab/cMDClick")
```

# Credentials

Credentials are required to access the database. They can be stored in a
`config.yml` file and then used by the
[config](https://github.com/rstudio/config/) R package. The `config.yml`
file should be in the working or home directory.

Example of the contents of the `config.yml` file:

``` yml
default:
  host: "hostAddress"
  user: "yourUserName"
  port: 8123
  password: "yourPassword"
  db: "databaseName"
```

Alternatively, the credentials can be stored using an `.odbc.ini` file
in the home directory. The file should have the following format:

    [ClickHouseDSN]
    Driver=ClickHouse
    Description=ClickHouse DSN
    Server=localhost
    Port=1234
    Database=default
    UID=default
    PWD=foo

# Getting started

``` r
library(cMDClick)
```

The `clickhouse_connect` function establishes a connection to the
database for querying. The function returns a `ClickHouse`
`OdbcConnection` object to be used in the other functions.

``` r
con <- clickhouse_connect()
con
#' <OdbcConnection> user@localhost
#'   Database: default
#'   ClickHouse Version: 01.00.0000
```

## Querying the database

`cMDClick` provides functions to query the curatedMetagenomicData v4
database hosted on ClickHouse. The `cMDGetRelab` function retrieves the
relative abundance of the features in the database.

In this example, the `exTaxa` object is a character vector with the NCBI
ids of the features to be queried.

``` r
## Get relative abundance, filtering by ncbi ids
relabFeatures <- cMDGetRelab(con, features = exTaxa)
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
```

Here `exSamples` is a character vector with the sample identifiers used
to filter records in the database.

``` r
## Get relative abundance, filtering by sample names
relabSamples <- cMDGetRelab(con, samples = exSamples)
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
```

The `cMDGetMarker` function retrieves the abundance of the markers in
the database and the `features` argument allows one to filter by marker
identifiers.

``` r
## Get marker abundance data, filtering by marker ids
mAb <- cMDGetMarker(con, features = exMarkers)
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
```

The `samples` argument allows one to filter by sample identifiers.

``` r
## Get marker presence data, filtering by sample names
mPr <- cMDGetMarker(con, samples = exSamples, type = "p")
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

## Using curatedMetagenomicData v4 Parquet data

The `cMDClick` package can leverage data stored in the Parquet format.
It makes use of parquet files located at the package data repository
<https://store.cancerdatasci.org/cmgd/cMDv4>.

### Importing data

The `parquet_setup` function creates a connection to the database and
the `parquet_import` function imports the data into the database. The
`dataType` argument specifies the type of data to import.

``` r
con <- parquet_setup()
parquet_import(con, dataType = "metaphlan_bugs", verbose = TRUE)
#> <duckdb_connection 1f340 driver=<duckdb_driver dbdir='/home/user/.cache/R/cMDClick/cMDClick.duckdb' read_only=FALSE bigint=numeric>>
```

### Querying the data

``` r
DBI::dbListTables(con)
#> [1] "marker_abundances" "marker_presences"  "metaphlan_bugs"
dplyr::tbl(con, "metaphlan_bugs") |>
    dplyr::filter(tax_id_string == "2|1239||||")
#> # Source:   SQL [?? x 7]
#> # Database: DuckDB v1.1.3 [user@Linux 6.8.0-50-generic:R 4.5.0//home/user/.cache/R/cMDClick/cMDClick.duckdb]
#>    `_path`    cmgd_version sample_id clade_name tax_id_string relative_abundance
#>    <chr>      <chr>        <chr>     <chr>      <chr>                      <dbl>
#>  1 cmgd-data… cMDv4        SAMEA258… k__Bacter… 2|1239||||               0.00476
#>  2 cmgd-data… cMDv4        SAMEA258… k__Bacter… 2|1239||||               0.0162 
#>  3 cmgd-data… cMDv4        SAMEA258… k__Bacter… 2|1239||||               0.00683
#>  4 cmgd-data… cMDv4        SAMEA110… k__Bacter… 2|1239||||               0.00652
#>  5 cmgd-data… cMDv4        SAMEA257… k__Bacter… 2|1239||||               0.00305
#>  6 cmgd-data… cMDv4        SAMEA257… k__Bacter… 2|1239||||               0.0107 
#>  7 cmgd-data… cMDv4        SAMEA257… k__Bacter… 2|1239||||               0.384  
#>  8 cmgd-data… cMDv4        SAMEA258… k__Bacter… 2|1239||||               0.0532 
#>  9 cmgd-data… cMDv4        SAMEA258… k__Bacter… 2|1239||||               0.0888 
#> 10 cmgd-data… cMDv4        SAMEA258… k__Bacter… 2|1239||||               0.145  
#> # ℹ more rows
#> # ℹ 1 more variable: additional_species <chr>
```

# Session Info

``` r
sessionInfo()
#> R Under development (unstable) (2024-11-01 r87285)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Ubuntu 22.04.5 LTS
#> 
#> Matrix products: default
#> BLAS:   /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.10.0 
#> LAPACK: /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.10.0
#> 
#> locale:
#>  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
#>  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
#>  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
#>  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
#>  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
#> [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
#> 
#> time zone: America/New_York
#> tzcode source: system (glibc)
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] cMDClick_0.99.8
#> 
#> loaded via a namespace (and not attached):
#>  [1] digest_0.6.37       R6_2.5.1            codetools_0.2-20   
#>  [4] BiocBaseUtils_1.9.0 fastmap_1.2.0       tidyselect_1.2.1   
#>  [7] xfun_0.49           magrittr_2.0.3      glue_1.8.0         
#> [10] tibble_3.2.1        knitr_1.49          pkgconfig_2.0.3    
#> [13] htmltools_0.5.8.1   generics_0.1.3      rmarkdown_2.29     
#> [16] dplyr_1.1.4         lifecycle_1.0.4     cli_3.6.3          
#> [19] vctrs_0.6.5         compiler_4.5.0      rstudioapi_0.17.1  
#> [22] tools_4.5.0         pillar_1.10.0       evaluate_1.0.1     
#> [25] yaml_2.3.10         BiocManager_1.30.25 rlang_1.1.4
```
