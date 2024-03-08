output "entrypoint_url" {
    description = "Shows the URL of nginx index page."
    value       = "http://${module.load_balancer.lb_global_ip}/index.html"
}

output "mig_self_link" {
    description = "MIG hosting nginx"
    value       = module.vm.mig.self_link 
}