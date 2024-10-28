#' Contextualize pdf text content
#'
#' @param file file path or raw vector with pdf data
#' @param type one or more from "text", "ocr_text", "ocr_data". Decides wether to
#' use `pdftools::pdf_text()`, `pdftools::pdf_ocr_text()`, or/and `pdftools::pdf_ocr_data()`.
#' @inheritParams pdftools::pdf_ocr_text
#'
#' @return An object of class "ask_context"
#' @export
#'
#' @examples
#' \dontrun{
#' ask("what is this about?", context_pdf("http://arxiv.org/pdf/1403.2805.pdf"))
#' }
context_pdf <- function(
    file,
    pages = NULL,
    opw = "",
    upw = "",
    dpi = 600,
    language = "eng",
    options = NULL,
    type = "text") {
  rlang::check_installed("pdftools")
  type = rlang::arg_match(type, c("text", "ocr_text", "ocr_data"), multiple = TRUE)
  contexts <- list()
  for (i in seq_along(type)) {
    contexts[[i]] <-   switch(
      type[[i]],
      text = context('Pdf file OCRed text content: {file}' := pdftools::pdf_text(
        pdf = file,
        opw = opw,
        upw = upw
      )),
      ocr_text = context('Pdf file OCRed text content: {file}' := pdftools::pdf_ocr_text(
        pdf = file,
        opw = opw,
        upw = upw,
        dpi = dpi,
        language = language,
        options = options
      )),
      ocr_data = context('Pdf file OCRed data content: {file}' := pdftools::pdf_ocr_data(
        pdf = file,
        opw = opw,
        upw = upw,
        dpi = dpi,
        language = language,
        options = options
      )),
    )
  }
  context(!!!contexts)
}
