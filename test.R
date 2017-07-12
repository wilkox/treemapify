library(devtools)
load_all()

ggplot(G20, aes(
  area = GDP.mil.USD,
  fill = HDI,
  label = Country,
  subgroup = Region,
  )) +
  geom_treemap() +
  geom_treemap_subgroup_border() +
  geom_treemap_subgroup_text(
    place = "centre",
    grow = T,
    alpha = 0.5,
    colour = "black",
    fontface = "italic",
    min.size = 0
  ) +
  geom_treemap_text(
    colour = "white",
    place = "topleft",
    reflow = T
  )
