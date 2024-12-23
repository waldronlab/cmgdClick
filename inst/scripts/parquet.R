
# library(duckdb)
library(DBI)
library(duckplyr)

# cmdConnect <- function(types = "relative_abundance") {
cmdConnect <- function() {
    dataOptions <- c(
        relative_abundance = "metaphlan_bugs",
        marker_abundance = "marker_abundances",
        marker_presence = "marker_presences"
    )
    # dataTypes <- dataOptions[types]
    dataTypes <- dataOptions
    
    # storageBaseURL <- Sys.getenv("CMDDUCKDB")
    storageBaseURL <- "https://store.cancerdatasci.org/cmgd/cMDv4/"
    readParquetCommands <- paste0(
        "create view ", names(dataTypes), " as select * from ",
        "read_parquet('", storageBaseURL, dataTypes, ".parquet');"
    )
    
    con <- DBI::dbConnect(duckdb::duckdb(), ":memory:")
    
    DBI::dbExecute(con, "install httpfs;")
    DBI::dbExecute(con, "load httpfs;")
    
    for (cmd in readParquetCommands) DBI::dbExecute(con, cmd)
    return(con)
}

con <- cmdConnect()

dbListTables(con)

relab <- as_duckplyr_tibble(dplyr::tbl(con, "relative_abundance"))

## This function only works if the package is loaded
relabFeatures <- cmdGetRelab(con, features = exTaxa)

# system.time({
#     mrkAb <- as_duckplyr_tibble(dplyr::tbl(con, "marker_abundance"))
# })
# 


relab |> 
    filter(grepl("\\|562$", tax_id_string)) |> 
    head() 
    # filter(tax_id_string %in% exTaxa)



unique(relab$tax_id_string)


## Probably use this code for in sql query
## SELECT *
# FROM relab
# WHERE tax_id_string LIKE '%|562'
# LIMIT 6;



# ra <- dplyr::tbl(con, "relative_abundance")
# mrkPr <- as_duckplyr_tibble(dplyr::tbl(con, "mrkPr"))
# mrkAb <- as_duckplyr_tibble(dplyr::tbl(con, "mrkAb"))

# res1 <- relab |>
#     select(sample_id) |>
#     # group_by(sample_id) |>
#     summarise(.by = sample_id, bug_count = n()) |>
#     arrange(desc(bug_count)) |>
#     head(10)
# res1
# 
# res2 <- relab |>
#     filter(sample_id == "SAMN02334067") |>
#     select(sample_id, clade_name, relative_abundance) |>
#     arrange(desc(relative_abundance)) -> metaphlan_bugs_sample
# res2
# 
# head(mrkAb)

## This one took about 4 seconds (already cached)
# dbGetQuery(con, paste("select * from", names(dataTypes)[1], "limit 5;"))

## This one took about two minutes (already cached)
# dbGetQuery(con, paste("select * from", names(dataTypes)[2], "limit 5;"))

## This oe workout took about
# dbGetQuery(con, paste("select * from", names(dataTypes)[3], "limit 5;"))

dbDisconnect(con)
