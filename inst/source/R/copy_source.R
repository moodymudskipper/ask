# for ask_smart we need the source of the package available from the package
# itself, it's only possible AFAIK by copying the files we need in inst/
copy_source <- function() {
  unlink("inst/source", recursive = TRUE, )
  dir.create("inst/source", showWarnings = FALSE)
  dir.create("inst/source/R", showWarnings = FALSE)
  file.copy(list.files("R", full.names = TRUE), "inst/source/R")
  file.copy(c("README.md", "DESCRIPTION", "NAMESPACE"), "inst/source/")
}

package_is_ask <- function() {
  file.exists("inst/ASK-PACKAGE")
}


