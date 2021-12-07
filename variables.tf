variable "pagerduty_token" {
  type        = string
  description = "PagerDuty API token"
}

locals {
  teams = jsondecode(file("teams.json"))
  users = { for row in csvdecode(file("./users.csv")) : lower(row.key) => {
    name         = row.name
    email        = lower(row.email)
    role         = lower(row.role)
    job_title    = row.job_title
    country_code = row.country_code
    phone        = row.phone
    sms          = row.sms
    }
  }
}


variable "pagerduty_service_region" {
  type        = string
  description = "PagerDuty service region"
  default     = "us" # Default US region. Supported value: eu. 
}

variable "pagerduty_subdomain" {
  type        = string
  description = "PagerDuty subdomain for configuring the Datadog integration"
}

variable "datadog_api_key" {
  type        = string
  description = "Datadog API Key"
}

variable "datadog_app_key" {
  type        = string
  description = "Datadog APP Key"
}

variable "datadog_domain" {
  type        = string
  description = "Datadog Domain"
  default     = "api.datadoghq.com" # Or api.datadoghq.eu 
}
