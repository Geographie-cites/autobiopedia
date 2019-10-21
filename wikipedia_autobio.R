
# load packages ----

library(rvest)
library(tidyverse)


# functions ----

get_name <- function(subject){
  listElem <- str_split(subject, pattern = "/", simplify = TRUE)
  return(listElem[length(listElem)])
}

clean_table <- function(tab){
  idNa <- grepl(pattern = "Catégorie", x = tab$subject)
  tabNona <- tab[!idNa, ]
  idDupli <- duplicated(tabNona$subject)
  tabClean <- tabNona[!idDupli, ]
  tabClean$NAME <- sapply(tabClean$subject, FUN = get_name)
  tabClean$LINK <- paste0("https://fr.wikipedia.org/wiki/", tabClean$NAME)
  return(tabClean[, c("NAME", "LINK")])
}


relative_entropy <- function(x){
  xRel <- x / sum(x)
  totalEntropy <- -sum(xRel * log(xRel, base = 2))
  maxEntropy <- log(length(x), base = 2)
  relativeEntropy <- totalEntropy / maxEntropy
  return(relativeEntropy)
}


gini_coef <- function (x, corr = FALSE, na.rm = TRUE){
  if (!na.rm && any(is.na(x))) 
    return(NA_real_)
  x <- as.numeric(na.omit(x))
  n <- length(x)
  x <- sort(x)
  G <- sum(x * 1L:n)
  G <- 2 * G/sum(x) - (n + 1L)
  if (corr) 
    G/(n - 1L)
  else G/n
}


get_contribpage <- function(name, limit = 3000){
  urlOne <- paste0("https://fr.wikipedia.org/w/index.php?title=", name, "&offset=&limit=", limit, "&action=history")
  contentOne <- try(read_html(urlOne))
  
  if(class(contentOne)[1] == "try-error"){
    tabContribs <- NA
  } else {
    idContribs <- contentOne %>% html_nodes("bdi") %>% html_text()
    historySizes <- contentOne %>% 
      html_nodes("[class='history-size mw-diff-bytes']") %>% 
      html_text() %>% 
      gsub("[[:punct:][:alpha:]]", "", x = .) %>% 
      str_trim() %>% as.integer() %>% rev()
    contribSize <- c(historySizes[1], historySizes[2:length(historySizes)] - historySizes[1:length(historySizes) - 1]) %>% abs()
    if(length(idContribs) != length(contribSize)){
      tabContribs <- NA
    } else {
      tabContribs <- tibble(ID = idContribs, SIZE = rev(contribSize)) %>% 
        group_by(ID) %>% 
        summarise(SIZE = sum(SIZE)) %>% 
        filter(SIZE > 1) %>% 
        ungroup()
    }
  }
  closeAllConnections()
  return(tabContribs)
}

compute_entropy <- function(cp){
  if(is.na(cp)){
    result <- NA
  } else {
    result <- relative_entropy(cp$SIZE) 
  }
  return(result)
}

compute_gini <- function(cp){
  if(is.na(cp)){
    result <- NA
  } else {
    result <- gini_coef(cp$SIZE)
  }
}


# get list of academics ----

prefix <- "http://fr.dbpedia.org/sparql?default-graph-uri=http://fr.dbpedia.org&query=DESCRIBE+%3Chttp://fr.dbpedia.org/resource/Cat%C3%A9gorie:"
suffix <-  "%3E&format=text/csv"

# historien
hist20 <- read_csv(paste0(prefix, "Historien_fran%C3%A7ais_du_XXe_si%C3%A8cle", suffix))
hist21 <- read_csv(paste0(prefix, "Historien_fran%C3%A7ais_du_XXIe_si%C3%A8cle", suffix))
hist20 <- clean_table(hist20)
hist21 <- clean_table(hist21)
historien <- rbind(hist20, hist21) %>% distinct()

# sociologue
socio20 <- read_csv(paste0(prefix, "Sociologue_fran%C3%A7ais_du_XXe_si%C3%A8cle", suffix))
socio21 <- read_csv(paste0(prefix, "Sociologue_fran%C3%A7ais_du_XXIe_si%C3%A8cle", suffix))
socio20 <- clean_table(socio20)
socio21 <- clean_table(socio21)
sociologue <- rbind(socio20, socio21) %>% distinct()

# géographe
geo2021 <- read_csv(paste0(prefix, "G%C3%A9ographe_fran%C3%A7ais", suffix))
geographe <- clean_table(geo2021)

# architecte
archi20 <- read_csv(paste0(prefix, "Architecte_fran%C3%A7ais_du_XXe_si%C3%A8cle", suffix))
archi21 <- read_csv(paste0(prefix, "Architecte_fran%C3%A7ais_du_XXIe_si%C3%A8cle", suffix))
archi20 <- clean_table(archi20)
archi21 <- clean_table(archi21)
architecte <- rbind(archi20, archi21) %>% distinct()

# Psychologue  et psychanalyste
psycho <- read_csv(paste0(prefix, "Psychanalyste_fran%C3%A7ais", suffix))
psycha <- read_csv(paste0(prefix, "Psychologue_fran%C3%A7ais", suffix))
psycho <- clean_table(psycho)
psycha <- clean_table(psycha)
psychonal <- rbind(psycho, psycha) %>% distinct()

# Philosophe
philo20 <- read_csv(paste0(prefix, "Philosophe_fran%C3%A7ais_du_XXe_si%C3%A8cle", suffix))
philo21 <- read_csv(paste0(prefix, "Philosophe_fran%C3%A7ais_du_XXIe_si%C3%A8cle", suffix))
philo20 <- clean_table(philo20)
philo21 <- clean_table(philo21)
philosophe <- rbind(philo20, philo21) %>% distinct()

# Economiste
econ20 <- read_csv(paste0(prefix, "%C3%89conomiste_fran%C3%A7ais_du_XXe_si%C3%A8cle", suffix))
econ21 <- read_csv(paste0(prefix, "%C3%89conomiste_fran%C3%A7ais_du_XXIe_si%C3%A8cle", suffix))
econ20 <- clean_table(econ20)
econ21 <- clean_table(econ21)
economiste <- rbind(econ20, econ21) %>% distinct()

# Politologue
polit2021 <- read_csv(paste0(prefix, "Politologue_fran%C3%A7ais", suffix))
politologue <- clean_table(politologue)


listPages <- list(HIST = historien, 
                  GEOG = geographe, 
                  ARCH = architecte, 
                  PSYC = psychonal, 
                  PHIL = philosophe,
                  ECON = economiste,
                  POLI = politologue)


currentDate <- Sys.time() %>% substr(x = ., start = 1, stop = 10)
saveRDS(object = listPages, file = paste0("list_pages_", currentDate, ".Rds"))

# get "histoire" ----

# listCP <- lapply(historien$NAME, get_contribpage)
listCP <- list()
for(i in 1:nrow(historien)){
  print(i)
  tempCP <- get_contribpage(historien$NAME[i])
  listCP[[length(listCP) + 1]] <- tempCP
}


saveRDS(listCP, file = "listCP_historien.Rds")

historien$ENTROPY <- sapply(listCP, compute_entropy)
historien$GINI <- sapply(listCP, compute_gini)

# for one person

refContribs <- tibble(ID = unique(idContribs), 
                      REF = paste0("/wiki/Sp%C3%A9cial:Contributions/", unique(idContribs)))

