# openDota API example for fetching hero stats

print("Fetching hero stats from OpenDota API...")
hero_stats <- httr::GET("https://api.opendota.com/api/heroStats")
hero_stats <- httr::content(hero_stats)
hero_stats
