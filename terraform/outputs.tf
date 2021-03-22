output "ping_client_id" {
  value = okta_app_oauth.ping_api_app.client_id
}

output "ping_client_secret" {
  value = okta_app_oauth.ping_api_app.client_secret
}

output "ping_api_audience" {
  value = var.ping_api_audience
}

output "ping_api_auth_server" {
  value = okta_auth_server.ping_api_auth_server.issuer
}

output "pong_client_id" {
  value = okta_app_oauth.pong_api_app.client_id
}

output "pong_client_secret" {
  value = okta_app_oauth.pong_api_app.client_secret
}

output "pong_api_audience" {
  value = var.pong_api_audience
}

output "pong_api_auth_server" {
  value = okta_auth_server.pong_api_auth_server.issuer
}