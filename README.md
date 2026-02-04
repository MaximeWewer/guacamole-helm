# Guacamole Helm Chart

A production-ready Helm chart for deploying [Apache Guacamole](https://guacamole.apache.org/) - a clientless remote desktop gateway supporting VNC, RDP, SSH, Telnet, and Kubernetes.

## Features

- **Kubernetes Operator-Based Databases**: Leverages production-grade operators for database management
  - [CloudNative-PG](https://cloudnative-pg.io/) for PostgreSQL (HA, backups, TLS)
  - [MariaDB Operator](https://github.com/mariadb-operator/mariadb-operator) for MariaDB (Galera, replication, backups)
  - [MySQL Operator](https://dev.mysql.com/doc/mysql-operator/en/) for MySQL InnoDB Cluster
- **External Database Support**: SQL Server, managed databases (RDS, Cloud SQL, Azure Database)
- **Automatic Schema Initialization**: Helm hooks handle Guacamole schema creation
- **Comprehensive Authentication**:
  - OIDC (OpenID Connect)
  - SAML 2.0
  - LDAP/Active Directory
  - TOTP (Time-based One-Time Password)
  - Duo Security 2FA
  - RADIUS
  - CAS (Central Authentication Service)
  - JSON tokens
  - HTTP Header (reverse proxy)
  - SSL/Certificate
- **Vault Integration**: Keeper Secrets Manager (KSM)
- **QuickConnect**: Ad-hoc connections via URI
- **Session Recording**: With playback support
- **High Availability**: PDB, HPA, pod anti-affinity
- **Security**: Network policies, RBAC, security contexts
- **Ingress**: TLS support with WebSocket configuration

## Prerequisites

- Kubernetes 1.25+
- Helm 3.x
- PV provisioner (for database and recordings persistence)

### Database Operators (Required for internal databases)

Before deploying this chart with an internal database, install the corresponding operator:

#### CloudNative-PG (PostgreSQL) - Recommended

```bash
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm install cnpg cnpg/cloudnative-pg \
  --namespace cnpg-system --create-namespace
```

#### MariaDB Operator

```bash
helm repo add mariadb-operator https://helm.mariadb.com/mariadb-operator
helm install mariadb-operator-crds mariadb-operator/mariadb-operator-crds \
  --namespace mariadb-operator --create-namespace
helm install mariadb-operator mariadb-operator/mariadb-operator \
  --namespace mariadb-operator
```

#### MySQL Operator

```bash
helm repo add mysql-operator https://mysql.github.io/mysql-operator/
helm install mysql-operator mysql-operator/mysql-operator \
  --namespace mysql-operator --create-namespace
```

## Installation

### Quick Start (with PostgreSQL)

```bash
# Install CloudNative-PG operator first
kubectl apply --server-side -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.28/releases/cnpg-1.28.0.yaml

# Install Guacamole
helm install guacamole ./chart -n guacamole --create-namespace
```

### From Repository

```bash
helm repo add guacamole https://github.com/maximewewer/guacamole-helm
helm repo update
helm install guacamole guacamole/guacamole -n guacamole --create-namespace
```

## Database Configuration

### Operator-Managed Databases

This chart creates CRDs managed by Kubernetes operators. The operators handle:

- Cluster provisioning and lifecycle
- High availability and failover
- Backups and point-in-time recovery
- TLS certificate management
- Monitoring and metrics

The chart's `job-db-init` hook handles Guacamole schema initialization automatically.

| Database   | Operator        | CRD Created      | Default |
|------------|-----------------|------------------|---------|
| PostgreSQL | CloudNative-PG  | `Cluster`        | Yes     |
| MySQL      | MySQL Operator  | `InnoDBCluster`  | No      |
| MariaDB    | MariaDB Operator| `MariaDB`        | No      |

#### PostgreSQL (CloudNative-PG)

```yaml
postgresql:
  enabled: true
  instances: 3  # HA cluster
  image:
    repository: ghcr.io/cloudnative-pg/postgresql
    tag: "18"
  auth:
    database: guacamole
    username: guacamole
    password: "secure-password"  # Or use existingSecret
  storage:
    size: 10Gi
    storageClass: "fast-ssd"
  # High Availability
  ha:
    enabled: true
    minSyncReplicas: 1
    maxSyncReplicas: 2
  # TLS encryption
  tls:
    enabled: true
  # Connection pooling (PgBouncer)
  pooler:
    enabled: true
    instances: 2
    poolMode: transaction
  # Automated backups to S3
  backup:
    enabled: true
    schedule: "0 0 * * *"
    retentionPolicy: "30d"
    s3:
      bucket: my-backup-bucket
      secretName: s3-credentials
  # Prometheus monitoring
  monitoring:
    enabled: true
    podMonitor: true
```

#### MySQL (InnoDB Cluster)

```yaml
postgresql:
  enabled: false

mysql:
  enabled: true
  instances: 3
  version: "9.6.0"
  router:
    instances: 2
  auth:
    database: guacamole
    username: guacamole
    password: "secure-password"
    rootPassword: "root-secure-password"
  storage:
    size: 10Gi
  tls:
    useSelfSigned: true  # Or provide existingSecret
  backup:
    enabled: true
    schedule: "0 2 * * *"
    s3:
      bucket: my-backup-bucket
      secretName: s3-credentials
```

#### MariaDB (with Galera)

```yaml
postgresql:
  enabled: false

mariadb:
  enabled: true
  replicas: 3
  image:
    repository: mariadb
    tag: "12.1"
  auth:
    database: guacamole
    username: guacamole
    password: "secure-password"
    rootPassword: "root-secure-password"
  storage:
    size: 10Gi
  # Galera multi-master clustering
  galera:
    enabled: true
    recovery:
      enabled: true
      clusterHealthyTimeout: "3m"
  # Or async replication instead
  # replication:
  #   enabled: true
  #   mode: semi-sync
  # TLS encryption
  tls:
    enabled: true
    existingSecret: mariadb-tls-certs
  # S3 backups
  backup:
    enabled: true
    schedule: "0 3 * * *"
    maxRetained: 7
    s3:
      bucket: my-backup-bucket
      secretName: s3-credentials
  # Prometheus metrics
  metrics:
    enabled: true
    serviceMonitor:
      enabled: true
```

### External Database (BYO Database)

For managed databases (RDS, Cloud SQL, Azure Database) or existing infrastructure:

```yaml
# Disable internal databases
postgresql:
  enabled: false

# Configure external database
database:
  type: postgresql  # postgresql, mysql, mariadb, sqlserver
  external:
    enabled: true
    hostname: "your-rds-instance.region.rds.amazonaws.com"
    port: 5432
    database: guacamole
    username: guacamole
    existingSecret: guacamole-db-credentials  # Must contain key: password
```

> **Note**: SQL Server is only supported as an external database.

## Complete Production Example

```yaml
# values-production.yaml

guacamole:
  replicaCount: 3
  resources:
    requests:
      memory: 512Mi
      cpu: 500m
    limits:
      memory: 1Gi
      cpu: 1000m
  pdb:
    enabled: true
    minAvailable: 2

guacd:
  replicaCount: 3
  pdb:
    enabled: true
    minAvailable: 2

# PostgreSQL with CloudNative-PG
postgresql:
  enabled: true
  instances: 3
  auth:
    existingSecret: guacamole-postgresql-secret
  storage:
    size: 20Gi
    storageClass: fast-ssd
  ha:
    enabled: true
    minSyncReplicas: 1
    maxSyncReplicas: 2
  tls:
    enabled: true
  pooler:
    enabled: true
    instances: 2
  backup:
    enabled: true
    schedule: "0 2 * * *"
    retentionPolicy: "30d"
    s3:
      bucket: guacamole-backups
      secretName: backup-s3-credentials
  monitoring:
    enabled: true
    podMonitor: true
  resources:
    requests:
      memory: 512Mi
      cpu: 250m
    limits:
      memory: 2Gi
      cpu: 1000m

auth:
  oidc:
    enabled: true
    authorizationEndpoint: "https://keycloak.example.com/realms/corp/protocol/openid-connect/auth"
    issuer: "https://keycloak.example.com/realms/corp"
    jwksEndpoint: "https://keycloak.example.com/realms/corp/protocol/openid-connect/certs"
    clientId: "guacamole"
    existingSecret: guacamole-oidc-secret
  totp:
    enabled: true
    mode: required

recording:
  enabled: true
  playback:
    enabled: true
  persistence:
    enabled: true
    size: 100Gi

api:
  session:
    timeout: 60
    maxConnectionsPerUser: 10

bruteForce:
  enabled: true

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/proxy-buffering: "off"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
  hosts:
    - host: guacamole.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: guacamole-tls
      hosts:
        - guacamole.example.com

networkPolicy:
  enabled: true
```

## Accessing Guacamole

### Default Credentials

- **Username**: `guacadmin`
- **Password**: `guacadmin`

> **Warning**: Change the default password immediately after first login!

### Port Forward (Development)

```bash
kubectl port-forward svc/guacamole 8080:8080 -n guacamole
```

Then open <http://localhost:8080> in your browser.

## Upgrading

```bash
helm upgrade guacamole ./chart -n guacamole -f your-values.yaml
```

## Uninstalling

```bash
helm uninstall guacamole -n guacamole

# Remove PVCs if desired
kubectl delete pvc -l app.kubernetes.io/instance=guacamole -n guacamole
```

## Parameters Reference

See [chart/values.yaml](chart/values.yaml) for the complete list of configurable parameters.

### Key Parameters

| Parameter                | Description                        | Default      |
|--------------------------|------------------------------------|--------------|
| `guacamole.enabled`      | Enable Guacamole deployment        | `true`       |
| `guacamole.replicaCount` | Number of replicas                 | `1`          |
| `guacd.enabled`          | Enable guacd deployment            | `true`       |
| `guacd.replicaCount`     | Number of replicas                 | `1`          |
| `database.type`          | Database type (for external)       | `postgresql` |
| `postgresql.enabled`     | Deploy PostgreSQL (CNPG)           | `true`       |
| `postgresql.instances`   | Number of PostgreSQL instances     | `1`          |
| `postgresql.ha.enabled`  | Enable synchronous replication     | `false`      |
| `mysql.enabled`          | Deploy MySQL (InnoDB Cluster)      | `false`      |
| `mysql.instances`        | Number of MySQL instances          | `1`          |
| `mariadb.enabled`        | Deploy MariaDB                     | `false`      |
| `mariadb.replicas`       | Number of MariaDB replicas         | `1`          |
| `mariadb.galera.enabled` | Enable Galera clustering           | `false`      |
| `auth.oidc.enabled`      | Enable OIDC auth                   | `false`      |
| `auth.ldap.enabled`      | Enable LDAP auth                   | `false`      |
| `auth.saml.enabled`      | Enable SAML auth                   | `false`      |
| `auth.totp.enabled`      | Enable TOTP 2FA                    | `false`      |
| `auth.duo.enabled`       | Enable Duo 2FA                     | `false`      |
| `auth.radius.enabled`    | Enable RADIUS auth                 | `false`      |
| `auth.cas.enabled`       | Enable CAS auth                    | `false`      |
| `auth.header.enabled`    | Enable HTTP header auth            | `false`      |
| `auth.ssl.enabled`       | Enable SSL cert auth               | `false`      |
| `vault.ksm.enabled`      | Enable Keeper Secrets Manager      | `false`      |
| `quickConnect.enabled`   | Enable QuickConnect                | `false`      |
| `recording.enabled`      | Enable session recording           | `false`      |
| `ingress.enabled`        | Enable Ingress                     | `false`      |
| `networkPolicy.enabled`  | Enable network policies            | `false`      |

## Troubleshooting

### Database Connection Issues

Check the db-init job logs:

```bash
# List jobs
kubectl get jobs -n guacamole

# Check job logs
kubectl logs job/guacamole-db-init -n guacamole --all-containers
```

### Operator CRD Issues

Verify the operator is running and the CRD is created:

```bash
# CloudNative-PG
kubectl get clusters.postgresql.cnpg.io -n guacamole
kubectl describe cluster guacamole-postgresql -n guacamole

# MariaDB
kubectl get mariadbs.k8s.mariadb.com -n guacamole

# MySQL
kubectl get innodbclusters.mysql.oracle.com -n guacamole
```

### WebSocket Connection Failures

Ensure your ingress has proper timeout and buffering settings:

```yaml
ingress:
  annotations:
    nginx.ingress.kubernetes.io/proxy-buffering: "off"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
```

## License

Apache License 2.0

## Links

- [Apache Guacamole](https://guacamole.apache.org/)
- [Guacamole Documentation](https://guacamole.apache.org/doc/gug/)
- [CloudNative-PG](https://cloudnative-pg.io/)
- [MariaDB Operator](https://github.com/mariadb-operator/mariadb-operator)
- [MySQL Operator](https://dev.mysql.com/doc/mysql-operator/en/)
