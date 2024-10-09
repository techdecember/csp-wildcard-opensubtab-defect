variable "default_tags" {
  description = "Default tags"
  type        = map(string)
  default = {
    "project" = "trusted-url-poc"
  } 
}