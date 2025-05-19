daten_base <- function() "https://daten.gdz.bkg.bund.de/"


bkg_download <- function(file,
                         product,
                         year = "latest",
                         group = "vg",
                         path = NULL,
                         timeout = 120,
                         update_cache = FALSE) {
  year <- switch(as.character(year), latest = "aktuell", year)
  url_path <- paste("produkte", group, product, year, file, sep = "/")
  url <- httr2::url_modify(daten_base(), path = url_path)

  path <- path %||% tempdir()
  path <- file.path(path, "ffm_cache", group, product, year)
  dir.create(path, recursive = TRUE, showWarnings = FALSE)
  download(url, path = path, timeout = timeout, update_cache = update_cache)
}


download <- function(url, path = NULL, timeout = 600, update_cache = FALSE) {
  file <- regex_match(url, "[^/]+$", i = 1)
  path <- file.path(path %||% tempdir(), file)

  if (file.exists(path) && !update_cache) {
    return(path)
  }

  if (isTRUE(getOption("ffm_debug", FALSE))) {
    cli::cli_verbatim(utils::URLdecode(url))
  }

  req <- httr2::request(url)
  req <- httr2::req_timeout(req, timeout)
  req <- maybe_retry(req)
  req <- httr2::req_error(req, is_error = function(resp) {
    if (identical(httr2::resp_status(resp), 404L)) {
      cli::cli_abort(c(
        "Could not find the correct file to download.",
        "i" = "This shouldn't happen. Please open a bug issue under {.url https://github.com/jslth/ffm/issues}."
      ))
    }

    FALSE
  })
  resp <- httr2::req_perform(req, path = path)
  unclass(resp$body)
}


unzip_ext <- function(path, ext, regex = NULL, exdir = dirname(path)) {
  zipfiles <- tryCatch(
    zip::zip_list(path)$filename,
    error = function(e) {
      cli::cli_abort(c(
        "Corrupted file detected in cache.",
        "i" = "Consider refreshing the cache using `update_cache = TRUE`."
      ), .envir = parent.frame(4))
    }
  )
  target_files <- zipfiles[has_file_ext(zipfiles, ext)]
  if (!is.null(regex)) {
    target_files <- target_files[grepl(regex, target_files, ignore.case = TRUE)]
  }

  if (!length(target_files) ||
      length(target_files) > 1 && !all(has_file_ext(target_files, shp_exts))) {
    cli::cli_abort(c(
      "Failed to select a single file from the zip archive.",
      "i" = "This shouldn't happen. Please open a bug issue under {.url https://github.com/jslth/ffm/issues}."
    ))
  }

  zip::unzip(path, files = target_files, exdir = exdir)
  file.path(exdir, target_files)
}


has_file_ext <- function(file, ext) {
  ext <- paste(ext, collapse = "|")
  suppressWarnings(grepl(sprintf("\\.(%s)$", ext), file))
}


shp_exts <- c("shp", "cpg", "dbf", "prj", "shx")
