library(ffm)
library(ggplot2)
library(ggborderline)

dus <- bkg_admin(level = "gem", ags == "05111000")

rivers <- bkg_dlm("44004", shape = "line", bbox = dus) |>
  st_intersection(dus) |>
  suppressWarnings()
streets <- bkg_dlm(42003, shape = "line", bbox = dus) |>
  st_intersection(dus) |>
  suppressWarnings()
streets <- streets[st_is(streets, "LINESTRING"), ]

buildings <- bkg_dlm("31001", shape = "polygon", bbox = dus)

ggplot(rivers) +
  geom_sf(data = dus, fill = "black", color = "black") +

  geom_sf(
    data = streets[!streets$brf %in% c(10, 15, 17.5), ],
    lineend = "round",
    color = "white"
  ) +

  geom_sf(
    data = streets[streets$brf %in% c(10, 15, 17.5), ],
    lineend = "round",
    color = "white",
    lwd = 1
  ) +
  labs(
    title = "Street network of Dusseldorf, Germany",
    subtitle = "Based on the digital landscape model DLM250",
    caption = "© GeoBasis-DE / BKG (2025)"
  ) +
  theme_void()

ggsave("man/figures/dus_network.png", bg = "white")
knitr::plot_crop("man/figures/dus_network.png")
