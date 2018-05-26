
library(data.table)
library(dplyr)


etl <- function() {
  trzni_rad <- fread('data/trznirad - trznirad.csv', encoding = 'UTF-8')
  View(trzni_rad)
  
  streets <- fread('data/Ulice20180525.csv', encoding = 'UTF-8')
  
  trzni_rad[,ulice := '']
  
  for (i in 1:nrow(streets)) {
    street <- streets[i, `Název ulice`]
    trzni_rad[grepl(street,  `Adresa místa§ 1 odst. 1`), ulice := paste(ulice, street, sep = ';')]
  }
  
  trzni_rad[,ulice := substr(ulice, 2, nchar(ulice))]
  write.csv(trzni_rad, 'data/trzni_rad_ulice_v1.csv', quote = TRUE, row.names = FALSE, fileEncoding = 'UTF-8')   
  
  # str <- 'Podolské nábřeží u č. 3/1184 a 3/1185 - 3/1186, parc.č. 1130, 1131/1, 113'
  
  
  get_cislo_domu <- function(ulice_string) {
    ulice_string <- gsub('parc.*', '', ulice_string)
    pattern_uc_num <- '[č\\. ]*[0-9]+[0-9,a/ \\–\\-]+'
    pattern_num <- '[0-9]*/[0-9/ \\–]+'
    
    reg_res_1 <- regexpr(pattern_uc_num, ulice_string)
    match_1 <- substr(ulice_string, reg_res_1, reg_res_1 + attr(reg_res_1, 'match.length'))
    
    cislo_domu <- gsub('a', ',', match_1) %>% 
      gsub('[a-z]', '', .) %>% 
      gsub('[A-Z]', '', .) %>% 
      gsub('č', '', .) %>% 
      gsub('\\.', '', .) %>% 
      gsub(' ', '', .) %>% 
      gsub('-', ',', .) %>% 
      gsub(',$', '', .) %>% 
      gsub('^,', '', .) %>% 
      gsub('^,', '', .) %>% 
      gsub(',$', '', .)
    return(cislo_domu)
  }
  
  trzni_rad[, cislo_domu := get_cislo_domu(`Adresa místa§ 1 odst. 1`)]
  write.csv(trzni_rad, 'data/trzni_rad_cisdom_v2.csv', quote = TRUE, row.names = FALSE, fileEncoding = 'UTF-8')   
  
  get_cislo_parcely <- function(ulice_string) {
    
    pattern_uc_num <- 'parc[č\\. ]*[0-9,a/ ]+'
    
    reg_res_1 <- regexpr(pattern_uc_num, ulice_string)
    match_1 <- substr(ulice_string, reg_res_1, reg_res_1 + attr(reg_res_1, 'match.length'))
    
    cislo_domu <- gsub('a', ',', match_1) %>% 
      gsub('[a-z]', '', .) %>% 
      gsub('[A-Z]', '', .) %>% 
      gsub('č', '', .) %>% 
      gsub('\\.', '', .) %>% 
      gsub(' ', '', .) %>% 
      gsub('-', ',', .) %>% 
      gsub(',$', '', .) %>% 
      gsub('^,', '', .) %>% 
      gsub('^,', '', .) %>% 
      gsub(',$', '', .)
    return(cislo_domu)
  }
  
  trzni_rad[grepl('parc', `Adresa místa§ 1 odst. 1`), cislo_parcely := get_cislo_parcely(`Adresa místa§ 1 odst. 1`)]
  trzni_rad[grepl('parc', `Adresa místa§ 1 odst. 1`),list(`Adresa místa§ 1 odst. 1`, cislo_parcely)]
  write.csv(trzni_rad, 'data/trzni_rad_cisdom_parc_v3.csv', quote = TRUE, row.names = FALSE, fileEncoding = 'UTF-8')   
  
  trzni_rad['' == cislo_parcely, .N]
  trzni_rad[grepl('parc', `Adresa místa§ 1 odst. 1`), .N] / nrow(trzni_rad)
  trzni_rad['' == cislo_domu, .N]/nrow(trzni_rad)
  
  }

