local serviceAccount = {
  apiVersion: 'v1',
  kind: 'ServiceAccount',
  metadata: {
    name: 'external-dns',
  },
};
local clusterRole = {
  apiVersion: 'rbac.authorization.k8s.io/v1beta1',
  kind: 'ClusterRole',
  metadata: {
    name: 'external-dns',
  },
  rules: [
    {
      apiGroups: [
        '',
      ],
      resources: [
        'services',
        'endpoints',
        'pods',
      ],
      verbs: [
        'get',
        'watch',
        'list',
      ],
    },
    {
      apiGroups: [
        'extensions',
        'networking.k8s.io',
      ],
      resources: [
        'ingresses',
      ],
      verbs: [
        'get',
        'watch',
        'list',
      ],
    },
    {
      apiGroups: [
        '',
      ],
      resources: [
        'nodes',
      ],
      verbs: [
        'list',
      ],
    },
  ],
};
local clusterRoleBinding = {
  apiVersion: 'rbac.authorization.k8s.io/v1beta1',
  kind: 'ClusterRoleBinding',
  metadata: {
    name: 'external-dns-viewer',
  },
  roleRef: {
    apiGroup: 'rbac.authorization.k8s.io',
    kind: 'ClusterRole',
    name: 'external-dns',
  },
  subjects: [
    {
      kind: 'ServiceAccount',
      name: 'external-dns',
      namespace: 'default',
    },
  ],
};
local deployment = {
  local tfvars = import 'terraform.tfvars.json',
  local doToken = std.extVar('DIGITALOCEAN_TOKEN'),
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'external-dns',
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: {
        app: 'external-dns',
      },
    },
    strategy: {
      type: 'Recreate',
    },
    template: {
      metadata: {
        labels: {
          app: 'external-dns',
        },
      },
      spec: {
        serviceAccountName: 'external-dns',
        containers: [
          {
            name: 'external-dns',
            image: 'k8s.gcr.io/external-dns/external-dns:v0.7.3',
            args: [
              '--source=ingress',
              '--domain-filter=' + tfvars.domain_name,
              '--provider=digitalocean',
            ],
            env: [
              {
                name: 'DO_TOKEN',
                value: doToken,
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
  items: [serviceAccount, clusterRole, clusterRoleBinding, deployment],
}
