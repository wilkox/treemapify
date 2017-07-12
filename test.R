library(devtools)
library(tweenr)
library(gganimate)
load_all()

G20_alt <- G20
G20_alt$GDP.mil.USD <- sample(G20$GDP.mil.USD, nrow(G20))
G20_alt$HDI <- sample(G20$HDI, nrow(G20))

tweened <- tween_states(list(G20, G20_alt), tweenlength = 20, statelength = 100, ease = 'cubic-in-out', nframes = 50)

p <- ggplot(tweened, aes(
  area = GDP.mil.USD,
  fill = HDI,
  label = Country,
  subgroup = Region,
  frame = .frame
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
  
animation::ani.options(interval = 1/15)
gganimate(p, "G20.gif", title_frame = F, ani.width = 400, ani.height = 400)
