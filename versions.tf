terraform {
  required_version = "~> 1.0"

  required_providers {
    pagerduty = {
      source  = "PagerDuty/pagerduty"
      version = "~> 2.5"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.6"
    }
  }
}
