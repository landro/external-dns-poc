local ingress = {
  local tfvars = import 'terraform.tfvars.json',
  apiVersion: 'networking.k8s.io/v1beta1',
  kind: 'Ingress',
  metadata: {
    name: 'nginx',
    annotations: {
      'kubernetes.io/ingress.class': 'nginx',
      'cert-manager.io/cluster-issuer': tfvars.acme_issuer,
      'external-dns.alpha.kubernetes.io/ttl': '60',
    },
  },
  spec: {
    rules: [
      {
        host: tfvars.mypreview_name + '.' + tfvars.domain_name,
        http: {
          paths: [
            {
              backend: {
                serviceName: 'nginx',
                servicePort: 80,
              },
            },
          ],
        },
      },
    ],
    tls: [
      {
        hosts: [
          tfvars.mypreview_name + '.' + tfvars.domain_name,
        ],
        secretName: 'myingress-cert',
      },
    ],
  },
};
local service = {
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'nginx',
  },
  spec: {
    ports: [
      {
        port: 80,
        targetPort: 80,
      },
    ],
    selector: {
      app: 'nginx',
    },
  },
};
local deplpoyment = {
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'nginx',
  },
  spec: {
    selector: {
      matchLabels: {
        app: 'nginx',
      },
    },
    template: {
      metadata: {
        labels: {
          app: 'nginx',
        },
      },
      spec: {
        containers: [
          {
            image: 'nginx',
            name: 'nginx',
            ports: [
              {
                containerPort: 80,
              },
            ],
          },
        ],
      },
    },
  },
};

{
  kind: 'List',
  apiVersion: 'v1',
  items: [ingress, service, deplpoyment],
}
