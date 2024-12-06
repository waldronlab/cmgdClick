
library(cMDClick)

## Create connection
## config.yml file must exist
setwd("/home/user/Projects/cMDClick")
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

## Get relative abundance, filtering by sample names
relabSamples <- cmdGetRelab(con(), samples = exSamples)
head(relabSamples)

## Get marker abundance data, filtering by marker ids
mAb <- cmdGetMarker(con(), features = exMarkers)
head(mAb)

## Get marker presence data, filtering by sample names
mPr <- cmdGetMarker(con(), samples = exSamples, type = "p")
head(mPr)
