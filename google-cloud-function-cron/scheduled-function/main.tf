locals {
  project_id = "forever-project"
  region = "us-central1"
}

provider "google" {
  project = local.project_id
  region  = local.region
}

module "scheduled-function" {
  source  = "terraform-google-modules/scheduled-function/google"
  version = "1.4.2"
  project_id   = local.project_id
  job_name = "hello_pubsub"
  job_schedule = "*/2 * * * *"
  function_entry_point = "hello_pubsub"
  function_name = "hello_pubsub_${random_string.bucket_suffix.result}"
  function_runtime = "python37"
  function_available_memory_mb = 128
  function_source_directory = "."
  function_timeout_s = "30"
  region  = local.region
}

# suffix for bucket
resource "random_string" "bucket_suffix" {
  length = 6
  special = false
  upper = false
  lower = true
  number = true
}
