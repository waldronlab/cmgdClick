.DBDIR_MEMORY <- duckdb:::DBDIR_MEMORY
.STORE_CANCERDATASCI_URL <- "https://store.cancerdatasci.org/cmgd/cMDv4"

#' @title Setup a connection to a DuckDB database with Parquet data
#'
#' @description This function creates a connection to a DuckDB database and
#'   imports Parquet data from <https://store.cancerdatasci.org>.
#'
#' @param db `character(1)` The name of the database file (default:
#'   "cMDClick.duckdb").
#'
#' @param dbdir `character(1)` The directory where the database file is stored
#'   (default: `cMDClickCache()`).
#'
#' @param verbose `logical(1)` Show informative messages in the console
#'   (default: `FALSE`).
#'
#' @importFrom BiocBaseUtils isScalarCharacter isScalarLogical
#'
#' @examples
#' if (interactive()) {
#'     con <- parquet_setup()
#'     parquet_import(con, dataType = "metaphlan_bugs", verbose = TRUE)
#'     DBI::dbListTables(con)
#' }
#' @export
parquet_setup <-
    function(
        db = "cMDClick.duckdb",
        dbdir = cMDClickCache(verbose = verbose),
        verbose = FALSE
    )
{
    stopifnot(isScalarCharacter(db), isScalarCharacter(dbdir))

    if (!identical(dbdir, DBDIR_MEMORY))
        dbdir <- file.path(dbdir, db)
    con <- DBI::dbConnect(duckdb::duckdb(), dbdir = dbdir)

    DBI::dbExecute(con, "install httpfs; load httpfs;")

    con
}

#' @rdname parquet_setup
#'
#' @param con `duckdb_connection` A connection object to a DuckDB database.
#'
#' @param dataType `character()` The type of data to import. Can be one or more
#'   of "metaphlan_bugs", "marker_abundances", or "marker_presences".
#'
#' @export
parquet_import <-
    function(
        con,
        dataType = c("metaphlan_bugs", "marker_abundances", "marker_presences"),
        verbose = FALSE
    )
{
    stopifnot(isScalarLogical(verbose))
    dataType <- match.arg(dataType, several.ok = TRUE)

    for (dt in dataType) {
        file <- file.path(.STORE_CANCERDATASCI_URL, paste0(dt, ".parquet"))
        pq_cmd <- glue::glue(
            "CREATE TABLE {dt} AS SELECT * FROM read_parquet('{file}');"
        )
        if (!dt %in% DBI::dbListTables(con))
            DBI::dbExecute(con, pq_cmd)
        else if (verbose)
            message("Table '", dt, "' already exists in database.")
    }
    con
}

#' @rdname parquet_setup
#'
#' @param cache_dir `character(1)` The directory where the cache is stored.
#'
#' @param ask `logical(1)` Ask the user to create the cache directory if it does
#'   not exist (default: `interactive()`).
#'
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
