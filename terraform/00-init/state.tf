terraform {
  backend "local" {
    path = "./state/init.tfstate"
  }
}