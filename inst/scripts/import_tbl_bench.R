library(cMDClick)
library(dplyr)
library(dbplyr)

unlink(cMDClickCache(), recursive = TRUE)
con <- parquet_setup()
## check the local cache for downloaded tables
DBI::dbListTables(con)

microbenchmark::microbenchmark(
    {
        con <- parquet_setup()
        parquet_import(con, dataType = "metaphlan_bugs", verbose = TRUE)
        dplyr::tbl(con, "metaphlan_bugs") |>
            dplyr::filter(tax_id_string == "2|1239||||") |>
            dplyr::collect()
    },
    {
        con <- parquet_setup()
        parquet_tbl(con, "metaphlan_bugs") |>
            dplyr::filter(tax_id_string == "2|1239||||") |>
            dplyr::collect()
    },
    times = 10L
)

DBI::dbDisconnect(con)
