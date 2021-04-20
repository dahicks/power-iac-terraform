static_resources:

  listeners:
  - name: listener_0
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 10000
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          access_log:
          - name: envoy.access_loggers.stdout
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.stream.v3.StdoutAccessLog
          http_filters:
          - name: envoy.filters.http.router
          route_config:
            name: local_route
            virtual_hosts:
            - name: local_service
              domains: ["*","echo.service.internal"]
              routes:
              - match:
                  prefix: "/"
                route:
                  host_rewrite_literal: echo.service.internal
                  cluster: service_echo

  clusters:
  - name: service_echo
    connect_timeout: 30s
    type: STATIC
    # Comment out the following line to test on v6 networks
    dns_lookup_family: V4_ONLY
    load_assignment:
      cluster_name: service_echo
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: ${address}
                port_value: ${port}