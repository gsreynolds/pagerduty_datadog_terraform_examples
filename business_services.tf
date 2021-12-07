resource "pagerduty_business_service" "example" {
  name             = "My Web App"
  description      = "A very descriptive description of this business service"
  point_of_contact = "PagerDuty Admin"
  team             = pagerduty_team.teams["cloud"].id
}

resource "pagerduty_business_service_subscriber" "team_example" {
  subscriber_id       = pagerduty_team.teams["exec_stakeholders"].id
  subscriber_type     = "team"
  business_service_id = pagerduty_business_service.example.id
}

resource "pagerduty_business_service_subscriber" "user_example" {
  subscriber_id       = pagerduty_user.users["security1"].id
  subscriber_type     = "user"
  business_service_id = pagerduty_business_service.example.id
}
