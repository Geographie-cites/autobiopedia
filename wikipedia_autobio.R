
# load packages ----

library(rvest)
library(tidyverse)

# get list of academics ----

urlDiscipline <- "https://fr.wikipedia.org/w/index.php?title=Cat%C3%A9gorie:Historien_fran%C3%A7ais_du_XXIe_si%C3%A8cle&from=H"
contentDiscipline <- read_html(urlDiscipline)
listHref <- contentDiscipline %>% html_nodes("a") %>% html_attr("href")
hist(sapply(listHref, nchar), breaks = 30)
listNames <- listHref[nchar(listHref) < 50]
listNames

# for one person

# urlOne <- "https://fr.wikipedia.org/wiki/Jacques_Le_Goff"
# urlOne <- "https://fr.wikipedia.org/wiki/Emmanuel_Le_Roy_Ladurie"
urlOne <- "https://fr.wikipedia.org/wiki/Fiona_Meadows"

nameOne <- strsplit(urlOne, split = "/")[[1]] %>% .[length(.)]
urlOne <- paste0("https://fr.wikipedia.org/w/index.php?title=", nameOne, "&offset=&limit=1000&action=history")
contentOne <- read_html(urlOne)
idContribs <- contentOne %>% html_nodes("bdi") %>% html_text()
historySizes <- contentOne %>% 
  html_nodes("[class='history-size mw-diff-bytes']") %>% 
  html_text() %>% 
  gsub("[[:punct:][:alpha:]]", "", x = .) %>% 
  str_trim() %>% as.integer() %>% rev()
contribSize <- c(historySizes[1], historySizes[2:length(historySizes)] - historySizes[1:length(historySizes) - 1]) %>% abs()
tabContribs <- tibble(ID = idContribs, SIZE = rev(contribSize)) %>% 
  group_by(ID) %>% 
  summarise(SIZE = sum(SIZE)) %>% 
  filter(SIZE > 1) %>% 
  ungroup()

relative_entropy <- function(x){
  xRel <- x / sum(x)
  totalEntropy <- -sum(xRel * log(xRel, base = 2))
  maxEntropy <- log(length(x), base = 2)
  relativeEntropy <- totalEntropy / maxEntropy
  return(relativeEntropy)
}

relative_entropy(tabContribs$SIZE)



refContribs <- tibble(ID = unique(idContribs), 
                      REF = paste0("/wiki/Sp%C3%A9cial:Contributions/", unique(idContribs)))



  
  
