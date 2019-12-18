options(stringsAsFactors = FALSE)
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman", quiet = TRUE)
pacman::p_load(dplyr, lubridate, rnaturalearth, ggplot2, sf, patchwork)
source("R/utils.R")

rcv <- read.csv("Data/SmithAndLefevre2019_Motus_receiver_deployments.csv")
rcv <- rcv %>%
  filter(isMobile != "true") %>%
  mutate(sdate = as.Date(dtStart),
         edate = as.Date(ifelse(dtEnd == "", as.character(Sys.Date()), dtEnd))) %>%
  select(site = siteName, lat = latitude, lon = longitude, sdate, edate)
  
na <- rnaturalearth::ne_states(country = c("canada", "united states of america"), returnclass = "sf") %>%
  select(country = geonunit, state = gn_name, st_abbr = postal)
mb <- rnaturalearth::ne_countries(country = c("mexico", "the bahamas"), scale = 50, returnclass = "sf") %>%
  select(country = geounit) %>%
  mutate(state = NA_character_,
         st_abbr = NA_character_)
na_buff <- st_buffer(rbind(na, mb), 1)

# Projection for figure
lcc <- "+proj=lcc +lon_0=-95 +lat_1=33 +lat_2=45"

# Tweak centroids so labels show up in legible places
state_c <- st_centroid(na) %>% sf_as_df()
state_c$nudge_y <- state_c$nudge_x <- 0
state_c$lat[grepl("Ontario|Quebec", state_c$state)] <- 50
state_c$lat[grepl("Manitoba", state_c$state)] <- 50.5
state_c$nudge_x[state_c$state == "Manitoba"] <- -2
state_c$nudge_x[state_c$state == "Florida"] <- 0.8
state_c$nudge_x[state_c$state == "New Jersey"] <- 0.3
state_c$nudge_x[state_c$state == "Oklahoma"] <- 0.5
state_c$nudge_x[state_c$state == "Michigan"] <- 0.5
state_c$nudge_x[state_c$state == "Delaware"] <- 0.1
state_c$nudge_x[state_c$state == "Louisiana"] <- -0.5
state_c$nudge_y[state_c$state == "Louisiana"] <- 0.9
state_c$nudge_y[state_c$state == "Maryland"] <- 0.5
state_c$nudge_y[state_c$state == "Michigan"] <- -0.5
state_c$nudge_y[state_c$state == "Massachusetts"] <- 0.2
state_c <- filter(state_c, !grepl("DC|RI|PE", st_abbr)) %>%
  mutate(lat = lat + nudge_y,
         lon = lon + nudge_x) %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326) %>%
  st_transform(crs = lcc)

na <- st_transform(na, crs = lcc)
mb <- st_transform(mb, crs = lcc)

dec14 <- filter(rcv, 
                as.Date("2014-12-01") >= sdate & as.Date("2014-12-01") <= edate,
                !is.na(lat),
                !is.na(lon)) %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326) %>%
  st_join(na_buff, left = FALSE) %>%
  st_transform(crs = lcc)

dec19 <- filter(rcv, 
                sdate <= as.Date("2019-12-01"),
                edate >= as.Date("2019-12-01"),
                !is.na(lat),
                !is.na(lon)) %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326) %>%
  st_join(na_buff, left = FALSE) %>%
  st_transform(crs = lcc)

lcc_bb <- st_as_sfc(st_bbox(c(xmin = -100, xmax = -65, ymax = 50, ymin = 25), crs = st_crs(4326))) %>%
  st_transform(crs = lcc) %>% st_bbox()

then <- ggplot() + theme_bw(base_size = 12) +
  geom_sf(data = mb, fill = "gray70", color = "black") +
  geom_sf(data = na, fill = "gray70", color = "black") +
  geom_sf_text(data = state_c, aes(label = st_abbr), fontface = "bold", size = 2) +
  coord_sf(xlim = lcc_bb[c(1,3)], ylim = lcc_bb[c(2,4)]) +
  geom_point(data = sf_as_df(dec14), aes(x = lon, y = lat),
             size = 1, pch = 21, color = "black", fill = "red") +
  labs(title = "(a) 1 December 2014") +
  theme(plot.title = element_text(hjust = 0),
        axis.title = element_blank(),
        panel.grid.major = element_line(color = "gray30"),
        plot.margin = grid::unit(c(2,2,2,2), "mm"))

now <- ggplot() + theme_bw(base_size = 12) +
  geom_sf(data = mb, fill = "gray70", color = "black") +
  geom_sf(data = na, fill = "gray70", color = "black") +
  geom_sf_text(data = state_c, aes(label = st_abbr), fontface = "bold", size = 2) +
  coord_sf(xlim = lcc_bb[c(1,3)], ylim = lcc_bb[c(2,4)]) +
  geom_point(data = sf_as_df(dec19), aes(x = lon, y = lat),
             size = 1, pch = 21, color = "black", fill = "red") +
  labs(title = "(b) 1 December 2019") +
  theme(plot.title = element_text(hjust = 0),
        axis.title = element_blank(),
        panel.grid.major = element_line(color = "gray30"),
        plot.margin = grid::unit(c(2,2,2,2), "mm"))

fig <- then + now
ggsave("Output/fig1_motus_changes_2014_2019.jpg", device = "jpeg",
       plot = fig, width = 8.5, height = 3.75, units = "in", dpi = 600)
