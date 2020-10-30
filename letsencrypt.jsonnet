local secret = {
  apiVersion: 'v1',
  kind: 'Secret',
  metadata: {
    name: 'digitalocean-dns',
    namespace: 'cert-manager',
  },
  data: {
    local doToken = std.extVar('DIGITALOCEAN_TOKEN'),
    'access-token': std.base64(doToken),
  },
};
local clusterIssuerProd = {
  apiVersion: 'cert-manager.io/v1',
  kind: 'ClusterIssuer',
  metadata: {
    name: 'letsencrypt-prod',
  },
  spec: {
    acme: {
      local tfvars = import 'terraform.tfvars.json',
      email: tfvars.acme_email,
      server: 'https://acme-v02.api.letsencrypt.org/directory',
      privateKeySecretRef: {
        name: 'letsencrypt-prod',
      },
      solvers: [
        {
          dns01: {
            digitalocean: {
              tokenSecretRef: {
                name: 'digitalocean-dns',
                key: 'access-token',
              },
            },
          },
        },
      ],
    },
  },
};
local clusterIssuerStaging = {
  apiVersion: 'cert-manager.io/v1',
  kind: 'ClusterIssuer',
  metadata: {
    name: 'letsencrypt-staging',
  },
  spec: {
    acme: {
      local tfvars = import 'terraform.tfvars.json',
      email: tfvars.acme_email,
      server: 'https://acme-staging-v02.api.letsencrypt.org/directory',
      privateKeySecretRef: {
        name: 'letsencrypt-staging',
      },
      solvers: [
        {
          dns01: {
            digitalocean: {
              tokenSecretRef: {
                name: 'digitalocean-dns',
                key: 'access-token',
              },
            },
          },
        },
      ],
    },
  },
};
{
  kind: 'List',
  apiVersion: 'v1',
  items: [secret, clusterIssuerProd, clusterIssuerStaging],
}
