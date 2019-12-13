options(stringsAsFactors = FALSE)
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman", quiet = TRUE)
pacman::p_load(httr, dplyr, readxl, threejs, pander)

# Download tags detected to temp file
fl_tags <- read_xlsx("Data/SmithAndLefevre2019_US.FL.xlsx", 
                     na = c("", "NA", "NULL")) %>% 
  filter(
    # Tags with tag_id == 0 are likely spurious detections so omit them
    !tag_id == 0,
    # Drop questionable detections from a cluster of unusually noisy stations
    !(grepl("Talbot|GTM NERR|UNF|Lighthouse", name) & n_hits < 15)) %>%
  # For this summary we're indifferent to multiple detections so drop them
  select(tag_id, origin_lat = tag_deploy_lat, origin_lon = tag_deploy_lon) %>%
  # Quick fix of incorrect longitudes for a couple of birds
  mutate(origin_lon = ifelse(origin_lon > 0, origin_lon * -1, origin_lon)) %>%
distinct()
fl_tags_complete <- filter(fl_tags, 
                           !(is.na(origin_lat)|is.na(origin_lon)))
(n_missing_metadata <- nrow(fl_tags) - nrow(fl_tags_complete))

fl_arcs <- fl_tags_complete %>%
  # Set generic central Florida anchor
  mutate(dest_lat = 28.142, dest_lon = -81.572)

earth <- "https://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73751/world.topo.bathy.200407.3x5400x2700.jpg"

# Figure 2 is still image capture of the follow interactive product
fl_crossroads <- globejs(img = earth, arcs = fl_arcs[, -1],
                         arcsHeight = 0.35, arcsLwd = 8, arcsColor = "#be5e00", arcsOpacity = 0.6,
                         atmosphere = TRUE, bg = "white",
                         rotationlat = pi * 15/180, rotationlong = pi * -3/180)
htmlwidgets::saveWidget(widget = fl_crossroads, file = "fl_crossroads.html",
                        title = "Florida migration crossroads")
out_html <- tempfile(fileext = ".html")
file.rename("fl_crossroads.html", out_html)
openFileInOS(normalizePath(out_html))

# The html files that opened in your browser is a temporary file and
# will be removed when you close this R session
# To delete it before closing R use:
unlink(out_html)
