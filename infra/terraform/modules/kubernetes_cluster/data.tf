terraform = {
  required_version = ">= 0.9.3"
}

data "aws_region" "current" {
  current = true
}

data "aws_ami" "kops_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${lookup(var.kops_ami_names, join(".", slice(split(".", var.kubernetes_version), 0, 2)))}"]
  }

  filter {
    name   = "owner-id"
    values = ["383156758163"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "template_file" "az_letters" {
  template = "$${az_letters}"

  vars {
    az_letters = "${ replace(join(",", sort(var.availability_zones)), data.aws_region.current.name, "") }"
  }
}

data "template_file" "master_resource_count" {
  template = "$${master_resource_count}"

  vars {
    master_resource_count = "${var.force_single_master == 1 ? 1 : length(var.availability_zones)}"
  }
}

data "template_file" "master_azs" {
  template = "$${master_azs}"

  vars {
    master_azs = "${var.force_single_master == 1 ? element(sort(var.availability_zones), 0) : join(",", var.availability_zones)}"
  }
}

data "template_file" "etcd_azs" {
  template = "$${etcd_azs}"

  vars {
    etcd_azs = "${var.force_single_master == 1 ? element(split(",", data.template_file.az_letters.rendered), 0) : data.template_file.az_letters.rendered}"
  }
}

data "template_file" "cluster_spec" {
  template = "${file("${path.module}/data/kops/cluster.tpl.yml")}"
}

data "template_file" "bastions_spec" {
  template = "${file("${path.module}/data/kops/bastions.tpl.yml")}"
}

data "template_file" "masters_spec" {
  template = "${file("${path.module}/data/kops/masters.tpl.yml")}"
}

data "template_file" "nodes_spec" {
  template = "${file("${path.module}/data/kops/nodes.tpl.yml")}"
}