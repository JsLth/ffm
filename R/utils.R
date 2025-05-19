regex_match <- function (text, pattern, i = NULL, ...) {
  match <- regmatches(text, regexec(pattern, text, ...))

  if (!is.null(i)) {
    match <- vapply(match, FUN.VALUE = character(1), function(x) {
      if (length(x) >= i) {
        x[[i]]
      } else {
        NA_character_
      }
    })
  }

  match
}


loadable <- function (x) {
  suppressPackageStartupMessages(requireNamespace(x, quietly = TRUE))
}


as_df <- function(x) {
  if (loadable("tibble")) {
    tibble::as_tibble(x)
  } else {
    as.data.frame(x)
  }
}


to_title <- function(x) {
  gsub("\\b([[:alpha:]])([[:alpha:]]+)", "\\U\\1\\L\\2", x, perl = TRUE)
}


is_formula <- function(x) {
  vapply(x, inherits, logical(1), "formula")
}


unbox <- function(x) {
  if (inherits(x, "list") && length(x) == 1) {
    x <- x[[1]]
  }
  x
}


"%zchar%" <- function(x, y) if (!nzchar(x)) y else x
"%__%" <- function(x, y) if (!length(x)) y else x
"%|||%" <- function(x, y) if (!is.null(x) && !all(is.na(x))) y else x
