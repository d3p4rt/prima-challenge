variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-south-1"
}

variable "project" {
  description = "Project tag"
  type        = string
  default     = "prima-tech-challenge"
}

variable "tf_state_bucket_name" {
  description = "Bucket name for tfstate"
  type        = string
}

variable "github_org" {
  description = "GitHub user."
  type        = string
  default     = "d3p4rt"
}

variable "github_repo" {
  description = "GitHub repo name."
  type        = string
  default     = "prima-challenge"
}
