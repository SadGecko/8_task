terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.16.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "wp" {
  name = "sadgecko/wp:last"
}

resource "docker_image" "db" {
  name = "mysql:8"
}

resource "docker_network" "wp_net" {
  name = "wp_net"
}

resource "docker_container" "wp" {
  image = docker_image.wp.latest
  name  = "app"

  ports {
    internal = 80
    external = 8080
  }

  networks_advanced {
    name = docker_network.wp_net.name
  }

  depends_on = [docker_network.wp_net, docker_container.db]
}

resource "docker_volume" "db_volume" {
  name = "database_files"
}

resource "docker_container" "db" {
  image      = docker_image.db.latest
  name       = "db"

  networks_advanced {
    name = docker_network.wp_net.name
  }

  env = ["MYSQL_ROOT_PASSWORD=password", "MYSQL_DATABASE=wp", "MYSQL_USER=wp", "MYSQL_PASSWORD=pass"]

  volumes {
    container_path = "/var/lib/mysql"
    volume_name = docker_volume.db_volume.name
  }

  depends_on = [docker_network.wp_net, docker_volume.db_volume]
}

