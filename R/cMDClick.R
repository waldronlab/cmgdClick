
#' Get marker data
#' 
#' \code{cmdGetMarker} gets data related to marker abundance or presence.
#'
#' @param con A connection created with DBI.
#' @param features A `character` vector with marker ids.
#' @param samples A `character` vector with sample names.
#' @param type A `character(1)` vector. One of two options: "`abundance`" or
#' "`presence`".
#'
#' @return A data.frame.
#' @export
#' 
#' @seealso [cmdGetRelab()]
#' @examples
#' 
#' \dontrun{
#' 
#' con <- function() {
#'     DBI::dbConnect(
#'         drv = ClickHouseHTTP::ClickHouseHTTP(),
#'         port = 8443,
#'         https = TRUE,
#'         host = config::get()$host,
#'         user = config::get()$user,
#'         password = config::get()$password,
#'         dbname = config::get()$db
#'     )
#' }
#' 
#' ## Get selected markers abundance data
#' mAb <- cmdGetMarker(con(), features = exMarkers)
#' 
#' ## Get selected samples presence data 
#' mPr <- cmdGetMarker(con(), samples = exSamples, type = "p")
#' 
#' ## exMarkers and exSamples are character vectors included in the package.
#' 
#' }
#'
cmdGetMarker <- function(
        con, features = NULL, samples = NULL, type = c("abundance", "presence")
) {
    type <- match.arg(type, choices = c("abundance", "presence"))
    q <-  stringr::str_c(
        "SELECT sample_id AS sample, marker_id AS feature, ", type, "\n",
        "FROM src_cmgd_v4__marker_", type, "\n"
    )
    if (!is.null(features) && !is.null(samples)) {
        featuresVar <- paste(paste0("'", features, "'"), collapse = ",")
        samplesVar <- paste(paste0("'", samples, "'"), collapse = ",")
        q <- stringr::str_c(
            q, 
            stringr::str_c(
                "WHERE sample IN (", samplesVar ,
                ") AND feature IN (", featuresVar, ")"
            )
        )
    } else if (!is.null(features)) {
        featuresVar <- paste(paste0("'", features, "'"), collapse = ",")
        q <- stringr::str_c(q, stringr::str_c("WHERE feature IN (", featuresVar, ")"))
    } else if (!is.null(samples)) {
        samplesVar <- paste(paste0("'", samples, "'"), collapse = ",")
        q <- stringr::str_c(
            q, stringr::str_c("WHERE sample IN (", samplesVar, ")"))
    } else {
        return(NULL)
    }
    DBI:: dbGetQuery(conn = con, statement = q) |> 
        dplyr::as_tibble()
}


#' Get relative abundance data
#' 
#' \code{cmdGetRalab} Get relative bugs relative abundance.
#' 
#' @inheritParams cmdGetMarker
#' @param id_type A `character(1)` vector. Choose in which id column perform
#' the filtering. Options: "ncbi" or "metaphlan"
#'
#' @return A data.frame.
#' @export
#' 
#' @seealso [cmdGetMarker()]
#'
#' @examples
#'
#' \dontrun{
#' 
#' con <- function() {
#'     DBI::dbConnect(
#'         drv = ClickHouseHTTP::ClickHouseHTTP(),
#'         port = 8443,
#'         https = TRUE,
#'         host = config::get()$host,
#'         user = config::get()$user,
#'         password = config::get()$password,
#'         dbname = config::get()$db
#'     )
#' }
#' 
#' ## Get selected features relative abundance data
#' relabFeatures <- cmdGetRelab(con(), features = exTaxa)
#' 
#' ## Get selected samples relative abundance data
#' relabSamples <- cmdGetRelab(con(), samples = exSamples)
#' 
#' ## exTaxa and exSamples are character vectors included in the package.
#' 
#' }
#'
cmdGetRelab <- function(
    con, features = NULL, samples = NULL, id_type = c("ncbi", "metaphlan")
) {
    id_type <- match.arg(id_type, choices = c("ncbi", "metaphlan"))
    q <- stringr::str_c(
        # "SELECT \"CAST(relative_abundance, 'Float32')\" AS relab, ",
        "SELECT relative_abundance AS relab, ",
        "sample_id AS sample, clade_name AS metaphlan, ",
        # "sample_id AS sample, marker_concatenated AS metaphlan, ",
        # "ncbi_tax_id AS ncbi\n",
        "tax_id_string AS ncbi\n",
        # "FROM src_cmgd_v4__bugs_list\n"
        "FROM relative_abundance\n"
    )
    if (!is.null(features) && !is.null(samples)) {
        featuresVar <- paste(paste0("'", features, "'"), collapse = ",")
        samplesVar <- paste(paste0("'", samples, "'"), collapse = ",")
        q <- stringr::str_c(
            q, 
            stringr::str_c(
                "WHERE sample IN (", samplesVar ,
                ") AND ", id_type, " IN (", featuresVar, ")"
            )
        )
    } else if (!is.null(features)) {
        featuresVar <- paste(paste0("'", features, "'"), collapse = ",")
        q <- stringr::str_c(q, stringr::str_c(
            "WHERE ", id_type, " IN (", featuresVar, ")")
        )
    } else if (!is.null(samples)) {
        samplesVar <- paste(paste0("'", samples, "'"), collapse = ",")
        q <- stringr::str_c(
            q, stringr::str_c("WHERE sample IN (", samplesVar, ")"))
    } else {
        return(NULL)
    }
    DBI:: dbGetQuery(conn = con, statement = q) |> 
        dplyr::as_tibble()
}

.cmdListTables <- function(con) {
    x <- con |> 
        DBI::dbListTables() |> 
        {\(y) grep("src_cmgd_v4", y, value = TRUE)}()
    x
}

.cmdColNames <- function(con, tblName) {
    con |> 
        DBI::dbListFields(tblName)
}

.cmdHead <- function(con, tblName, n = 100) {
    con |> 
        dplyr::tbl(tblName) |> 
        head(n) |> 
        dplyr::as_tibble()
}
