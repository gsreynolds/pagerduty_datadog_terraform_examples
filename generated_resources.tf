# # __generated__ by Terraform
# # Please review these resources and move them into your main configuration files.

# # __generated__ by Terraform from "PRDSL33"
# resource "pagerduty_incident_workflow" "stakeholders" {
#   description = null
#   name        = "Engage Executive Stakeholders"
#   team        = null
#   step {
#     action = "pagerduty.com:incident-workflows:add-stakeholders:2"
#     name   = "Add Stakeholders-71dc404f-3b12-41d0-a74e-b85249fc767d"
#     input {
#       name  = "Stakeholders"
#       value = "[{\"id\":\"P0TQQIK\",\"type\":\"team\"}]"
#     }
#   }
#   step {
#     action = "pagerduty.com:incident-workflows:send-status-update:5"
#     name   = "Send Status Update-e8d262c9-a023-4e77-be01-fcce47973bd5"
#     input {
#       name  = "Status Update template"
#       value = "STATUS_UPDATE_DEFAULT"
#     }
#   }
# }

# # __generated__ by Terraform from "PQM1774"
# resource "pagerduty_incident_workflow" "example" {
#   description = null
#   name        = "Example Workflow"
#   team        = null
#   step {
#     action = "pagerduty.com:incident-workflows:link-slack-channel:5"
#     name   = "Link a Slack Channel to an Incident-e5d1b369-5908-486d-82a6-dd46bd790e8e"
#     input {
#       name  = "Channel Name"
#       value = "slack_test_pdt_gavin"
#     }
#     input {
#       name  = "Slack Workspace Name"
#       value = "T024FV5EJ"
#     }
#   }
#   step {
#     action = "pagerduty.com:incident-workflows:send-status-update:5"
#     name   = "Send Status Update-9b98801e-13d7-4b80-b6c9-15814da1c35c"
#     input {
#       name  = "Status Update template"
#       value = "01DCWUG41PA3JF8JSBCEEFD95L"
#     }
#   }
# }
