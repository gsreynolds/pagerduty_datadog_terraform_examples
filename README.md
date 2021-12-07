# ACME - PagerDuty & Datadog Terraform

## Introduction

Please refer to the [Introduction to Terraform](https://www.terraform.io/intro/index.html), to the [PagerDuty Provider](https://registry.terraform.io/providers/PagerDuty/pagerduty/latest/docs) and to the [Datadog Provider](https://registry.terraform.io/providers/Datadog/datadog/latest/docs) documentation.

The Terraform is implemented in a single root module as part of the Proof of Value exercise; it is highly recommended that to operationalise this at scale ACME iterates further to develop  Terraform modules for reusability and/or engages [PagerDuty Professional Services](https://www.pagerduty.com/services/) for further development.

## Usage

### Variables
`variables.tf` defines the default values of the common input variables.  These can be overridden in the standard Terraform manner, but it is highly suggested that only the credentials such as `pagerduty_token` are overridden and all other variable definitions are maintained and checked into source control.

The `pagerduty_token` variable is the API token used to authenticate with the PagerDuty account. A valid read-write API key is required.
The `pagerduty_service_region` variable is used to configure the PagerDuty Service Region between `us` and `eu`.
The `datadog_api_key` variable is the API token used to authenticate with the Datadog account.
The `datadog_app_key` variable is the APP key used to authenticate with the Datadog account.
The `datadog_domain` variable is used to configure the Datadog API URL (e.g. `api.datadoghq.com` or `api.datadoghq.eu`)

It is suggested that this is set in an environment variable, in a terraform.tfvars file (ignored by the `.gitignore` file) or passed using the `-var` command line argument for `terraform` to avoid it being accidentally committed into a Git repository.

An example `terraform.tfvars.example` file is provided. If this file is renamed to `terraform.tfvars` and the `pagerduty_token` line populated with a valid API token, it will be used for the authentication.


### Users & Teams

Currently, users are being provisioned from the [users.csv](users.csv) file via a `pagerduty_user` resource in [pagerduty_teams.tf](pagerduty_teams.tf).

Teams and team membership are defined in [teams.json](teams.json); they are provisioned via `pagerduty_team` and `pagerduty_team_membership` resources in `teams.tf`.

### Schedules, Escalation Policies and Response Plays

On-call rotation schedules and incident escalation policies have been defined in the `escalation_*.tf` files, one per team; they are provisioned via `pagerduty_schedule` and `pagerduty_escalation_policy` resources. Example schedules and escalation policies have been defined.

### Technical Services

> A PagerDuty (technical) service generally represents an application, microservice, or piece of infrastructure owned by a team. For example, a service can be a specialized component used by an application, like a user authentication service, or a piece of shared infrastructure like a database.

Technical services and their relationship to business services have been defined in the `services_*.tf` files, one per team; they are provisioned using `pagerduty_service` resources from a variable (e.g. `acme_web_services`) containing the details for each technical service for a team. Currently, only the `name` and `description` are stored in the variable; this could be extended to contain further service configuration settings and potentially using dynamic blocks for optional configuration.

Please refer to the [Service Configuration Guide](https://community.pagerduty.com/forum/t/service-configuration-guide/1660) for recommended practices of Intuitive Service Configuration and pitfalls to avoid. It is highly recommended that standards/conventions be adopted; we provide the guide to ensure ease-of-use and purposeful setup.

### Integrations, Event Rulesets and Service Event Rules

As a recommended practice, [Event Rulesets](https://support.pagerduty.com/docs/rulesets) have been used to integrate Datadog. Rulesets are used when integration event stream has more than one service destination; using event rules and a global Integration Key you can ingest and route your events to the right service based on their content.

It is highly recommended that when integrating with PagerDuty that attention is paid to Rate Limiting. PagerDuty's rate limits via the Events v2 API are (currently) approximately 120 events/minute per integration key. The limit is calculated over a 60 second window looking back from the current time.

It is also therefore highly recommended that multiple integration keys are used; it would not be recommended practice to use a single integration key for ingesting events from all Datadog monitors for all teams, for example. A typical practice is to create Event Rulesets per team/line of business/logical seperation, per integration source. It may also be appropriate to have seperate Event Rulesets per application or application team.

In this respository, a naming convention has been adopted of `TEAMNAME_SOURCE` e.g. `cloud_datadog` or `cloud_guardduty`.

Additionally, an example of setting up catch-all service and user for triaging events not matched by existing event ruleset rules.

#### Datadog

To integrate Datadog, the [Datadog Integration Guide](https://www.pagerduty.com/docs/guides/datadog-integration-guide/) was used. Alternatively, it is possible to use a custom integration to PagerDuty from Datadog to customize the event payload.

An event ruleset and event rules have been created in the [rulesets_cloud_datadog.tf](rulesets_cloud_datadog.tf) file.

Datadog monitors have been tagged with a `pdservice:SERVICEKEY` tag (e.g. `pdservice:ad`) and the `@pagerduty-ACMECloudRuleset` @-mention. This will result in the Datadog events being sent to the Cloud Platform Datadog ruleset and routed to the services based on the `pdservice` tag.

An additional example of integrating Datadog using a service-level integration is provided in [services_examples.tf](services_examples.tf)
