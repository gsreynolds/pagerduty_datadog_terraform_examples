resource "pagerduty_event_orchestration" "my_monitor" {
  name        = "My Monitoring Orchestration"
  description = "Send events to a pair of services"
  team        = pagerduty_team.teams["cloud"].id
}

locals {
  acme_web_routing_rules = {
    "web_db" : { "name" : "relational database", "conditions" : ["event.source matches regex 'db[0-9]+-server'", "event.source matches regex 'db[0-9]+-server'"] },
    "web_app" : { "name" : "web app", "conditions" : ["event.summary matches part 'www'"] },
  }
}

resource "pagerduty_event_orchestration_router" "router" {
  event_orchestration = pagerduty_event_orchestration.my_monitor.id
  set {
    id = "start"
    dynamic "rule" {
      for_each = local.acme_web_routing_rules
      content {
        label = "Events relating to ${rule.value.name}"
        dynamic "condition" {
          for_each = rule.value.conditions
          content {
            expression = condition.value
          }
        }
        actions {
          route_to = pagerduty_service.acme_web[rule.key].id
        }
      }
    }
  }
  catch_all {
    actions {
      route_to = "unrouted"
    }
  }
}

resource "pagerduty_event_orchestration_service" "www" {
  service = pagerduty_service.acme_web["web_app"].id
  set {
    id = "start"
    rule {
      label = "Always apply some consistent event transformations to all events"
      actions {
        variable {
          name  = "hostname"
          path  = "event.component"
          value = "hostname: (.*)"
          type  = "regex"
        }
        extraction {
          # Demonstrating a template-style extraction
          template = "{{variables.hostname}}"
          target   = "event.custom_details.hostname"
        }
        extraction {
          # Demonstrating a regex-style extraction
          source = "event.source"
          regex  = "www (.*) service"
          target = "event.source"
        }
        # Id of the next set
        route_to = "step-two"
      }
    }
  }
  set {
    id = "step-two"
    rule {
      label = "All critical alerts should be treated as P1 incident"
      condition {
        expression = "event.severity matches 'critical'"
      }
      actions {
        annotate = "Please use our P1 runbook: https://docs.test/p1-runbook"
        priority = data.pagerduty_priority.priorities["P1 🔥"].id
      }
    }
    rule {
      label = "If there's something wrong on the canary let the team know about it in our deployments Slack channel"
      condition {
        expression = "event.custom_details.hostname matches part 'canary'"
      }
      # create webhook action with parameters and headers
      actions {
        automation_action {
          name      = "Canary Slack Notification"
          url       = "https://our-slack-listerner.test/canary-notification"
          auto_send = true
          parameter {
            key   = "channel"
            value = "#my-team-channel"
          }
          parameter {
            key   = "message"
            value = "something is wrong with the canary deployment"
          }
          header {
            key   = "X-Notification-Source"
            value = "PagerDuty Incident Webhook"
          }
        }
      }
    }
    rule {
      label = "Never bother the on-call for info-level events outside of work hours"
      condition {
        expression = "event.severity matches 'info' and not (now in Mon,Tue,Wed,Thu,Fri 09:00:00 to 17:00:00 America/Los_Angeles)"
      }
      actions {
        suppress = true
      }
    }
  }
  catch_all {
    actions {}
  }
}
