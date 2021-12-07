# Configure the PagerDuty provider
provider "pagerduty" {
  token          = var.pagerduty_token
  service_region = var.pagerduty_service_region
}

# Configure the Datadog provider
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://${var.datadog_domain}/"
}

# Datadog integration vendor
data "pagerduty_vendor" "datadog" {
  name = "Datadog"
}

# Lookup PagerDuty priorities
locals {
  pagerduty_priorities = toset(["P1 🔥", "P2 📟", "P3 😫", "P4 🤔", "P5 👀"])
}

data "pagerduty_priority" "priorities" {
  for_each = local.pagerduty_priorities
  name     = each.key
}
