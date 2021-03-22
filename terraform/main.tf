  
terraform {
  required_providers {
    okta = {
      source = "oktadeveloper/okta"
      version = "~> 3.10.1"
    }
  }
}

variable "okta_org" {
  type    = string
  sensitive = true
}

variable "okta_base_url" {
  type    = string
  default = "okta.com"
}

variable "okta_api_token" {
  type    = string
  sensitive = true
}

variable "ping_api_audience" {
  type    = string
  default = "api://ping"
}

variable "pong_api_audience" {
  type    = string
  default = "api://pong"
}

# Configure the Okta Provider
provider "okta" {
  org_name  = var.okta_org
  base_url  = var.okta_base_url
  api_token = var.okta_api_token
}

# Ping API OAuth App
resource "okta_app_oauth" "ping_api_app" {
  label          = "Ping API Native App"
  type           = "service"
  response_types = ["token"]
  grant_types    = ["client_credentials"]
  token_endpoint_auth_method = "client_secret_jwt"
}

# Pong API OAuth App
resource "okta_app_oauth" "pong_api_app" {
  label          = "Pong API Native App"
  type           = "service"
  response_types = ["token"]
  grant_types    = ["client_credentials"]
  token_endpoint_auth_method = "client_secret_jwt"
}

# Ping Auth Server and Scope:
resource "okta_auth_server" "ping_api_auth_server" {
  audiences   = [var.ping_api_audience]
  description = "The central store for Ping API scopes and claims"
  name        = "Ping API Auth Server"
  issuer_mode = "ORG_URL"
  status      = "ACTIVE"
}

resource "okta_auth_server_scope" "play_ping" {
  auth_server_id   = okta_auth_server.ping_api_auth_server.id
  metadata_publish = "NO_CLIENTS"
  name             = "play_ping"
  consent          = "IMPLICIT"
  description = "The API will allow a ping"
}

# Pong Auth Server and Scope:
resource "okta_auth_server" "pong_api_auth_server" {
  audiences   = [var.pong_api_audience]
  description = "The central store for Pong API scopes and claims"
  name        = "Pong API Auth Server"
  issuer_mode = "ORG_URL"
  status      = "ACTIVE"
}

resource "okta_auth_server_scope" "play_pong" {
  auth_server_id   = okta_auth_server.pong_api_auth_server.id
  metadata_publish = "NO_CLIENTS"
  name             = "play_pong"
  consent          = "IMPLICIT"
  description = "The API will allow a pong"
}

# Scope policies
resource "okta_auth_server_policy" "play_ping_scope_cc_flow_policy" {
  auth_server_id   = okta_auth_server.ping_api_auth_server.id
  status           = "ACTIVE"
  name             = "play_ping Client Credentials Policy"
  description      = "Policy to guard the play_ping scope requested with Client Credentials flow"
  priority         = 1
  client_whitelist = [okta_app_oauth.pong_api_app.id] # Allow pong client to play ping 
}

resource "okta_auth_server_policy_rule" "play_ping_scope_cc_flow_rule" {
  auth_server_id       = okta_auth_server.ping_api_auth_server.id
  policy_id            = okta_auth_server_policy.play_ping_scope_cc_flow_policy.id
  status               = "ACTIVE"
  name                 = "Allow play_ping scope"
  priority             = 1
  grant_type_whitelist = ["client_credentials"]
  scope_whitelist = [ okta_auth_server_scope.play_ping.name ]
}

resource "okta_auth_server_policy" "play_pong_scope_cc_flow_policy" {
  auth_server_id   = okta_auth_server.pong_api_auth_server.id
  status           = "ACTIVE"
  name             = "play_pong Client Credentials Policy"
  description      = "Policy to guard the play_pong scope requested with Client Credentials flow"
  priority         = 1
  client_whitelist = [okta_app_oauth.ping_api_app.id] # Allow ping client to play pong 
}

resource "okta_auth_server_policy_rule" "play_pong_scope_cc_flow_rule" {
  auth_server_id       = okta_auth_server.pong_api_auth_server.id
  policy_id            = okta_auth_server_policy.play_pong_scope_cc_flow_policy.id
  status               = "ACTIVE"
  name                 = "Allow play_pong scope"
  priority             = 1
  grant_type_whitelist = ["client_credentials"]
  scope_whitelist = [ okta_auth_server_scope.play_pong.name ]
}