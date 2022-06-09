## Function Files

customCrop <- function(data) {

  # Cleans up Hawaii (removes long Northwestern Chain)
  cz34701 = data[data$cz==34701,] %>%
    st_crop(c(xmin=-160, ymin=10, xmax=-157, ymax=23))
  
  st_geometry(data[data$cz==34701,]) <- st_geometry(cz34701)
  
  return(data)
}

mergeCz <- function(merge_from_cz, merge_to_cz, data) {
  
  only_merge_from_cz <- data %>% 
    filter(cz == merge_from_cz)
  
  only_merge_to_cz <- data %>% 
    filter(cz == merge_to_cz)
  
  out <- st_union(only_merge_from_cz, only_merge_to_cz) %>% 
    select(-cz) %>% 
    rename(cz = cz.1)
  
  return(out)
}

replaceCzWithMergedCz <- function(data, merge_from_cz, merge_to_cz, merged_czs) {
  
  out <- data %>% 
    filter(!cz %in% c(merge_from_cz, merge_to_cz)) %>% 
    bind_rows(merged_czones)
  
  return(out)
}