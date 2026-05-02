variable "aws_region" {
  description = "AWS region for the application infrastructure."
  type        = string
  default     = "eu-south-1"
}

variable "project" {
  description = "Project tag applied to every resource."
  type        = string
  default     = "prima-tech-challenge"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prd...)."
  type        = string
  default     = "prd"
}

variable "avatars_bucket_name" {
  description = "Globally unique S3 bucket name for user avatars."
  type        = string
}

