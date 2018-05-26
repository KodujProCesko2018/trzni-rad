
library(data.table)
library(dplyr)



filter_extracted_streets <- function(streets_str, sep = ';') {
  streets <- strsplit(streets_str, sep)[[1]]
  streets <- unique(streets)
  streets <- streets[order(nchar(streets))]
  ignored_streets <- c('Mánesova', 'Parková', 'Dolní', 'Horní', 'Výstupní', 'K přístavišti', 'U stanice', 'Na ostrůvku', 'U kašny',
                       'K Náplavce', 'Vnitřní', 'Malá', "Sídliště", "Pěší", "Vodní", "U pošty", "V Ohybu", "Vstupní",
                       "Horčičkova", "U hráze", "U Nádraží", "U garáží", "Pražského", "Sportovní", "U Prodejny", "Za poštou",
                       "Na Výtoni")
  for (ign_s in ignored_streets) {
    streets <- streets[streets != ign_s]
  }
  
  
  ind_to_remove <- c()
  if (length(streets) > 1) {
    for (i in 1:(length(streets)-1)) {
      is_in <- grepl(streets[i], streets[(i+1):length(streets)], ignore.case = TRUE)
      if (any(is_in)) {
        ind_to_remove <- c(ind_to_remove, i)
      }
    }
    if(length(ind_to_remove) > 0) {
      streets <- streets[-ind_to_remove]
    }
  }
  streets_str <- paste(streets, collapse = ';')
  return(streets_str)
}


get_cislo_domu <- function(ulice_string) {
  ulice_string <- gsub('parc.*', '', ulice_string)
  pattern_uc_num <- '[č\\. ]*[0-9]+[0-9,a/ \\–\\-]+'
  pattern_num <- '[0-9]*/[0-9/ \\–]+'
  
  reg_res_1 <- regexpr(pattern_uc_num, ulice_string)
  match_1 <- substr(ulice_string, reg_res_1, reg_res_1 + attr(reg_res_1, 'match.length'))
  
  cislo_domu <- gsub('a', ',', match_1) %>% 
    gsub('[a-z]', '', .) %>% 
    gsub('[A-Z]', '', .) %>% 
    gsub('[čěščřžýáíéůú\\(\\)]', '', .) %>% 
    gsub('\\.', '', .) %>% 
    gsub(' ', '', .) %>% 
    gsub('-', ',', .) %>% 
    gsub('[^0-9]+$', '', .) %>% 
    gsub('^[^0-9]+', '', .) 
  return(cislo_domu)
}


get_cislo_parcely <- function(ulice_string, par_string) {
  
  pattern_uc_num <- '[0-9]+[0-9,/ \\–]+'
  
  ulice_string <- gsub(paste0('.*', par_string), replacement = '', ulice_string)
  
  reg_res_1 <- regexpr(pattern_uc_num, ulice_string)
  match_1 <- substr(ulice_string, reg_res_1, reg_res_1 + attr(reg_res_1, 'match.length'))
  match_1
  
  cislo <- gsub(' a ', ',', match_1) %>% 
    gsub('[a-z]', '', .) %>% 
    gsub('[A-Z]', '', .) %>% 
    gsub('[čěščřžýáíéůú\\(\\)]', '', .) %>% 
    gsub('\\.', '', .) %>% 
    gsub(' ', '', .) %>% 
    gsub('-', ',', .) %>% 
    gsub('[^0-9]+$', '', .) %>% 
    gsub('^[^0-9]+', '', .) 
  return(cislo)
}


get_katastralni_uzemi <- function(ulice_string, katastralni_uzemi_dt) {
  
  pattern_uc_num <- 'k\\.[ ]*ú.*'
  
  reg_res_1 <- regexpr(pattern_uc_num, ulice_string)
  match_1 <- substr(ulice_string, reg_res_1, reg_res_1 + attr(reg_res_1, 'match.length'))
  
  if (length(match_1) > 0) {
    if (match_1 != '') {
      for (i in 1:nrow(katastralni_uzemi_dt)) {
        if (grepl(katastralni_uzemi_dt$nazev_ku[i], match_1)) {
          ku_found <- katastralni_uzemi_dt[i,]$nazev_ku
          break
        }
      }
    }
  }
  
  return(ku_found)
}



etl <- function() {
    data_path <- '../data'
    trzni_rad <- fread(file.path(data_path, 'trzni_rad_plocha_zabor_v5.csv'), encoding = 'UTF-8')
    streets_dt <- fread(file.path(data_path, 'Ulice20180525.csv'), encoding = 'UTF-8')
    katastralni_uzemi_dt <- fread(file.path(data_path, 'katastralni_uzemi.csv'), encoding = 'UTF-8')
    trzni_rad[,ulice := '']
    
    # streets[grepl('Náměstí Bratří', `Název ulice`, ignore.case = TRUE),]
    
    ## Extract streetname from freetext
    for (i in 1:nrow(streets_dt)) {
      street <- streets_dt[i, `Název ulice`]
      trzni_rad[grepl(street,  gsub('k\\.[ ]*ú.*', '',  adresa), ignore.case = TRUE), ulice := paste(ulice, street, sep = ';')]
      if (grepl('nábřeží', street, ignore.case = TRUE)) {
        street_short <- gsub('nábřeží', 'nábř.', street)
        trzni_rad[grepl(street_short,  adresa, ignore.case = TRUE), ulice := paste(ulice, street, sep = ';')]
      }
      if (grepl('náměstí', street, ignore.case = TRUE)) {
        street_short <- gsub('náměstí', 'nám.', street)
        trzni_rad[grepl(street_short,  adresa, ignore.case = TRUE), ulice := paste(ulice, street, sep = ';')]
      }
    }
    trzni_rad[,ulice := gsub('^;', '', ulice)]
    trzni_rad[,ulice := gsub(';$', '', ulice)]
    
    # streets_str <- trzni_rad[grepl('Malá Štupartská',ulice), ulice]
    
    for(i in 1:nrow(trzni_rad)) {
      trzni_rad[i, ulice := filter_extracted_streets(ulice)]  
    }
    
    ## filter streets from extracted streetnames
    
    trzni_rad[ ulice!= '', .N]/ nrow(trzni_rad)
    # View(trzni_rad[,list(adresa, ulice)])
    
    # trzni_rad[,ulice := substr(ulice, 2, nchar(ulice))]
    write.csv(trzni_rad, '../data/trzni_rad_ulice_v1.csv', quote = TRUE, row.names = FALSE, fileEncoding = 'UTF-8')   
    
    # str <- 'Podolské nábřeží u č. 3/1184 a 3/1185 - 3/1186, parc.č. 1130, 1131/1, 113'
    
    trzni_rad[, cislo_domu := get_cislo_domu(adresa)]
    write.csv(trzni_rad, '../data/trzni_rad_cisdom_v2.csv', quote = TRUE, row.names = FALSE, fileEncoding = 'UTF-8')   
    
    trzni_rad[grepl('parc', adresa), cislo_parcely := get_cislo_parcely(adresa, 'parc')]
    trzni_rad[grepl('par\\.', adresa), cislo_parcely := get_cislo_parcely(adresa, 'par\\.')]
    write.csv(trzni_rad, '../data/trzni_rad_cisdom_parc_v3.csv', quote = TRUE, row.names = FALSE, fileEncoding = 'UTF-8')
    
    for (i in 1:nrow(trzni_rad)) {
      if (grepl('k\\.[ ]*ú', trzni_rad[i,adresa])) {
        trzni_rad[i, ku := get_katastralni_uzemi(adresa, katastralni_uzemi_dt)]
      }
    }
    
    trzni_rad[is.na(ulice), ulice := '']
    trzni_rad[is.na(ku), ku := '']
    trzni_rad[is.na(cislo_domu), cislo_domu := '']
    trzni_rad[is.na(cislo_parcely), cislo_parcely := '']
    
    write.csv(trzni_rad, '../data/trzni_rad_cisdom_parc_zabor_ku_v6.csv', quote = TRUE, row.names = FALSE, fileEncoding = 'UTF-8')
    View(trzni_rad[grepl(';', ulice),list(adresa, ulice, cislo_domu, cislo_parcely, ku)])
  
  
  trzni_rad['' != cislo_parcely, .N] # parcel 320 
  
  trzni_rad['' != cislo_domu | ('' != cislo_parcely & '' != ku), .N] # cislo domu nebo parcely a ku: 739 
  
  trzni_rad[ulice != '' & cislo_domu != '', .N] # ulice a cislo domu: 528
  
  }

