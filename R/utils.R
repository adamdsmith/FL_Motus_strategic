sf_as_df <- function(x, names = c("lon","lat")) {
  ret <- sf::st_coordinates(x) %>% tibble::as_tibble()
  stopifnot(length(names) == ncol(ret))
  x <- x[ , !names(x) %in% names]
  ret <- setNames(ret,names)
  as.data.frame(dplyr::bind_cols(x,ret))
}