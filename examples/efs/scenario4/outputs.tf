output "efs" {
  description = "Elastic File System info"
  value       = module.owned_efs.efs
}

output "efs_ap" {
  description = "Elastic File System Access Points"
  value       = module.owned_efs.efs_ap
}

output "efs_replica_usw1" {
  description = "Replicated Elastic File System info"
  value       = module.owned_efs_replica_usw1.efs
}

output "efs_replica_ap_usw1" {
  description = "Replicated Elastic File System Access Points"
  value       = module.owned_efs_replica_usw1.efs_ap
}
