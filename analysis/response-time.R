library(tidyverse)

# Load datasets
arm <-
  read_csv("../results/response-time-arm-20201209-1000.csv") %>%
  mutate(arch = "arm32v7") %>%
  mutate(resp_time = resp_time * 1000) %>%
  select(-id)

i386 <-
  read_csv("../results/response-time-i386-20203611-1000.csv") %>%
  mutate(arch = "i386") %>%
  mutate(resp_time = resp_time * 1000) %>%
  select(-id)

data <- bind_rows(arm, i386) # append datasets

# Print general info
data %>%
  group_by(arch, mst, cont) %>%
  summarise(
    mean = mean(resp_time),
    std_deviation = sd(resp_time),
    min = min(resp_time),
    max = max(resp_time)
  ) %>%
  print()

##### Lineplots #####

# ARM running times lineplot
data %>%
  filter(arch == "arm32v7") %>%
  filter(mst == "master_running") %>%
  ggplot(aes(x = iter, y = resp_time, colour = cont)) +
  geom_line() +
  labs(
    title = "Tiempo de respuesta en arm32v7 con el contenedor en ejecución",
    x = "Iteración",
    y = "Tiempo (ms)",
    colour = "Implementación"
  ) +
  scale_colour_hue(labels = c("C", "Go", "Rust"))

# ARM stopped times lineplot
data %>%
  filter(arch == "arm32v7") %>%
  filter(mst == "master_stopped") %>%
  ggplot(aes(x = iter, y = resp_time, colour = cont)) +
  geom_line() +
  labs(
    title = "Tiempo de respuesta en arm32v7 con el contenedor parado",
    x = "Iteración",
    y = "Tiempo (ms)",
    colour = "Implementación"
  ) +
  scale_colour_hue(labels = c("C", "Go", "Rust"))

# ARM paused times lineplot
data %>%
  filter(arch == "arm32v7") %>%
  filter(mst == "master_paused") %>%
  ggplot(aes(x = iter, y = resp_time, colour = cont)) +
  geom_line() +
  labs(
    title = "Tiempo de respuesta en arm32v7 con el contenedor pausado",
    x = "Iteración",
    y = "Tiempo (ms)",
    colour = "Implementación"
  ) +
  scale_colour_hue(labels = c("C", "Go", "Rust"))

# i386 running times lineplot
data %>%
  filter(arch == "i386") %>%
  filter(mst == "master_running") %>%
  ggplot(aes(x = iter, y = resp_time, colour = cont)) +
  geom_line() +
  labs(
    title = "Tiempo de respuesta en i386 con el contenedor en ejecución",
    x = "Iteración",
    y = "Tiempo (ms)",
    colour = "Implementación"
  ) +
  scale_colour_hue(labels = c("C", "Go", "Rust"))

# i386 stopped times lineplot
data %>%
  filter(arch == "i386") %>%
  filter(mst == "master_stopped") %>%
  ggplot(aes(x = iter, y = resp_time, colour = cont)) +
  geom_line() +
  labs(
    title = "Tiempo de respuesta en i386 con el contenedor parado",
    x = "Iteración",
    y = "Tiempo (ms)",
    colour = "Implementación"
  ) +
  scale_colour_hue(labels = c("C", "Go", "Rust"))

# i386 paused times lineplot
data %>%
  filter(arch == "i386") %>%
  filter(mst == "master_paused") %>%
  ggplot(aes(x = iter, y = resp_time, colour = cont)) +
  geom_line() +
  labs(
    title = "Tiempo de respuesta en i386 con el contenedor pausado",
    x = "Iteración",
    y = "Tiempo (ms)",
    colour = "Implementación"
  ) +
  scale_colour_hue(labels = c("C", "Go", "Rust"))

##### Barplots #####

# Mean times comparison barplot
data %>%
  group_by(arch, mst) %>%
  summarise(mean_time = mean(resp_time)) %>%
  ggplot(aes(x = mst, y = mean_time, fill = arch)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(
    title = "Tiempo medio de respuesta",
    x = "Estado inicial",
    y = "Tiempo (ms)",
    fill = "Arquitectura"
  ) +
  scale_x_discrete(labels = c("Pausado", "En ejecución", "Parado"))

# Running mean times comparison barplot
data %>%
  filter(mst == "master_running") %>%
  group_by(arch, cont) %>%
  summarise(mean_time = mean(resp_time)) %>%
  ggplot(aes(x = cont, y = mean_time, fill = arch)) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_text(aes(label = mean_time)) +
  labs(
    title = "Tiempo medio de respuesta con el contenedor en ejecución",
    x = "Implementación",
    y = "Tiempo (ms)",
    fill = "Arquitectura"
  ) +
  scale_x_discrete(labels = c("C", "Go", "Rust"))

# Stopped mean times comparison barplot
data %>%
  filter(mst == "master_stopped") %>%
  group_by(arch, cont) %>%
  summarise(mean_time = mean(resp_time)) %>%
  ggplot(aes(x = cont, y = mean_time, fill = arch)) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_text(aes(label = mean_time)) +
  labs(
    title = "Tiempo medio de respuesta con el contenedor parado",
    x = "Implementación",
    y = "Tiempo (ms)",
    fill = "Arquitectura"
  ) +
  scale_x_discrete(labels = c("C", "Go", "Rust"))

# Paused mean times comparison barplot
data %>%
  filter(mst == "master_paused") %>%
  group_by(arch, cont) %>%
  summarise(mean_time = mean(resp_time)) %>%
  ggplot(aes(x = cont, y = mean_time, fill = arch)) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_text(aes(label = mean_time)) +
  labs(
    title = "Tiempo medio de respuesta con el contenedor pausado",
    x = "Implementación",
    y = "Tiempo (ms)",
    fill = "Arquitectura"
  ) +
  scale_x_discrete(labels = c("C", "Go", "Rust"))
