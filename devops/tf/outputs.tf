output "instances" {
    value = [for host in linode_instance.app_vm.*: "${host.label} : ${host.ip_address}"]
}

output "loadbalancer" {
    value = "${linode_instance.app_loadbalancer.ip_address}"
}

output "redisdb" {
    value = "${linode_instance.app_redis.ip_address}"
}