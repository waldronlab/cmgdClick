cmdListTables <- function(con) {
    x <- con |> 
        DBI::dbListTables() |> 
        {\(y) grep("src_cmgd_v4", y, value = TRUE)}()
    # names(x) <- x
    x
}

cmdColNames <- function(con, tblName) {
    con |> 
        DBI::dbListFields(tblName)
}

cmdHead <- function(con, tblName, n = 100) {
    con |> 
        dplyr::tbl(tblName) |> 
        head(n) |> 
        dplyr::as_tibble()
}

cmdGet <- function(features, samples, type) {
    
}

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


cmdGetRelab <- function(
    con, features = NULL, samples = NULL, type = c("ncbi", "metaphlan")
) {
    type <- match.arg(type, choices = c("ncbi", "metaphlan"))
    q <- stringr::str_c(
        "SELECT \"CAST(relative_abundance, 'Float32')\" AS relab, ",
        "sample_id AS sample, marker_concatenated AS metaphlan, ",
        "ncbi_tax_id AS ncbi\n",
        "FROM src_cmgd_v4__bugs_list\n"
    )
    if (!is.null(features) && !is.null(samples)) {
        featuresVar <- paste(paste0("'", features, "'"), collapse = ",")
        samplesVar <- paste(paste0("'", samples, "'"), collapse = ",")
        q <- stringr::str_c(
            q, 
            stringr::str_c(
                "WHERE sample IN (", samplesVar ,
                ") AND ", type, " IN (", featuresVar, ")"
            )
        )
    } else if (!is.null(features)) {
        featuresVar <- paste(paste0("'", features, "'"), collapse = ",")
        q <- stringr::str_c(q, stringr::str_c(
            "WHERE ", type, " IN (", featuresVar, ")")
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