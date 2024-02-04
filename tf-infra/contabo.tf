resource "contabo_instance" "vps1" {
  display_name = "vps1"
  product_id   = "V1"
  image_id     = data.contabo_image.ubuntu_22_04.id
}

resource "contabo_instance" "vps2" {
  display_name = "vps2"
  product_id   = "V1"
}

data "contabo_image" "ubuntu_22_04" {
  id = "afecbb85-e2fc-46f0-9684-b46b1faf00bb"
}
