
library(duckdb)
library(duckplyr)

storageBaseURL <- Sys.getenv("CMDDUCKDB")
dataTypes <- c(
    relab = "metaphlan_bugs",
    mrkAb = "marker_abundances",
    mrkPr = "marker_presences"
)
readParquetCommands <- paste0(
    "create view ", names(dataTypes), " as select * from ",
    "read_parquet('", storageBaseURL, dataTypes, ".parquet');"
)

con <- dbConnect(duckdb::duckdb(), ":memory:")

dbExecute(con, "install httpfs;")
dbExecute(con, "load httpfs;")

for (cmd in readParquetCommands) dbExecute(con, cmd)

dbListTables(con)
   
## This takes a lot of time, maybe is better to just
## use SQL queries
relab <- as_duckplyr_tibble(dplyr::tbl(con, "relab"))
mrkPr <- as_duckplyr_tibble(dplyr::tbl(con, "mrkPr"))
mrkAb <- as_duckplyr_tibble(dplyr::tbl(con, "mrkAb"))

res1 <- relab |>
    select(sample_id) |>
    # group_by(sample_id) |>
    summarise(.by = sample_id, bug_count = n()) |>
    arrange(desc(bug_count)) |>
    head(10)
res1

res2 <- relab |>
    filter(sample_id == "SAMN02334067") |>
    select(sample_id, clade_name, relative_abundance) |>
    arrange(desc(relative_abundance)) -> metaphlan_bugs_sample
res2

head(mrkAb)

## This one took about 4 seconds (already cached)
# dbGetQuery(con, paste("select * from", names(dataTypes)[1], "limit 5;"))

## This one took about two minutes (already cached)
# dbGetQuery(con, paste("select * from", names(dataTypes)[2], "limit 5;"))

## This oe workout took about
# dbGetQuery(con, paste("select * from", names(dataTypes)[3], "limit 5;"))

dbDisconnect(con)
