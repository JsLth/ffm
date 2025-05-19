library(ffm)
library(ggplot2)
library(hexSticker)
library(rmapshaper)

ger <- bkg_admin(level = "sta", scale = "5000", gf == 9)$geometry
lan <- bkg_admin(level = "lan", scale = "5000", gf == 9)$geometry

ger_simplified <- rmapshaper::ms_filter_islands(ger, min_area = 1000000000) |>
  rmapshaper::ms_simplify(keep = 0.1)

lan_simplified <- ms_filter_islands(lan, min_area = 1000000000) |>
  ms_simplify(keep = 0.05)

p <- ggplot(ger_simplified) +
  geom_sf(color = "#000", size = 2, fill = "#ffcc00") +
  geom_sf(data = lan_simplified, color = "grey50", size = 0.5, fill = NA, lty = "dotted") +
  geom_sf(color = "#000", size = 2, fill = NA) +
  theme_void()

hexSticker::sticker(
  p,
  package = "ffm",
  p_color = "#000",
  h_color = "#DD0000",
  h_fill = "white",
  s_x = 1,
  s_y = 1,
  p_x = 1,
  p_y = 1.2,
  p_size = 18,
  s_height = 1.5,
  s_width = 1.5,
  url = "https://jslth.github.io/ffm/",
  u_size = 4,
  u_x = 1,
  filename = "man/figures/logo.png"
)
