variable "pm_api_url" {
    type = string
}

variable "pm_api_token_id" {
    type = string
}

variable "pm_api_token_secret" {
    type = string
    sensitive = true
}

variable "ssh_user" {
    type = string
    sensitive = true
}

variable "ssh_password" {
    type = string
    sensitive = true
}