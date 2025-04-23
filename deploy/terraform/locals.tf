locals {

  tags = {
    "finops.org/environment"     = "production",
    "finops.org/expenses-nature" = "cogs",
    "finops.org/service"         = "deepface",
    "finops.org/feature"         = "reconhecimento-facial",
    "cobli.co/iac-stack"         = "terraform"
  }

}
