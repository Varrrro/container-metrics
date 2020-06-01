library(tidyverse)

# Load datasets
arm <-
  read_csv("../results/start-time-arm-20200304-1000.csv") %>%
  mutate(arch = "arm32v7") %>%
  select(-id)

i386 <-
  read_csv("../results/start-time-i386-20203810-1000.csv") %>%
  mutate(arch = "i386") %>%
  select(-id)

data <- bind_rows(arm, i386) # append datasets

# Print general info
data %>%
  group_by(arch, impl) %>%
  summarise(
    mean = mean(start_time),
    std_deviation = sd(start_time),
    min = min(start_time),
    max = max(start_time)
  ) %>%
  print()

# ARM times lineplot
data %>%
  filter(arch == "arm32v7") %>%
  ggplot(aes(x = iter, y = start_time, colour = impl)) +
  geom_line() +
  labs(
    title = "Tiempo de lanzamiento en arm32v7",
    x = "Iteración",
    y = "Tiempo (ms)",
    colour = "Implementación"
  ) +
  scale_colour_hue(labels = c("C", "Go", "Rust"))

# i386 times lineplot
data %>%
  filter(arch == "i386") %>%
  ggplot(aes(x = iter, y = start_time, colour = impl)) +
  geom_line() +
  labs(
    title = "Tiempo de lanzamiento en i386",
    x = "Iteración",
    y = "Tiempo (ms)",
    colour = "Implementación"
  ) +
  scale_colour_hue(labels = c("C", "Go", "Rust"))

# Mean times comparison barplot
data %>%
  group_by(arch, impl) %>%
  summarise(mean_time = mean(start_time)) %>%
  ggplot(aes(x = impl, y = mean_time, fill = arch)) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_text(aes(label = mean_time)) +
  labs(
    title = "Tiempo medio de lanzamiento",
    x = "Implementación",
    y = "Tiempo (ms)",
    fill = "Arquitectura"
  ) +
  scale_x_discrete(labels = c("C", "Go", "Rust"))
