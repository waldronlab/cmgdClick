
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

con <- function() {
    DBI::dbConnect(
        drv = ClickHouseHTTP::ClickHouseHTTP(),
        port = 8443,
        https = TRUE,
        host = keyring::key_get("cmd-host"),
        user = keyring::key_get("cmd-user"),
        password = keyring::key_get("cmd-password"),
        dbname = keyring::key_get("cmd-db")
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
