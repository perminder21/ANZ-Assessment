resource "aws_key_pair" "worker_node_keypair" {d
  key_name   = "worker_node_keypair"
  // add the key information if you wanted to create a key pair based on your public key - for assessment it is fine, for production don't do it 
  public_key = "ssh-rsa nTkQotoOaD0PbtIinqU= psingh@192-168-1-108.tpgi.com.au"
}
