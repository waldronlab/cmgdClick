.DBDIR_MEMORY <- duckdb:::DBDIR_MEMORY
.STORE_CANCERDATASCI_URL <- "https://store.cancerdatasci.org/cmgd/cMDv4"

#' @export
parquet_setup <- function(db = "cMDClick.duckdb", dbdir = cMDClickCache()) {

    if (!identical(dbdir, DBDIR_MEMORY))
        dbdir <- file.path(dbdir, db)
    con <- DBI::dbConnect(duckdb::duckdb(), dbdir = dbdir)

    DBI::dbExecute(con, "install httpfs; load httpfs;")

    con
}

#' @export
parquet_import <-
    function(
        con,
        dataType = c("metaphlan_bugs", "marker_abundances", "marker_presences"),
        verbose = FALSE
    )
{
    dataType <- match.arg(dataType, several.ok = TRUE)

    for (dt in dataType) {
        file <- file.path(.STORE_CANCERDATASCI_URL, paste0(dt, ".parquet"))
        pq_cmd <- glue(
            "CREATE TABLE {dt} AS SELECT * FROM read_parquet('{file}');"
        )
        if (!dt %in% DBI::dbListTables(con))
            DBI::dbExecute(con, pq_cmd)
        else if (verbose)
            message("Table '", dt, "' already exists in database.")
    }
    con
}

#' @export
cMDClickCache <-
    function(
        cache_dir = getOption(
            "cMDClickCache",
            tools::R_user_dir("cMDClick", "cache")
        ),
        verbose = TRUE,
        ask = interactive()
    )
{
    stopifnot(isScalarCharacter(cache_dir))

    if (!dir.exists(cache_dir)) {
        if (ask) {
            qtxt <- sprintf(
                "Create cMDClick cache at \n    %s? [y/n]: ",
                cache_dir
            )
            answer <- .getAnswer(qtxt, allowed = c("y", "Y", "n", "N"))
            if (identical(answer, "n"))
                stop("'cMDClickCache' cache_dir not created. Use 'setCache'")
        }
        dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
    }
    options(cMDClickCache = cache_dir)

    if (verbose)
        message("cMDClick 'cache_dir' set to:\n    ", cache_dir)

    invisible(cache_dir)
}

.getAnswer <- function(msg, allowed)
{
    if (interactive()) {
        repeat {
            message(msg)
            answer <- readLines(n = 1)
            if (answer %in% allowed)
                break
        }
        tolower(answer)
    } else {
        "n"
    }
}
