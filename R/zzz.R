#' @import "plyr"
#' @import "ggplot2"
#' @import "reshape2"

.onAttach <- function(lib, pkg) {
  packageStartupMessage(paste("Package treemapify",utils::packageVersion("treemapify"),"has been loaded!\n"))
}
