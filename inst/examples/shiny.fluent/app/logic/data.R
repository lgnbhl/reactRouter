# openDota API example for fetching hero stats

print("Fetching hero stats from OpenDota API...")
hero_stats <- httr::GET("https://api.opendota.com/api/heroStats")
hero_stats <- jsonlite::fromJSON(
    httr::content(hero_stats, as = "text", encoding = "UTF-8"),
    simplifyVector = FALSE
)
hero_stats
