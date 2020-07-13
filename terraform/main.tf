provider "google" {
 credentials = file("~/terraform/terraform-cloud-282518-a832d5d911bb.json")
 project     = "terraform-cloud-282518"
 region      = "us-east4-c"
}

resource "google_compute_instance" "master-01" {
 name         = "master-01"
 machine_type = "n1-standard-4"
 zone         = "us-east4-c"
 hostname     = "master-01.internal"

 boot_disk {
   initialize_params {
     image = "centos-cloud/centos-7"
     size  = "50"
   }
 }

 network_interface {
   network    = "default"
   network_ip = "10.150.0.4"
   access_config {
     // Include this section to give the VM an external ip address
   }
 }

 metadata = {
   ssh-keys = "luisfilho:${file("/home/luisfilho/.ssh/id_rsa.pub")}"
 }
}

resource "google_compute_instance" "master-02" {
 name         = "master-02"
 machine_type = "n1-standard-4"
 zone         = "us-central1-b"
 hostname     = "master-02.internal"

 boot_disk {
   initialize_params {
     image = "centos-cloud/centos-7"
     size  = "50"
   }
 }

 network_interface {
   network    = "default"
   network_ip = "10.128.0.9"
   access_config {
     // Include this section to give the VM an external ip address
   }
 }

 metadata = {
   ssh-keys = "luisfilho:${file("/home/luisfilho/.ssh/id_rsa.pub")}"
 }
}

resource "google_compute_instance" "node-01" {
 name         = "node-01"
 machine_type = "n1-standard-1"
 zone         = "us-central1-a"
 hostname     = "node-01.internal"

 boot_disk {
   initialize_params {
     image = "centos-cloud/centos-7"
     size  = "50"
   }
 }

 network_interface {
   network    = "default"
   network_ip = "10.128.0.6"
   access_config {
     // Include this section to give the VM an external ip address
   }
 }

 metadata = {
   ssh-keys = "luisfilho:${file("/home/luisfilho/.ssh/id_rsa.pub")}"
 }
}
resource "google_compute_instance" "node-02" {
 name         = "node-02"
 machine_type = "n1-standard-1"
 zone         = "us-east4-a"
 hostname     = "node-02.internal"

 boot_disk {
   initialize_params {
     image = "centos-cloud/centos-7"
     size  = "50"
   }
 }

 network_interface {
   network    = "default"
   network_ip = "10.150.0.2"
   access_config {
     // Include this section to give the VM an external ip address
   }
 }

 metadata = {
   ssh-keys = "luisfilho:${file("/home/luisfilho/.ssh/id_rsa.pub")}"
 }
}
resource "google_compute_instance" "node-03" {
 name         = "node-03"
 machine_type = "n1-standard-1"
 zone         = "us-east4-a"
 hostname     = "node-03.internal"

 boot_disk {
   initialize_params {
     image = "centos-cloud/centos-7"
     size  = "50"
   }
 }

 network_interface {
   network    = "default"
   network_ip = "10.150.0.3"
   access_config {
     // Include this section to give the VM an external ip address
   }
 }

 metadata = {
   ssh-keys = "luisfilho:${file("/home/luisfilho/.ssh/id_rsa.pub")}"
 }
}


resource "null_resource" "hosts" {
  triggers = {
   public_ip1  = google_compute_instance.master-01.network_interface.0.access_config.0.nat_ip
   public_ip2  = google_compute_instance.master-02.network_interface.0.access_config.0.nat_ip
   public_ip3  = google_compute_instance.node-01.network_interface.0.access_config.0.nat_ip
   public_ip4  = google_compute_instance.node-02.network_interface.0.access_config.0.nat_ip
   public_ip5  = google_compute_instance.node-03.network_interface.0.access_config.0.nat_ip
 }
  
  provisioner "remote-exec" {
   connection {
     type = "ssh"
     user = "luisfilho"
     host = google_compute_instance.master-01.network_interface.0.access_config.0.nat_ip
     private_key = file("/home/luisfilho/.ssh/id_rsa")
   }
   inline = [
     "echo master 1 OK"
   ]
 }

 provisioner "remote-exec" {
   connection {
     type = "ssh"
     user = "luisfilho"
     host = google_compute_instance.master-02.network_interface.0.access_config.0.nat_ip
     private_key = file("/home/luisfilho/.ssh/id_rsa")
   }
   inline = [
     "echo master 2 OK"
   ]
 }

 provisioner "remote-exec" {
   connection {
     type = "ssh"
     user = "luisfilho"
     host = google_compute_instance.node-01.network_interface.0.access_config.0.nat_ip
     private_key = file("/home/luisfilho/.ssh/id_rsa")
   }
   inline = [
     "echo node 1 OK"
   ]
 }

 provisioner "remote-exec" {
   connection {
     type = "ssh"
     user = "luisfilho"
     host = google_compute_instance.node-02.network_interface.0.access_config.0.nat_ip
     private_key = file("/home/luisfilho/.ssh/id_rsa")
   }
   inline = [
     "echo node 2 OK"
   ]
 }

 provisioner "remote-exec" {
   connection {
     type = "ssh"
     user = "luisfilho"
     host = google_compute_instance.node-03.network_interface.0.access_config.0.nat_ip
     private_key = file("/home/luisfilho/.ssh/id_rsa")
   }
   inline = [
     "echo node 3 OK"
   ]
 }

 provisioner "remote-exec" {
   connection {
     type = "ssh"
     user = "luisfilho"
     host = "35.196.60.119"
     private_key = file("/home/luisfilho/.ssh/id_rsa")
   }
   inline = [
     "cd /home/luisfilho/terraform-master/terraform/ansible",
     "ansible-playbook -i hosts cloudera-cdh.yml",
   ]   

 }
}




