# Builds man/figures/card.png, the social preview card (og:image) of the site:
# the cream paper, Space Grotesk title and hex logo of felixluginbuhl.com, 1200x630.
# Run from the repo root: Rscript dev/logo/card.R

logo <- normalizePath("man/figures/logo.png", winslash = "/")
html <- tempfile(fileext = ".html")
writeLines(
  sprintf(
    '<!doctype html><html><head><meta charset="utf-8">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500&family=Space+Grotesk:wght@600&display=swap">
<style>
  html, body { margin: 0; width: 1200px; height: 630px; overflow: hidden; }
  body {
    background: #FAF6F1;
    background-image:
      radial-gradient(45%% 60%% at 78%% 50%%, rgba(0,137,123,0.14), transparent 70%%),
      url("data:image/svg+xml,%%3Csvg xmlns=\'http://www.w3.org/2000/svg\' width=\'180\' height=\'180\'%%3E%%3Cfilter id=\'n\'%%3E%%3CfeTurbulence type=\'fractalNoise\' baseFrequency=\'.85\' numOctaves=\'3\' stitchTiles=\'stitch\'/%%3E%%3CfeColorMatrix type=\'saturate\' values=\'0\'/%%3E%%3C/filter%%3E%%3Crect width=\'100%%25\' height=\'100%%25\' filter=\'url(%%23n)\' opacity=\'.05\'/%%3E%%3C/svg%%3E");
    font-family: "DM Sans", sans-serif; color: #3D3229;
    display: flex; align-items: center; justify-content: space-between;
    padding: 0 96px; box-sizing: border-box;
  }
  h1 { font: 600 112px/1 "Space Grotesk", sans-serif; letter-spacing: -0.04em; color: #1C1917; margin: 0; }
  p { font-size: 32px; line-height: 1.35; max-width: 640px; margin: 24px 0 0; color: #6B5D4D; }
  .sign { font: 600 26px "Space Grotesk", sans-serif; letter-spacing: -0.02em; color: #1C1917; margin-top: 40px; }
  img { width: 300px; }
</style></head><body>
<div>
  <h1>reactRouter</h1>
  <p>URL routing with React Router for Shiny and Quarto</p>
  <div class="sign">Félix Luginbühl</div>
</div>
<img src="file:///%s">
</body></html>',
    logo
  ),
  html,
  useBytes = TRUE
)

b <- chromote::ChromoteSession$new(width = 1200, height = 630)
b$Page$navigate(paste0("file:///", normalizePath(html, winslash = "/")))
Sys.sleep(2) # fonts
b$screenshot("man/figures/card.png", selector = "html", scale = 1)
b$close()
