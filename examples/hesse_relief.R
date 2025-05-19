library(ffm)
library(terra)
library(sf)
library(ggplot2)
library(tidyterra)
library(dplyr)
library(scales)
library(ggrepel)
library(extrafont)
library(ggspatial)
library(knitr)

font_import(pattern = "Roboto", prompt = FALSE)
loadfonts("win", quiet = TRUE)

# Taken from https://dieghernan.github.io/202212_tidyterra-hillshade-2/
hillshade <- function(r, power = 1) {
  r <- r ^ power
  slope <- terrain(r, "slope", unit = "radians")
  aspect <- terrain(r, "aspect", unit = "radians")
  hill <- shade(slope, aspect, 35, 45)
  names(hill) <- "shades"
  hill
}

hillshade_colors <- function(hill) {
  pal_greys <- hcl.colors(1000, "Grays")
  index <- hill %>%
    mutate(index_col = rescale(shades, to = c(1, length(pal_greys)))) %>%
    mutate(index_col = round(index_col)) %>%
    pull(index_col)
  pal_greys[index]
}

all_states <- bkg_admin(scale = "2500", level = "lan", gf == 9)
states_15 <- all_states[!all_states$sn_l %in% "06",]
hesse <- all_states[all_states$sn_l %in% "06",]
dem <- bkg_dem(bbox = st_buffer(hesse, dist = 50000))
dem <- crop(dem, vect(hesse), mask = TRUE)
hill <- hillshade(dem, power = 2)

prox_states <- suppressWarnings(st_intersection(states_15, st_as_sfc(st_bbox(hesse))))

map <- ggplot() +
  geom_spatraster(data = hill, fill = hillshade_colors(hill), maxcell = Inf) +
  geom_spatraster(data = dem, alpha = 0.5, maxcell = Inf) +
  geom_sf(data = states_15, fill = "transparent", color = "grey20") +
  geom_sf(data = hesse, fill = "transparent", color = "black", lwd = 1) +
  annotate("text", x = 4324000, y = 3164617, label = "Nieder-\nsachsen", family = "Roboto") +
  annotate("text", x = 4190282, y = 3115695, label = "Nordrhein-\nWestfalen", family = "Roboto") +
  annotate("text", x = 4179574, y = 2947211, label = "Rheinland-\nPfalz", family = "Roboto") +
  annotate("text", x = 4282808, y = 2929298, label = "Baden-\nWürttemberg", family = "Roboto") +
  annotate("text", x = 4303086, y = 2984246, label = "Bayern", family = "Roboto") +
  annotate("text", x = 4336950, y = 3080641, label = "Thür-\ningen", family = "Roboto") +
  annotation_scale(
    location = "bl",
    style = "ticks",
    width_hint = 0.15,
    tick_height = 0.6,
    height = unit(0.1, "cm")
  ) +
  coord_sf(xlim = ext(dem)[c(1, 2)], ylim = ext(dem)[c(3, 4)]) +
  scale_fill_terrain_c(
    name = "Elevation (in m)",
    na.value = "transparent",
    direction = -1
  ) +
  labs(
    title = "Relief model of Hesse, Germany",
    subtitle = "Based on the digital elevation model DGM200",
    caption = "© GeoBasis-DE / BKG (2025)"
  ) +
  theme_void() +
  theme(
    text = element_text(family = "Roboto"),
    legend.direction = "horizontal",
    legend.title.position = "top",
    legend.position = "inside",
    legend.position.inside = c(0.2, 0.9),
    legend.frame = element_rect(color = "grey20"),
    legend.ticks = element_line(color = "transparent"),
    legend.key.height = unit(0.35, "cm"),
    plot.caption = element_text(hjust = 1),
    panel.background = element_rect(fill = "transparent", color = NA),
    plot.background = element_rect(fill = "transparent", color = NA)
  )

ggsave("man/figures/hesse_relief.png", bg = "white")
plot_crop("man/figures/hesse_relief.png")
