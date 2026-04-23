# Load application support files into testing environment
shinytest2::load_app_env()

# Increase timeout for slower CI environments
options(shinytest2.load_timeout = 30 * 1000)
