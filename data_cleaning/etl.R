
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
  pattern <- '[č\\. ]*[0-9]+[0-9,a/ \\–\\-]+'
  reg_res_1 <- regexpr(pattern, ulice_string)
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
  pattern <- '[0-9]+[0-9,/ \\–]+'
  ulice_string <- gsub(paste0('.*', par_string), replacement = '', ulice_string)
  reg_res_1 <- regexpr(pattern, ulice_string)
  match_1 <- substr(ulice_string, reg_res_1, reg_res_1 + attr(reg_res_1, 'match.length'))
  
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


annotate_druh_zbozi <- function(trzni_rad) {
  trzni_rad[,tags := '']
  
  trzni_rad[grepl("Ovoc", druh_zbozi, ignore.case = T) |
              grepl("Zelen", druh_zbozi, ignore.case = T) |
              grepl("jahod", druh_zbozi, ignore.case = T) |
              grepl("lesní", druh_zbozi, ignore.case = T), 
            tags := paste(tags, "Ovoce, Zelenina", sep = ';')]
  trzni_rad[grepl("Farm", druh_zbozi, ignore.case = T) |
              grepl("výpěstk", druh_zbozi, ignore.case = T), 
            tags := paste(tags, "Farmářské trhy", sep = ';')]
  trzni_rad[grepl("Váno", druh_zbozi, ignore.case = T),
            tags := paste(tags, "Vánoční trhy", sep = ';')]
  trzni_rad[grepl("Veli", druh_zbozi, ignore.case = T),
            tags := paste(tags, "Velikonoční trhy", sep = ';')]
  trzni_rad[grepl("Dušič", druh_zbozi, ignore.case = T),
            tags := paste(tags, "Dušičkové trhy", sep = ';')]
  trzni_rad[grepl("Ryby", druh_zbozi, ignore.case = T),
            tags := paste(tags, "Rybí trhy", sep = ';')]
  trzni_rad[grepl("Půjčov", druh_zbozi, ignore.case = T),
            tags := paste(tags, "Půjčovna", sep = ';')]
  trzni_rad[grepl("upomínk", druh_zbozi, ignore.case = T) |
              grepl("pohled", druh_zbozi, ignore.case = T),
            tags := paste(tags, "Upomínkové předměty", sep = ';')]
  trzni_rad[grepl("Zmrzlin", druh_zbozi, ignore.case = T) |
              grepl("točen", druh_zbozi, ignore.case = T),
            tags := paste(tags, "Zmrzlina", sep = ';')]
  trzni_rad[grepl("občerstven", druh_zbozi, ignore.case = T) | 
              grepl("káva", druh_zbozi, ignore.case = T) | 
              grepl("grilovac", druh_zbozi, ignore.case = T) | 
              grepl("nealkohol", druh_zbozi, ignore.case = T),
            tags := paste(tags, "Občerstvení", sep = ';')]
  trzni_rad[grepl('včetně alkohol', druh_zbozi, ignore.case = T),
            tags := paste(tags, "Alkohol", sep = ';')]
  trzni_rad[grepl("lodní lístky na vyhlídkové plavby", druh_zbozi, ignore.case = T) 
            , tags := paste(tags, "lodní lístky na vyhlídkové plavby", sep = ';')]
  trzni_rad[grepl("čištění peří", druh_zbozi, ignore.case = T),
            tags := paste(tags, "Čištění peří", sep = ';')]
  trzni_rad[grepl("tabák", druh_zbozi, ignore.case = T),
            tags := paste(tags, "Tabák", sep = ';')]
  trzni_rad[grepl("textil", druh_zbozi, ignore.case = T),
            tags := paste(tags, "Textil", sep = ';')]
  trzni_rad[grepl("květ", druh_zbozi, ignore.case = T),
            tags := paste(tags, "Květiny", sep = ';')]
  trzni_rad[grepl("^;", tags, ignore.case = T),
            tags := gsub("^;", '', tags)]
  return(trzni_rad)
  
}


## Main Function
etl <- function() {
  data_path <- '../data'
  trzni_rad <- fread(file.path(data_path, 'v7_carky_lode_ctvti.csv'), encoding = 'UTF-8')
  streets_dt <- fread(file.path(data_path, 'Ulice20180525.csv'), encoding = 'UTF-8')
  katastralni_uzemi_dt <- fread(file.path(data_path, 'katastralni_uzemi.csv'), encoding = 'UTF-8')
  trzni_rad[,ulice := '']
  
  
  ## Extract streetname from Adresa
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
  
  for(i in 1:nrow(trzni_rad)) {
    trzni_rad[i, ulice := filter_extracted_streets(ulice)]  
  }
  write.csv(trzni_rad, '../data/trzni_rad_ulice_v1.csv', quote = TRUE, row.names = FALSE, fileEncoding = 'UTF-8')   
  
  
  ## Extract Cislo domu
  trzni_rad[, cislo_domu := get_cislo_domu(adresa)]
  write.csv(trzni_rad, '../data/trzni_rad_cisdom_v2.csv', quote = TRUE, row.names = FALSE, fileEncoding = 'UTF-8')   
  
  
  ## Extract Cislo Parcely
  trzni_rad[grepl('parc', adresa), cislo_parcely := get_cislo_parcely(adresa, 'parc')]
  trzni_rad[grepl('par\\.', adresa), cislo_parcely := get_cislo_parcely(adresa, 'par\\.')]
  write.csv(trzni_rad, '../data/trzni_rad_cisdom_parc_v3.csv', quote = TRUE, row.names = FALSE, fileEncoding = 'UTF-8')
  
  ## Extract Katastralni Uzemi
  for (i in 1:nrow(trzni_rad)) {
    if (grepl('k\\.[ ]*ú', trzni_rad[i,adresa])) {
      trzni_rad[i, ku := get_katastralni_uzemi(adresa, katastralni_uzemi_dt)]
    }
  }
  write.csv(trzni_rad, '../data/trzni_rad_cisdom_parc_zabor_ku_v8.csv', quote = TRUE, row.names = FALSE, fileEncoding = 'UTF-8')
  
  
  ## Create  tags
  trzni_rad <- annotate_druh_zbozi(trzni_rad)
  
  write.csv(trzni_rad, '../data/trzni_rad_tagy_v9.csv', quote = TRUE, row.names = FALSE, fileEncoding = 'UTF-8')
  
  trzni_rad[,tz_id := (1:nrow(trzni_rad)) * 100]
  trzni_rad_bak <- trzni_rad
  trzni_rad_bak -> trzni_rad
  trzni_rad <- merge(trzni_rad, katastralni_uzemi_dt, by.x = 'ku', by.y = 'nazev_ku', all.x = TRUE)
  setkeyv(trzni_rad, 'tz_id')
  
  trzni_rad <- clean_NAs(trzni_rad)
  
  # order columns
  trzni_rad <- trzni_rad[,list(tz_id, druh_mista, mestska_cast, adresa, mista, zabor, lode, prodejni_doba, doba_provozu, druh_zbozi, 
                               vice_zaznamu, ulice, cislo_domu, cislo_parcely, ku, cislo_ku, tags)]
  
  write.csv(trzni_rad, '../data/trzni_rad_tagy_ku_v10.csv', quote = TRUE, row.names = FALSE, fileEncoding = 'UTF-8')
  write.csv(trzni_rad, '../data/trzni_rad_tagy_ku_v10_cp1250.csv', quote = TRUE, row.names = FALSE, fileEncoding = 'CP1250')
  
  View(trzni_rad)
  
}


clean_NAs <- function(trzni_rad) {
  trzni_rad[is.na(ulice), ulice := '']
  trzni_rad[is.na(ku), ku := '']
  trzni_rad[is.na(cislo_ku), cislo_ku := '']
  trzni_rad[is.na(cislo_domu), cislo_domu := '']
  trzni_rad[is.na(cislo_parcely), cislo_parcely := '']
  trzni_rad[is.na(ku), ku := '']
  trzni_rad[, cislo_ku_s := as.character(cislo_ku)]
  trzni_rad[, cislo_ku := NULL]
  trzni_rad[, cislo_ku := cislo_ku_s]
  trzni_rad[, cislo_ku_s := NULL]
  trzni_rad[is.na(cislo_ku), cislo_ku := '']
}


explore <- function(trzni_rad) {
  trzni_rad['' != cislo_parcely, .N] # parcel 320 
  trzni_rad['' != cislo_domu | ('' != cislo_parcely & '' != ku), .N] # cislo domu nebo parcely a ku: 739 
  trzni_rad['' != cislo_domu & ulice != '' & !grepl(';', ulice),.N] 
  trzni_rad[ulice != '' & cislo_domu != '', .N] # ulice a cislo domu: 528
}
