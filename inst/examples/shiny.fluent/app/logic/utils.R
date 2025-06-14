#' @export
primary_attr_color <- function(attr) {
    switch(
        attr,
        "str" = "darkred",
        "agi" = "darkgreen",
        "int" = "darkblue",
        "all" = "purple", # or "indigo"/"#6a0dad" if you want darker purple
        "black" # fallback/default
    )
}
