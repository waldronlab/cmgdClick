library(cMDClick)
library(dplyr)

data_types <- c(
    relab = "metaphlan_bugs",
    mkab = "marker_abundances",
    mkpr = "marker_presences"
)

con <- parquet_setup()

system.time({
    parquet_import(con, dataType = data_types, verbose = TRUE)
})

DBI::dbListTables(con)

dplyr::tbl(con, data_types[["relab"]]) |>
    pull(sample_id) |> 
    unique() |> 
    length()

dplyr::tbl(con, data_types[["mkab"]]) |>
    pull(sample_id) |> 
    unique() |> 
    length()

dplyr::tbl(con, data_types[["mkpr"]]) |>
    pull(sample_id) |> 
    unique() |> 
    length()
