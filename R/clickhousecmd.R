
library(DBI)
library(dplyr)
library(config)

## Create connection
# con <- dbConnect(
#     drv = ClickHouseHTTP::ClickHouseHTTP(),
#     port = 8443,
#     https = TRUE,
#     host = get()$host,
#     user = get()$user,
#     password = get()$password,
#     dbname = get()$db
# )

## A function might be better since the connections ends too quickly
con <- function() {
    dbConnect(
        drv = ClickHouseHTTP::ClickHouseHTTP(),
        port = 8443,
        https = TRUE,
        host = get()$host,
        user = get()$user,
        password = get()$password,
        dbname = get()$db
    )
}

## Tables
tbls <- con() |> 
    dbListTables() |> 
    as_tibble()
tbls

## Number of bugs
bugs <- con() |> 
    dbGetQuery(
    "
        SELECT COUNT(*) AS bugs, presence, sample_id
        FROM src_cmgd_v4__marker_presence
        WHERE presence = true
        GROUP BY ALL
        ORDER BY bugs DESC
        LIMIT 100
    "
    ) |> 
    as_tibble()
bugs

## Bioconductor query
bioc <- con() |> 
    dbGetQuery(
    "
        SELECT COUNT(*) AS n
        FROM src_pubmed
        WHERE (abstract ILIKE '%bioconductor%') OR (title ILIKE '%bioconductor%')
    "
    ) |> 
    as_tibble()
bioc

## Split by year
by_year <- con() |> 
    dbGetQuery(
    "
        SELECT
            splitByChar('-', coalesce(pubdate, ''))[1] AS year,
            COUNT(*) AS n
        FROM src_pubmed
        WHERE (abstract ILIKE '%bioconductor%') OR (title ILIKE '%bioconductor%')
        GROUP BY year
        ORDER BY year DESC
    "
) |> 
    as_tibble()

## Relative abundance data
con() |> 
    dbListFields("src_cmgd_v4__marker_abundance")
relab <- con() |> 
    dbGetQuery(
    "
        SELECT sample_id, marker_id, abundance
        FROM src_cmgd_v4__marker_abundance
        ORDER BY abundance DESC
        LIMIT 100
    "
) |> 
    as_tibble()
relab

## Studies?
con() |> 
    dbListFields("src_pubmed")

studies <- con() |> 
    dbGetQuery(
    "
        SELECT COUNT(*) AS n, pmid
        FROM src_pubmed
        GROUP BY pmid
        ORDER BY n DESC
        LIMIT 100
    "
    ) |> 
    as_tibble()
studies

## Disconnect
# dbDisconnect(con())

