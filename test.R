library(devtools)
load_all()

ggplot(G20, aes(
  area = GDP.mil.USD,
  fill = HDI,
  label = Country,
  subgroup = Region,
  )) +
  geom_treemap(striped = T) +
  geom_treemap_subgroup_border(striped = T) +
  geom_treemap_subgroup_text(
    place = "centre",
    grow = T,
    alpha = 0.5,
    colour = "black",
    fontface = "italic",
    min.size = 0,
    striped = T
  ) +
  geom_treemap_text(
    colour = "white",
    place = "topleft",
    reflow = T,
    striped = T
  )
