
# Teams
resource "pagerduty_team" "teams" {
  for_each    = local.teams
  name        = each.value.name
  description = each.value.description
}

resource "pagerduty_user" "users" {
  for_each  = local.users
  name      = each.value.name
  email     = each.value.email
  role      = each.value.role
  job_title = each.value.job_title
}

resource "pagerduty_user_contact_method" "phone" {
  for_each     = local.users
  user_id      = pagerduty_user.users[each.key].id
  type         = "phone_contact_method"
  country_code = each.value.country_code
  address      = each.value.phone
  label        = "Mobile"
}

resource "pagerduty_user_contact_method" "sms" {
  for_each     = local.users
  user_id      = pagerduty_user.users[each.key].id
  type         = "sms_contact_method"
  country_code = each.value.country_code
  address      = each.value.sms
  label        = "Mobile"
}

locals {
  # flatten ensures that this local value is a flat list of objects, rather
  # than a list of lists of objects.
  team_memberships = flatten([
    for team_key, team in local.teams : [
      for user_key, role in team.members : {
        team = team_key
        user = user_key
        role = role
      }
    ]
  ])
}

resource "pagerduty_team_membership" "teams" {
  for_each = {
    for membership in local.team_memberships : "${membership.team}/${membership.user}" => membership
  }
  team_id = pagerduty_team.teams[each.value.team].id
  user_id = pagerduty_user.users[each.value.user].id
  role    = each.value.role
}
