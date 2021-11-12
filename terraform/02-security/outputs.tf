output "control_plane_role" {
  value = aws_iam_role.control_plane_role
}

output "eks_worker_node_instance_profile" {
  value = aws_iam_instance_profile.eks_worker_node_instance_profile
}

output "eks_worker_node_role" {
  value = aws_iam_role.eks_worker_node_role
}

output "eks_control_plane_inbound" {
  value = aws_security_group.eks_control_plane_inbound
}

output "eks_control_plane_outbound_to_workers" {
  value = aws_security_group.eks_control_plane_outbound_to_workers
}

output "eks_worker_outbound_to_eks_control_plane" {
  value = aws_security_group.eks_worker_outbound_to_eks_control_plane
}

output "eks_worker_inbound_from_eks_control_plane" {
  value = aws_security_group.eks_worker_inbound_from_eks_control_plane
}

output "eks_worker_to_eks_worker" {
  value = aws_security_group.eks_worker_to_eks_worker
}

output "allow_tls_outbound_all" {
  value = aws_security_group.allow_tls_outbound_all
}

output "allow_everything_outbound_all" {
  value = aws_security_group.allow_everything_outbound_all
}

output "worker_node_keypair" {
  value = aws_key_pair.worker_node_keypair
}

output "service_elb_security_group" {
  value = aws_security_group.service_elb
}

output "service_elb_security_group_id" {
  value = aws_security_group.service_elb.id
}

