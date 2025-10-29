library(ffm)
library(bonn)
library(dplyr)

font_import(pattern = "Roboto", prompt = FALSE)
loadfonts("win", quiet = TRUE)

# Get municipalities
munic <- bkg_admin(scale = "5000", level = "gem")
states <- bkg_admin(scale = "5000", level = "lan", gf == 9)
ger <- bkg_admin(scale = "5000", level = "sta", gf == 9)

# Get INKAR data
themes <- bonn::get_themes("gem")
theme <- themes |>
  filter(Unterbereich %in% "Erreichbarkeit") |>
  pull(ID)
vars <- bonn::get_variables(theme, "gem")
var <- vars |>
  filter(KurznamePlus %in% "Nahversorgung ÖV Haltestelle") |>
  pull(Gruppe)
munic_internet <- bonn::get_data(var, "GEM", time = 2022) |>
  setNames(c("ags", "geography", "indicator", "value", "time"))

munic <- left_join(
  munic[c("ags", "gen")],
  munic_internet[c("ags", "value")],
  by = "ags"
)

map <- ggplot(munic) +
  geom_sf(data = munic, aes(fill = value), color = NA) +
  geom_sf(data = states, lwd = 0.3, color = "white", fill = NA) +
  geom_sf(data = ger, lwd = 0.3, color = "grey20", fill = NA) +
  binned_scale(
    aesthetics = "fill",
    name = "Share",
    palette = function(x) rev(hcl.colors(length(x), "ag_GrnYl")),
    breaks = c(10, 80, 95, 99),
    labels = function(x) paste0(x, " %"),
    guide = "colorsteps",
    n.breaks = 5
  ) +
  labs(
    title = "Accessibility of public transport in Germany, 2022",
    subtitle = "Share of people within 1 km of the next public transport stop",
    caption = "© GeoBasis-DE / BKG (2025)\n© BBSR Bonn 2025"
  ) +
  theme_void() +
  theme(
    text = element_text(family = "Roboto"),
    legend.frame = element_rect(color = "grey20"),
    legend.ticks = element_line(color = "transparent"),
    plot.title = element_text(margin = margin(b = 2)),
    plot.subtitle = element_text(margin = margin(b = -10)),
    plot.caption = element_text(hjust = 1, margin = margin(t = -10))
  )

ggsave("man/figures/munic_access.png", bg = "white", dpi = 100)
plot_crop("man/figures/munic_access.png")
