job "kibana" {
  datacenters = ["[[env "DC"]]"]
  type = "service"
  group "kibana" {
    update {
      stagger = "10s"
      max_parallel = 1
    }
    count = "[[.kibana.count]]"
    constraint {
      attribute = "${attr.unique.hostname}"
      regexp = "[[.kibana.noderegexp]]"
    }
    restart {
      attempts = 5
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }
    task "kibana" {
      kill_timeout = "180s"
      env {
	ELASTICSEARCH_URL = "http://elasticsearch.service:9200"
      }
      logs {
        max_files     = 5
        max_file_size = 10
      }
      driver = "docker"
      config {
        logging {
            type = "syslog"
            config {
              tag = "${NOMAD_JOB_NAME}${NOMAD_ALLOC_INDEX}"
            }   
        }
	network_mode       = "host"
        force_pull         = true
        image              = "docker.elastic.co/kibana/kibana-oss:[[.kibana.version]]"
        hostname           = "${attr.unique.hostname}"
	dns_servers        = ["${attr.unique.network.ip-address}"]
        dns_search_domains = ["consul","service.consul","node.consul"]
      }
      resources {
        memory  = "[[.kibana.ram]]"
        network {
          mbits = 10
          port "healthcheck" { static = "[[.kibana.port]]" }
        } #network
      } #resources
      service {
        name = "kibana"
        tags = "[[.kibana.version]]"
        port = "healthcheck"
        check {
          name     = "kibana-internal-port-check"
          port     = "healthcheck"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        } #check
      } #service
    } #task
  } #group
} #job
