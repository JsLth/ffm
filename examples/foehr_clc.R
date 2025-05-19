library(ffm)
library(ggplot2)
library(sf)
library(dplyr)
library(ggspatial)
library(extrafont)
library(knitr)

font_import(pattern = "Roboto", prompt = FALSE)
loadfonts("win", quiet = TRUE)

clc_classes <- list(
  "331" = "Beaches, dunes, sands",
  "321" = "Natural grasslands",
  "322" = "Moors and heathland",
  "313" = "Mixed forest",
  "112" = "Discontinuous urban fabric",
  "121" = "Industrial or commercial units",
  "142" = "Sport and leisure facilities",
  "211" = "Non-irrigated arable land",
  "231" = "Pastures",
  "311" = "Broad-leaved forest",
  "423" = "Intertidal flats",
  "421" = "Salt marshes",
  "512" = "Water bodies",
  "523" = "Sea and ocean",
  "141" = "Green urban areas",
  "324" = "Transitional woodland-shrub",
  "411" = "Inland marshes",
  "333" = "Sparsely vegetated areas",
  "111" = "Continuous urban fabric",
  "312" = "Coniferous forest"
)

mun_names <- c(
  "Alkersum", "Borgsum", "Dunsum", "Midlum", "Nieblum", "Oevenum", "Oldsum",
  "Süderende", "Utersum", "Witsum", "Wrixum", "Wyk auf Föhr"
)
ags <- bkg_ags(gemeinde %in% mun_names)$ags
fohr <- bkg_admin(level = "gem", scale = "250", ags %in% ags, gf == 4)
clc <- bkg_clc(bbox = fohr)

# resolve clc codes
clc$landuse <- unlist(clc_classes[clc$clc18])
lvls <- unlist(clc_classes[unique(as.character(sort(as.numeric(clc$clc18))))])
clc$landuse <- factor(clc$landuse, levels = lvls)

bbox <- st_bbox(fohr)
map <- ggplot(clc) +
  geom_sf(aes(fill = landuse), color = "transparent") +
  geom_sf_text(data = fohr, aes(label = gen), size = 3) +
  coord_sf(xlim = bbox[c(1, 3)], ylim = bbox[c(2, 4)]) +
  scale_fill_manual(
    values = c(
      "Continuous urban fabric" = "#e6004d",
      "Discontinuous urban fabric" = "#ff0000",
      "Industrial or commercial units" = "#cc4df2",
      "Green urban areas" = "#ffa6ff",
      "Sport and leisure facilities" = "#ffe6ff",
      "Non-irrigated arable land" = "#ffffa8",
      "Pastures" = "#e6e64d",
      "Broad-leaved forest" = "#80ff00",
      "Coniferous forest" = "#00a600",
      "Mixed forest" = "#4dff00",
      "Natural grasslands" = "#ccf24d",
      "Moors and heathland" = "#a6ff80",
      "Transitional woodland-shrub" = "#a6f200",
      "Beaches, dunes, sands" = "#e6e6e6",
      "Sparsely vegetated areas" = "#ccffcc",
      "Inland marshes" = "#a6a6ff",
      "Salt marshes" = "#ccccff",
      "Intertidal flats" = "#a6a6e6",
      "Water bodies" = "#80f2e6",
      "Sea and ocean" = "#e6f2ff"
    )
  ) +
  annotation_scale(
    location = "bl",
    style = "ticks",
    width_hint = 0.15,
    tick_height = 0.6,
    height = unit(0.1, "cm")
  ) +
  labs(
    title = "Land cover on the German island Föhr",
    subtitle = "Based on the the 5 ha CORINE land cover model, 2018",
    caption = "© GeoBasis-DE / BKG (2025)"
  ) +
  theme_void() +
  guides(fill = guide_legend(ncol = 3)) +
  theme(
    text = element_text(family = "Roboto"),
    legend.direction = "horizontal",
    legend.title = element_blank(),
    legend.position = "bottom",
    legend.key = element_rect(color = "grey20"),
    legend.key.size = unit(0.3, "cm")
  )

ggsave("man/figures/foehr_clc.png", map, bg = "white")
plot_crop("man/figures/foehr_clc.png")
