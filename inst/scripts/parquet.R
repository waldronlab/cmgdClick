library(duckdb)
library(dplyr)

## Parquet files
storageBaseURL <- Sys.getenv("CMDDUCKDB")
dataTypes <- c(
    relab = "metaphlan_bugs",
    markAb = "marker_abundances",
    markPr = "marker_presences"
)
readParquetCommands <- paste0(
    "create view ", names(dataTypes), " as select * from ",
    "read_parquet('", storageBaseURL, dataTypes, ".parquet');"
)

con <- dbConnect(duckdb::duckdb(), ":memory:")

dbExecute(con, "install httpfs;")
dbExecute(con, "load httpfs;")

tim <- system.time({
    for (i in seq_along(dataTypes)) {
        dbExecute(con, readParquetCommands[i])
    }
})
## Running these three took about three minutes (not the first time)

dbListTables(con)

## This one took about 4 seconds (already cached)
dbGetQuery(con, paste("select * from", names(dataTypes)[1], "limit 5;"))

## This one took about two minutes (already cached)
dbGetQuery(con, paste("select * from", names(dataTypes)[2], "limit 5;"))

    ## This oe workout took about
dbGetQuery(con, paste("select * from", names(dataTypes)[3], "limit 5;"))


    
    
    
## This step seems to take a while
relab <- tbl(con, "relab")

# metaphlan_bugs |>
#     select(sample_id) |>
#     group_by(sample_id) |>
#     summarise(bug_count = n()) |>
#     arrange(desc(bug_count)) |>
#     head(10)
# 
# metaphlan_bugs |>
#     filter(sample_id == "SAMN02334067") |>
#     select(sample_id, clade_name, relative_abundance) |>
#     arrange(desc(relative_abundance)) -> metaphlan_bugs_sample
# 
# head(metaphlan_bugs_sample, 50)



dbDisconnect(con)
