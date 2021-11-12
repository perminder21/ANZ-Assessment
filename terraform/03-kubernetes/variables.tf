#variable "worker_nodes"
#{
#  type  = "map"
#  description = "ASG values for the worker nodes"
#  default = {
#    max_size = "{{ terraform.kubernetes.aws.worker_nodes.max_size }}",
#    min_size = "{{ terraform.kubernetes.aws.worker_nodes.min_size }}",
#    instance_type = "{{ terraform.kubernetes.aws.worker_nodes.instance_type }}",
#    ami_id = "{{ terraform.kubernetes.aws.worker_nodes.ami_id }}"
#  }
#}
