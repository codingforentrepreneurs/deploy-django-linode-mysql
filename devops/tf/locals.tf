locals {
    tf_dir = "${abspath(path.root)}"
    templates_dir = "${local.tf_dir}/templates"
    devops_dir = "${dirname(abspath(local.tf_dir))}"
    ansible_dir = "${local.devops_dir}/ansible"
}