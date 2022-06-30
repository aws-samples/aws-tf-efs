output "efs" {
  description = "Elastic File System info"
  value       = module.shared_efs.efs
}

output "efs_ap" {
  description = "Elastic File System Access Points"
  value       = module.shared_efs.efs_ap
}
