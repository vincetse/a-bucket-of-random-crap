variable "cloudflare_api_key" {
  type        = string
  description = "Cloudflare API key"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare zone ID"
}

variable "gcp_region" {
  type        = string
  description = "Google Cloud region"
}

variable "gcp_zone" {
  type        = string
  description = "Google Cloud zone"
}

variable "gcp_project_id" {
  type        = string
  description = "Google Cloud project ID"
}

variable "gcp_oauth_client_id" {
  type        = string
  description = "Google Cloud OAuth2 client ID"
}

variable "gcp_oauth_client_secret" {
  type        = string
  description = "Google Cloud OAuth2 client secret"
}

variable "bkpr_dns_domain" {
  type        = string
  description = "Specifies the DNS suffix for the externally-visible websites and services deployed in the cluster. A TLD or a sub-domain may be used."
}

variable "admin_email_address" {
  type        = string
  description = "Adminstrator email address used for Let's Encrypt"
}
