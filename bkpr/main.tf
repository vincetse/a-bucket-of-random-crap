provider "cloudflare" {
  version   = "~> 2.0"
  api_token = var.cloudflare_api_key
}

provider "google" {
  region  = var.gcp_region
  zone    = var.gcp_zone
  project = var.gcp_project_id
}

################################################################################
# Build parameters that are necessary
data "google_client_openid_userinfo" "me" {
}

locals {
  bkpr_dns_zone_name_prefix = "bkpr"
  dns_ttl                   = 120
  authz_domain              = split("@", data.google_client_openid_userinfo.me.email)[1]
  bkpr_dns_zone_name        = replace("${local.bkpr_dns_zone_name_prefix}.${var.bkpr_dns_domain}", ".", "-")
}

################################################################################
# Bitnami Kubernetes Production Runtime
# https://github.com/bitnami/kube-prod-runtime/blob/master/docs/quickstart-gke.md
resource "null_resource" "kubeprod_install" {
  provisioner "local-exec" {
    command = join(" ", [
      "kubeprod install gke",
      "--email ${var.admin_email_address}",
      "--dns-zone ${var.bkpr_dns_domain}",
      "--project ${var.gcp_project_id}",
      "--oauth-client-id '${var.gcp_oauth_client_id}'",
      "--oauth-client-secret '${var.gcp_oauth_client_secret}'",
      "--authz-domain ${local.authz_domain}",
    ])
  }
}

resource "null_resource" "kubecfg_delete" {
  provisioner "local-exec" {
    when    = destroy
    command = "kubecfg delete kubeprod-manifest.jsonnet"
  }
  depends_on = [
    null_resource.kubectl_wait_delete_kubeprod_ns,
  ]
}

resource "null_resource" "kubectl_wait_delete_kubeprod_ns" {
  provisioner "local-exec" {
    when    = destroy
    command = "kubectl wait --for=delete ns/kubeprod --timeout=300s"
  }
  depends_on = [
    null_resource.delete_all_dns_records,
  ]
}

resource "null_resource" "delete_all_dns_records" {
  triggers = {
    bkpr_dns_zone_name = local.bkpr_dns_zone_name
  }
  provisioner "local-exec" {
    when    = destroy
    command = "gcloud dns record-sets import /dev/null --zone ${local.bkpr_dns_zone_name} --delete-all-existing"
  }
  depends_on = [
    null_resource.delete_dns_zone,
  ]
}

resource "null_resource" "delete_dns_zone" {
  triggers = {
    bkpr_dns_zone_name = local.bkpr_dns_zone_name
  }
  provisioner "local-exec" {
    when    = destroy
    command = "gcloud dns managed-zones delete ${local.bkpr_dns_zone_name}"
  }
  depends_on = [
    null_resource.remove_service_account_binding,
  ]
}

locals {
  bkpr_service_account_id    = substr("bkpr-edns-${replace(var.bkpr_dns_domain, ".", "-")}", 0, 30)
  bkpr_service_account_email = "${local.bkpr_service_account_id}@${var.gcp_project_id}.iam.gserviceaccount.com"
}

resource "null_resource" "remove_service_account_binding" {
  triggers = {
    bkpr_service_account_email = local.bkpr_service_account_email
  }
  provisioner "local-exec" {
    when    = destroy
    command = "gcloud projects remove-iam-policy-binding ${var.gcp_project_id} --member=serviceAccount:${local.bkpr_service_account_email} --role=roles/dns.admin"
  }
  depends_on = [
    null_resource.remove_service_account,
  ]
}

resource "null_resource" "remove_service_account" {
  triggers = {
    bkpr_service_account_email = local.bkpr_service_account_email
  }
  provisioner "local-exec" {
    when    = destroy
    command = "gcloud --quiet iam service-accounts delete ${local.bkpr_service_account_email}"
  }
  depends_on = [
    null_resource.remove_service_account,
  ]
}


################################################################################
# DNS
data "google_dns_managed_zone" "bkpr" {
  name = local.bkpr_dns_zone_name

  depends_on = [
    null_resource.kubeprod_install,
  ]
}

resource "cloudflare_record" "bkpr" {
  count   = 4 #length(data.google_dns_managed_zone.bkpr.name_servers)
  zone_id = var.cloudflare_zone_id
  name    = var.bkpr_dns_domain
  type    = "NS"
  ttl     = local.dns_ttl
  value   = data.google_dns_managed_zone.bkpr.name_servers[count.index]
}
