#' Contextualize package
#'
#' @param pkg Name of the package.
#' @param DESCRIPTION Boolean, whether to include the DESCRIPTION file.
#' @param NAMESPACE Boolean, whether to include the NAMESPACE file.
#' @param README Boolean, whether to include the README file.
#' @param NEWS Boolean, whether to include the NEWS.md file.
#' @param LICENSE Boolean, whether to include the LICENSE file.
#' @param help_files Boolean, whether to include help files.
#' @param code Boolean, whether to include code files.
#' @param vignettes Boolean, whether to include vignettes.
#'
#' @return An object of class "ask_context"
#' @export
context_package <- function(
    pkg,
    DESCRIPTION = TRUE,
    NAMESPACE = TRUE,
    README = TRUE,
    NEWS = TRUE,
    LICENSE = TRUE,
    help_files = TRUE,
    code = FALSE,
    vignettes = FALSE) {

  pkgdir <- base::system.file(package = pkg, lib.loc = .libPaths())
  list.files(pkgdir, recursive = TRUE)

  contexts <- list()
  if (DESCRIPTION) {
    path <- file.path(pkgdir, "DESCRIPTION")
    contexts <- c(contexts, list(context(DESCRIPTION = readLines(path))))
  }

  if (NAMESPACE) {
    path <- file.path(pkgdir, "NAMESPACE")
    contexts <- c(contexts, list(context(NAMESPACE = readLines(path))))
  }

  if (NEWS) {
    path <- file.path(pkgdir, "NEWS.md")
    if (file.exists(path)) {
      contexts <- c(contexts, list(context(NEWS = readLines(path))))
    }
  }

  if (LICENSE) {
    path <- file.path(pkgdir, "LICENSE")
    if (file.exists(path)) {
      contexts <- c(contexts, list(context(LICENSE = readLines(path))))
    }
  }

  if (README) {
    path <- file.path(pkgdir, "README.md")
    if (file.exists(path)) {
      contexts <- c(contexts, list(context(README = readLines(path))))
    }
  }

  if (help_files) {
    path <- file.path(pkgdir, sprintf("help/%s.rdb", pkg))
    contexts <- c(contexts, list(context_pkg_doc(path)))
  }

  if (code) {
    path <- file.path(pkgdir, sprintf("R/%s.rdb", pkg))
    contexts <- c(contexts, list(context_pkg_code(path)))
  }

  if (vignettes) {
    vig_path <- file.path(pkgdir, "doc")
    if (file.exists(vig_path)) {
      vign_files <- list.files(vig_path, full.names = TRUE, pattern = "\\.Rmd$")
      vig_contexts <- lapply(vign_files, function(file) context("Vignette: {basename(file)}" := c("```", readLines(file), "```")))
      contexts <- c(contexts, list(context(Vignettes = context(!!!vig_contexts))))
    }
  }

  context("External package '{pkg}'" := context(!!!contexts))
}

context_pkg_doc <- function(path) {
  path <- sub("\\.rdb$", "", path, ignore.case = TRUE)
  e <- new.env()
  lazyLoad(path, envir = e)
  help_files <- suppressWarnings(eapply(e, capture.output))
  contexts <- lapply(
    names(help_files),
    function(nm) {
      context("Help file: {nm}" := help_files[[nm]])
    })
  context("Help files" = context(!!!contexts))
}

context_pkg_code <- function(path) {
  path <- sub("\\.rdb$", "", path, ignore.case = TRUE)
  e <- new.env()
  lazyLoad(path, envir = e)
  help_files <- suppressWarnings(eapply(e, capture.output))
  contexts <- lapply(
    names(help_files),
    function(nm) {
      code <- help_files[[nm]]
      code[[1]] <- sprintf("%s <- %s", nm, code[[1]])
      context("Function code: {nm}" := code)
    })
  context(Code = context(!!!contexts))
}
