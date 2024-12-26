#' Check if the user has a configuration file
#'
#' @description The function checks if the user has an ODBC configuration file
#' or a general configuration file. These files are used to connect via ODBC
#' driver either with an `.odbc.ini` file or a general configuration file
#' `config.yml`. For details, see [clickhouse_connect()].
#'
#' @return A logical vector indicating if the user has an ODBC configuration or
#'   a general configuration file.
#'
#' @examples
#' has_config()
#'
#' @export
has_config <- function() {
    home <- Sys.getenv("HOME")
    c(
        ODBC = file.exists(file.path(home, ".odbc.ini")),
        config = file.exists(file.path(home, "config.yml"))
    )
}
