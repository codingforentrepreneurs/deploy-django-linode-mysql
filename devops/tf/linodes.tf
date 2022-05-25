resource "linode_instance" "app_vm" {
    count = var.app_instance_vm_count > 0 ? var.app_instance_vm_count : 0
    image = var.linode_image
    region = "us-central"
    type = "g6-standard-1"
    authorized_keys = [ var.authorized_key ]
    root_pass = var.root_user_pw
    private_ip = true
    tags = ["app", "app-node"]
}


resource "linode_instance" "app_loadbalancer" {
    image = "linode/ubuntu20.04"
    label = "app_vm-load-balancer"
    region = "us-central"
    type = "g6-standard-2"
    authorized_keys = [ var.authorized_key]
    root_pass = var.root_user_pw
    private_ip = true
    tags = ["app", "app-lb"]

    lifecycle {
        prevent_destroy = true
    }
}

resource "linode_instance" "app_redis" {
    image = var.linode_image
    label = "app_redis-db"
    region = "us-central"
    type = "g6-standard-1"
    authorized_keys = [ var.authorized_key]
    root_pass = var.root_user_pw
    private_ip = true
    tags = ["app", "app-redis"]

    lifecycle {
        prevent_destroy = true
    }

}


resource "linode_instance" "app_worker" {
    count=1
    image = var.linode_image
    label = "app_worker-${count.index + 1}"
    region = "us-central"
    type = "g6-standard-1"
    authorized_keys = [ var.authorized_key]
    root_pass = var.root_user_pw
    private_ip = true
    tags = ["app", "app-worker"]

    depends_on = [linode_instance.app_redis]
}


resource "local_file" "ansible_inventory" {
    content = templatefile("${local.templates_dir}/ansible-inventory.tpl", {
                      webapps=[for host in linode_instance.app_vm.*: "${host.ip_address}"]
                      loadbalancer="${linode_instance.app_loadbalancer.ip_address}"
                      redis="${linode_instance.app_redis.ip_address}"
                      workers=[for host in linode_instance.app_worker.*: "${host.ip_address}"]
            })
    filename = "${local.ansible_dir}/inventory.ini"

}

resource "linode_domain" "tryiac_com" {
    type = "master"
    domain = "tryiac.com"
    soa_email = "hello@tryiac.com"
    tags = ["app", "app-domain"]
}

resource "linode_domain_record" "tryiac_com_root" {
    domain_id = linode_domain.tryiac_com.id
    name = ""
    record_type = "A"
    ttl_sec = 300
    target = "${linode_instance.app_loadbalancer.ip_address}"
}

resource "linode_domain_record" "tryiac_com_www" {
    domain_id = linode_domain.tryiac_com.id
    name = "www"
    record_type = "A"
    ttl_sec = 300
    target = "${linode_instance.app_loadbalancer.ip_address}"
}