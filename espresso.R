library(googledrive)
library(tidyverse)
library(here)
df <- drive_ls("~/art/project/espresso/") %>%
  select(name, id) %>%
  filter(name %>% str_detect("^espresso", TRUE)) %>%
  separate(name, into = c("code", "title", "extension"), sep = "_|\\.") %>%
  spread("extension", "id") %>%
  arrange(desc(code)) %>%
  rename(thumb = jpeg, image = jpg, url = png)

filename <- here::here("data/items.toml")
prefix <- "https://drive.google.com/uc?export=view&id="
add_prefix <- function(url) {
  if (is.na(url)) return("")
  paste0(prefix, url)
}

csv_file <- tempfile()

drive_download("~/art/project/espresso/espresso.csv", csv_file)

df2 <- df %>%
  rename(filename_title = title) %>%
  left_join(read_csv(csv_file)) %>%
  replace_na(list(title = "", description = ""))

cat("", file = filename)
for (i in 1:nrow(df)) {
  cat("[[items]]\n", file = filename, append = TRUE)
  cat('title = "', df2$title[i], '"\n', file = filename, sep = "", append = TRUE)
  cat('alt = "', df2$title[i], '"\n', file = filename, sep = "", append = TRUE)
  cat('image = "', add_prefix(df2$image[i]), '"\n', file = filename, sep = "", append = TRUE)
  cat('thumb = "', add_prefix(df2$thumb[i]), '"\n', file = filename, sep = "", append = TRUE)
  cat('description = "', df2$description[i], '"\n', file = filename, append = TRUE)
  cat('url = "', add_prefix(df2$url[i]), '"\n', file = filename, sep = "", append = TRUE)
}
