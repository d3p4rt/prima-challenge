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

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table that stores users."
  type        = string
  default     = "prima-tech-challenge-users"
}

variable "dynamodb_hash_key" {
  description = "Primary key attribute of the users table. The app uses `email`."
  type        = string
  default     = "email"
}

variable "dynamodb_deletion_protection" {
  description = "Enable deletion protection on the DynamoDB table."
  type        = bool
  default     = true
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository."
  type        = string
  default     = "prima-tech-challenge-api"
}
variable "k8s_namespace" {
  description = "NS where app is deployed."
  type        = string
  default     = "production"
}

variable "k8s_service_account" {
  description = "Kubernetes ServiceAccount name used by the app."
  type        = string
  default     = "prima-tech-challenge-api"
}