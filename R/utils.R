group_list <- function(l, k) {
  grouped_l <- list()
  for(i in 1:length(l)) {
    if(k %in% names(l[[i]])) {
      val_to_key <- as.character(l[[i]][[k]])
      grouped_l[[val_to_key]] <- append(grouped_l[[val_to_key]], l[i])
    } else {
      grouped_l[["key_unfound"]] <- append(grouped_l[["key_unfound"]], l[i])
    }
  }
  # Remove empty names added for unknown reason
  for(i in 1:length(grouped_l)) {
    if(identical(unique(names(grouped_l[[i]])), "")) {
      grouped_l[[i]] <- unname(grouped_l[[i]])
    }
  }
  grouped_l
}

fail_warning <- function(f) {
  function(...) {
    tryCatch(f(...),
             warning=function(w) {stop(w)})
  }
}

fct_relevel_safe <- fail_warning(forcats::fct_relevel)

