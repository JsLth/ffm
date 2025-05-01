daten_base <- function() "https://daten.gdz.bkg.bund.de/"


bkg_download <- function(file,
                         product,
                         year = "latest",
                         group = "vg",
                         path = NULL,
                         timeout = 120,
                         update_cache = FALSE) {
  year <- switch(year, latest = "aktuell", year)
  url_path <- paste("produkte", group, product, year, file, sep = "/")
  url <- httr2::url_modify(daten_base(), path = url_path)
  download(url, path = path, timeout = timeout, update_cache = update_cache)
}


download <- function(url, path = NULL, timeout = 600, update_cache = FALSE) {
  file <- regex_match(url, "[^/]+$", i = 1)
  path <- file.path(path %||% tempdir(), file)

  if (file.exists(path) && !update_cache) {
    return(path)
  }

  req <- httr2::request(url)
  req <- httr2::req_timeout(req, timeout)
  resp <- httr2::req_perform(req, path = path)
  unclass(resp$body)
}


unzip_ext <- function(path, ext, regex = NULL, exdir = dirname(path)) {
  zipfiles <- unzip(path, list = TRUE)$Name
  target_files <- zipfiles[has_file_ext(zipfiles, ext)]
  if (!is.null(regex)) {
    target_files <- target_files[grepl(regex, target_files, ignore.case = TRUE)]
  }
  unzip(path, files = target_files, exdir = exdir)
  file.path(exdir, target_files)
}


has_file_ext <- function(file, ext) {
  ext <- paste(ext, collapse = "|")
  suppressWarnings(grepl(sprintf("\\.(%s)$", ext), file))
}


shp_exts <- c("shp", "cpg", "dbf", "prj", "shx")
