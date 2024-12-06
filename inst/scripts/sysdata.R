exSamples <- c("SAMEA103958109", "SAMEA103958110", "SAMEA103958111")
exMarkers <- c("UniClust90_GMEPEMOD01001|1__4|SGB72336", "UniClust90_MABEGJKF00110|1__5|SGB72336", "UniClust90_HPNJJKHE00621|1__5|SGB72336")
exTaxa <- c("562", "573", "1301", "1392", "470", "213", "243230", "1352", "282", "83333")

usethis::use_data(
    exSamples, exMarkers, exTaxa,
    overwrite = TRUE
)
