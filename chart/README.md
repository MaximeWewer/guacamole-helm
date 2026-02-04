# guacamole

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.6.0](https://img.shields.io/badge/AppVersion-1.6.0-informational?style=flat-square)

A Helm chart for Apache Guacamole - clientless remote desktop gateway

**Homepage:** <https://guacamole.apache.org/>

## TL;DR

```bash
# Install the required operator first (CloudNative-PG for PostgreSQL)
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm install cnpg cnpg/cloudnative-pg \
  --namespace cnpg-system --create-namespace

# Install the chart
helm install guacamole . -n guacamole --create-namespace
```

## Introduction

This chart deploys [Apache Guacamole](https://guacamole.apache.org/) on a Kubernetes cluster. It uses **Kubernetes operators** for database management, providing production-grade features like high availability, automated backups, and TLS encryption.

### Components

- **Guacamole** - Web application (`guacamole/guacamole`)
- **Guacd** - Connection proxy daemon (`guacamole/guacd`)
- **Database** - Managed by Kubernetes operators:
  - PostgreSQL via [CloudNative-PG](https://cloudnative-pg.io/)
  - MySQL via [MySQL Operator](https://dev.mysql.com/doc/mysql-operator/en/)
  - MariaDB via [MariaDB Operator](https://github.com/mariadb-operator/mariadb-operator)

### Features

- Kubernetes operator-based database management (HA, backups, TLS)
- Automatic Guacamole schema initialization via Helm hooks
- Comprehensive authentication (OIDC, SAML, LDAP, TOTP, Duo, RADIUS, CAS)
- Session recording with playback support
- Network policies and RBAC
- Ingress with WebSocket support

## Prerequisites

- Kubernetes 1.25+
- Helm 3.x
- PV provisioner (for persistence)

### Database Operators

Install the operator for your chosen database **before** deploying this chart:

#### CloudNative-PG (PostgreSQL) - Default

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

## Installing the Chart

```bash
helm install guacamole . -n guacamole --create-namespace
```

## Uninstalling the Chart

```bash
helm uninstall guacamole -n guacamole

# Remove PVCs if desired
kubectl delete pvc -l app.kubernetes.io/instance=guacamole -n guacamole
```

## Requirements

Kubernetes: `>=1.25.0-0`

## Configuration

### Database Selection

| Database   | Operator         | CRD Created      | Values Key   |
|------------|------------------|------------------|--------------|
| PostgreSQL | CloudNative-PG   | `Cluster`        | `postgresql` |
| MySQL      | MySQL Operator   | `InnoDBCluster`  | `mysql`      |
| MariaDB    | MariaDB Operator | `MariaDB`        | `mariadb`    |

Only enable **one** internal database at a time. For external databases, set all internal databases to `enabled: false` and configure `database.external`.

### Quick Examples

#### PostgreSQL with HA

```yaml
postgresql:
  enabled: true
  instances: 3
  ha:
    enabled: true
    minSyncReplicas: 1
  auth:
    password: "secure-password"
```

#### MySQL InnoDB Cluster

```yaml
postgresql:
  enabled: false
mysql:
  enabled: true
  instances: 3
  auth:
    password: "secure-password"
    rootPassword: "root-password"
```

#### MariaDB with Galera

```yaml
postgresql:
  enabled: false
mariadb:
  enabled: true
  replicas: 3
  galera:
    enabled: true
  auth:
    password: "secure-password"
    rootPassword: "root-password"
```

#### External Database

```yaml
postgresql:
  enabled: false
database:
  type: postgresql  # postgresql, mysql, mariadb, sqlserver
  external:
    enabled: true
    hostname: "db.example.com"
    port: 5432
    database: guacamole
    username: guacamole
    existingSecret: db-credentials
```

> **Note**: SQL Server is only supported as an external database.

## Values

### Global

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| commonAnnotations | object | `{}` | Common annotations to add to all resources |
| commonLabels | object | `{}` | Common labels to add to all resources |
| fullnameOverride | string | `""` | Override full name |
| nameOverride | string | `""` | Override chart name |

### Guacamole Client

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| guacamole.affinity | object | `{}` | Affinity rules |
| guacamole.containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}` | Container security context |
| guacamole.enabled | bool | `true` | Enable guacamole deployment |
| guacamole.extraEnvFrom | list | `[]` | Additional environment variables from ConfigMap/Secret |
| guacamole.extraEnvVars | list | `[]` | Additional environment variables |
| guacamole.extraVolumeMounts | list | `[]` | Additional volume mounts |
| guacamole.extraVolumes | list | `[]` | Additional volumes |
| guacamole.hpa.enabled | bool | `false` | Enable HorizontalPodAutoscaler |
| guacamole.hpa.maxReplicas | int | `10` | Maximum replicas |
| guacamole.hpa.minReplicas | int | `2` | Minimum replicas |
| guacamole.hpa.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage |
| guacamole.hpa.targetMemoryUtilizationPercentage | int | `80` | Target memory utilization percentage |
| guacamole.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| guacamole.image.repository | string | `"guacamole/guacamole"` | Guacamole image repository |
| guacamole.image.tag | string | `""` | Guacamole image tag (defaults to appVersion) |
| guacamole.imagePullSecrets | list | `[]` | Image pull secrets |
| guacamole.livenessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/","port":"http"},"initialDelaySeconds":60,"periodSeconds":10,"timeoutSeconds":5}` | Liveness probe configuration |
| guacamole.nodeSelector | object | `{}` | Node selector |
| guacamole.pdb.enabled | bool | `false` | Enable PodDisruptionBudget |
| guacamole.pdb.minAvailable | int | `1` | Minimum available pods |
| guacamole.podAntiAffinityPreset | string | `"soft"` | Pod anti-affinity preset (soft/hard/none) |
| guacamole.podSecurityContext | object | `{"fsGroup":1000,"runAsGroup":1000,"runAsNonRoot":true,"runAsUser":1000}` | Pod security context |
| guacamole.readinessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/","port":"http"},"initialDelaySeconds":30,"periodSeconds":5,"timeoutSeconds":3}` | Readiness probe configuration |
| guacamole.replicaCount | int | `1` | Number of replicas |
| guacamole.resources | object | `{"limits":{"cpu":"500m","memory":"512Mi"},"requests":{"cpu":"250m","memory":"256Mi"}}` | Resource requests and limits |
| guacamole.service.annotations | object | `{}` | Service annotations |
| guacamole.service.port | int | `8080` | Service port |
| guacamole.service.type | string | `"ClusterIP"` | Service type |
| guacamole.terminationGracePeriodSeconds | int | `30` | Termination grace period |
| guacamole.tolerations | list | `[]` | Tolerations |
| guacamole.webappContext | string | `"ROOT"` | Webapp context path (use ROOT for /) |

### Guacd (Connection Proxy)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| guacd.affinity | object | `{}` | Affinity rules |
| guacd.containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true}` | Container security context |
| guacd.dnsConfig | object | `{}` | Custom DNS configuration |
| guacd.dnsPolicy | string | `""` | DNS Policy for guacd pods Use "Default" to use the node's DNS (useful for Tailscale/Netbird/VPN) Options: ClusterFirst (default), Default, ClusterFirstWithHostNet, None |
| guacd.enabled | bool | `true` | Enable guacd deployment |
| guacd.extraEnvFrom | list | `[]` | Additional environment variables from ConfigMap/Secret |
| guacd.extraEnvVars | list | `[]` | Additional environment variables |
| guacd.extraVolumeMounts | list | `[]` | Additional volume mounts |
| guacd.extraVolumes | list | `[]` | Additional volumes |
| guacd.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| guacd.image.repository | string | `"guacamole/guacd"` | Guacd image repository |
| guacd.image.tag | string | `""` | Guacd image tag (defaults to appVersion) |
| guacd.imagePullSecrets | list | `[]` | Image pull secrets |
| guacd.livenessProbe | object | `{"failureThreshold":3,"initialDelaySeconds":30,"periodSeconds":10,"tcpSocket":{"port":"guacd"},"timeoutSeconds":5}` | Liveness probe configuration |
| guacd.logLevel | string | `"info"` | Log level (trace, debug, info, warning, error) |
| guacd.nodeSelector | object | `{}` | Node selector |
| guacd.pdb.enabled | bool | `false` | Enable PodDisruptionBudget |
| guacd.pdb.minAvailable | int | `1` | Minimum available pods |
| guacd.podAntiAffinityPreset | string | `"soft"` | Pod anti-affinity preset (soft/hard/none) |
| guacd.podSecurityContext | object | `{"fsGroup":1000,"runAsGroup":1000,"runAsNonRoot":true,"runAsUser":1000}` | Pod security context |
| guacd.readinessProbe | object | `{"failureThreshold":3,"initialDelaySeconds":10,"periodSeconds":5,"tcpSocket":{"port":"guacd"},"timeoutSeconds":3}` | Readiness probe configuration |
| guacd.replicaCount | int | `1` | Number of replicas |
| guacd.resources | object | `{"limits":{"cpu":"500m","memory":"512Mi"},"requests":{"cpu":"250m","memory":"256Mi"}}` | Resource requests and limits |
| guacd.service.annotations | object | `{}` | Service annotations |
| guacd.service.port | int | `4822` | Service port |
| guacd.service.type | string | `"ClusterIP"` | Service type |
| guacd.terminationGracePeriodSeconds | int | `30` | Termination grace period |
| guacd.tolerations | list | `[]` | Tolerations |

### Database Configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| database.external | object | `{"database":"guacamole","enabled":false,"existingSecret":"","existingSecretPasswordKey":"password","hostname":"","password":"","port":"","username":"guacamole"}` | External database configuration Use this for databases not managed by this chart |
| database.external.database | string | `"guacamole"` | External database name |
| database.external.enabled | bool | `false` | Enable external database |
| database.external.existingSecret | string | `""` | Existing secret with database credentials |
| database.external.existingSecretPasswordKey | string | `"password"` | Key in existing secret for password |
| database.external.hostname | string | `""` | External database hostname |
| database.external.password | string | `""` | External database password (use existingSecret for production) |
| database.external.port | string | `""` | External database port (auto-detected based on type if not set) |
| database.external.username | string | `"guacamole"` | External database username |
| database.type | string | `"postgresql"` | Database type (postgresql, mysql, mariadb, sqlserver) Note: sqlserver is only supported as external database |

### PostgreSQL (CloudNative-PG)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| postgresql.affinity | object | `{}` |  |
| postgresql.auth | object | `{"database":"guacamole","existingSecret":"","password":"","username":"guacamole"}` | Database authentication |
| postgresql.auth.database | string | `"guacamole"` | Database name for Guacamole |
| postgresql.auth.existingSecret | string | `""` | Use existing secret for credentials (keys: username, password) |
| postgresql.auth.password | string | `""` | Database password (auto-generated if empty) |
| postgresql.auth.username | string | `"guacamole"` | Database username |
| postgresql.backup | object | `{"azure":{"destinationPath":"","secretName":""},"enabled":false,"gcs":{"destinationPath":"","secretName":""},"retentionPolicy":"30d","s3":{"destinationPath":"","endpointURL":"","secretName":""},"schedule":"0 0 * * *"}` | Backup configuration |
| postgresql.backup.azure | object | `{"destinationPath":"","secretName":""}` | Azure Blob Storage configuration |
| postgresql.backup.azure.destinationPath | string | `""` | Azure container destination path |
| postgresql.backup.azure.secretName | string | `""` | Secret containing Azure credentials |
| postgresql.backup.enabled | bool | `false` | Enable automated backups |
| postgresql.backup.gcs | object | `{"destinationPath":"","secretName":""}` | Google Cloud Storage configuration |
| postgresql.backup.gcs.destinationPath | string | `""` | GCS bucket destination path |
| postgresql.backup.gcs.secretName | string | `""` | Secret containing GCS credentials |
| postgresql.backup.retentionPolicy | string | `"30d"` | Backup retention policy |
| postgresql.backup.s3 | object | `{"destinationPath":"","endpointURL":"","secretName":""}` | S3-compatible object storage configuration |
| postgresql.backup.s3.destinationPath | string | `""` | S3 bucket destination path (e.g., s3://bucket/path) |
| postgresql.backup.s3.endpointURL | string | `""` | S3 endpoint URL (for non-AWS S3) |
| postgresql.backup.s3.secretName | string | `""` | Secret containing S3 credentials Must contain keys: ACCESS_KEY_ID, ACCESS_SECRET_KEY |
| postgresql.backup.schedule | string | `"0 0 * * *"` | Backup schedule (cron format) |
| postgresql.enabled | bool | `true` | Enable PostgreSQL via CloudNative-PG operator |
| postgresql.ha | object | `{"enabled":false,"maxSyncReplicas":1,"minSyncReplicas":1}` | High Availability configuration |
| postgresql.ha.enabled | bool | `false` | Enable synchronous replication (requires instances >= 2) |
| postgresql.ha.maxSyncReplicas | int | `1` | Maximum number of synchronous replicas |
| postgresql.ha.minSyncReplicas | int | `1` | Minimum number of synchronous replicas |
| postgresql.image.repository | string | `"ghcr.io/cloudnative-pg/postgresql"` | PostgreSQL image (CNPG format) |
| postgresql.image.tag | string | `"18"` | PostgreSQL version tag |
| postgresql.instances | int | `1` | Number of instances (1 for standalone, 3+ for HA) |
| postgresql.monitoring | object | `{"enabled":false,"podMonitor":false}` | Monitoring configuration |
| postgresql.monitoring.enabled | bool | `false` | Enable Prometheus metrics |
| postgresql.monitoring.podMonitor | bool | `false` | Enable default PodMonitor |
| postgresql.nodeSelector | object | `{}` | Scheduling configuration |
| postgresql.pooler | object | `{"defaultPoolSize":10,"enabled":false,"instances":1,"maxClientConnections":100,"poolMode":"session","resources":{}}` | Connection pooler (PgBouncer) configuration |
| postgresql.pooler.defaultPoolSize | int | `10` | Default pool size |
| postgresql.pooler.enabled | bool | `false` | Enable PgBouncer connection pooler |
| postgresql.pooler.instances | int | `1` | Number of pooler instances |
| postgresql.pooler.maxClientConnections | int | `100` | Maximum client connections |
| postgresql.pooler.poolMode | string | `"session"` | Pooling mode (session, transaction, statement) |
| postgresql.pooler.resources | object | `{}` | Resources for pooler pods |
| postgresql.resources | object | `{}` | Resource requests/limits for PostgreSQL pods |
| postgresql.storage | object | `{"size":"8Gi","storageClass":""}` | Storage configuration |
| postgresql.storage.size | string | `"8Gi"` | Storage size |
| postgresql.storage.storageClass | string | `""` | Storage class (empty for default) |
| postgresql.tls | object | `{"enabled":false,"existingSecret":""}` | TLS configuration |
| postgresql.tls.enabled | bool | `false` | Enable TLS for client connections |
| postgresql.tls.existingSecret | string | `""` | Existing secret containing TLS certificates Must contain keys: tls.crt, tls.key, ca.crt |
| postgresql.tolerations | list | `[]` |  |

### MySQL (MySQL Operator)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| mysql.affinity | object | `{}` |  |
| mysql.auth | object | `{"database":"guacamole","existingSecret":"","password":"","rootPassword":"","username":"guacamole"}` | Database authentication |
| mysql.auth.database | string | `"guacamole"` | Database name for Guacamole |
| mysql.auth.existingSecret | string | `""` | Use existing secret for root credentials Must contain keys: rootUser, rootHost, rootPassword |
| mysql.auth.password | string | `""` | Database password (auto-generated if empty) |
| mysql.auth.rootPassword | string | `""` | Root password (auto-generated if empty) |
| mysql.auth.username | string | `"guacamole"` | Database username |
| mysql.backup | object | `{"enabled":false,"schedule":"0 0 * * *","storage":{"s3":{"bucketName":"","endpoint":"","secretName":""}}}` | Backup configuration |
| mysql.backup.enabled | bool | `false` | Enable automated backups |
| mysql.backup.schedule | string | `"0 0 * * *"` | Backup schedule (cron format) |
| mysql.backup.storage | object | `{"s3":{"bucketName":"","endpoint":"","secretName":""}}` | Backup storage configuration |
| mysql.backup.storage.s3 | object | `{"bucketName":"","endpoint":"","secretName":""}` | S3-compatible storage |
| mysql.backup.storage.s3.bucketName | string | `""` | S3 bucket name |
| mysql.backup.storage.s3.endpoint | string | `""` | S3 endpoint URL |
| mysql.backup.storage.s3.secretName | string | `""` | Secret containing S3 credentials |
| mysql.enabled | bool | `false` | Enable MySQL via MySQL Operator |
| mysql.instances | int | `1` | Number of MySQL server instances (1 for standalone, 3+ for InnoDB Cluster) |
| mysql.nodeSelector | object | `{}` | Scheduling configuration |
| mysql.resources | object | `{}` | Resource requests/limits for MySQL pods |
| mysql.router | object | `{"instances":1,"resources":{}}` | MySQL Router configuration |
| mysql.router.instances | int | `1` | Number of router instances |
| mysql.router.resources | object | `{}` | Resources for router pods |
| mysql.storage | object | `{"size":"8Gi","storageClass":""}` | Storage configuration |
| mysql.storage.size | string | `"8Gi"` | Storage size |
| mysql.storage.storageClass | string | `""` | Storage class (empty for default) |
| mysql.tls | object | `{"existingSecret":"","useSelfSigned":true}` | TLS configuration |
| mysql.tls.existingSecret | string | `""` | Use existing secret for TLS certificates Must contain keys: tls.crt, tls.key, ca.crt |
| mysql.tls.useSelfSigned | bool | `true` | Use self-signed certificates |
| mysql.tolerations | list | `[]` |  |
| mysql.version | string | `"9.6.0"` | MySQL version |

### MariaDB (MariaDB Operator)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| mariadb.affinity | object | `{}` |  |
| mariadb.auth | object | `{"database":"guacamole","existingSecret":"","password":"","rootPassword":"","username":"guacamole"}` | Database authentication |
| mariadb.auth.database | string | `"guacamole"` | Database name for Guacamole |
| mariadb.auth.existingSecret | string | `""` | Use existing secret for credentials Must contain keys: root-password, password |
| mariadb.auth.password | string | `""` | Database password (auto-generated if empty) |
| mariadb.auth.rootPassword | string | `""` | Root password (auto-generated if empty) |
| mariadb.auth.username | string | `"guacamole"` | Database username |
| mariadb.backup | object | `{"enabled":false,"maxRetained":7,"s3":{"bucket":"","endpoint":"","secretName":""},"schedule":"0 0 * * *"}` | Backup configuration |
| mariadb.backup.enabled | bool | `false` | Enable automated backups |
| mariadb.backup.maxRetained | int | `7` | Maximum retained backups |
| mariadb.backup.s3 | object | `{"bucket":"","endpoint":"","secretName":""}` | S3 storage configuration |
| mariadb.backup.s3.bucket | string | `""` | S3 bucket name |
| mariadb.backup.s3.endpoint | string | `""` | S3 endpoint URL |
| mariadb.backup.s3.secretName | string | `""` | Secret containing S3 credentials Must contain keys: access-key-id, secret-access-key |
| mariadb.backup.schedule | string | `"0 0 * * *"` | Backup schedule (cron format) |
| mariadb.enabled | bool | `false` | Enable MariaDB via MariaDB Operator |
| mariadb.galera | object | `{"agent":{"image":"ghcr.io/mariadb-operator/mariadb-operator:25.10.4"},"enabled":false,"recovery":{"clusterBootstrapTimeout":"10m","clusterHealthyTimeout":"3m","enabled":true,"podRecoveryTimeout":"5m","podSyncTimeout":"5m"}}` | High Availability with Galera |
| mariadb.galera.agent | object | `{"image":"ghcr.io/mariadb-operator/mariadb-operator:25.10.4"}` | Galera agent image |
| mariadb.galera.enabled | bool | `false` | Enable Galera cluster (requires replicas >= 3) |
| mariadb.galera.recovery | object | `{"clusterBootstrapTimeout":"10m","clusterHealthyTimeout":"3m","enabled":true,"podRecoveryTimeout":"5m","podSyncTimeout":"5m"}` | Galera recovery configuration |
| mariadb.image.repository | string | `"mariadb"` | MariaDB image repository |
| mariadb.image.tag | string | `"12.1"` | MariaDB version tag |
| mariadb.metrics | object | `{"enabled":false,"image":"prom/mysqld-exporter:v0.18.0","resources":{},"serviceMonitor":{"enabled":false}}` | Metrics / Monitoring |
| mariadb.metrics.enabled | bool | `false` | Enable Prometheus metrics exporter |
| mariadb.metrics.image | string | `"prom/mysqld-exporter:v0.18.0"` | Exporter image |
| mariadb.metrics.resources | object | `{}` | Resources for exporter |
| mariadb.metrics.serviceMonitor | object | `{"enabled":false}` | Create ServiceMonitor for Prometheus Operator |
| mariadb.myCnf | string | `""` | Custom MariaDB configuration (my.cnf format) Will be appended to the default configuration |
| mariadb.nodeSelector | object | `{}` | Scheduling configuration |
| mariadb.replicas | int | `1` | Number of replicas (1 for standalone, 3+ for Galera) |
| mariadb.replication | object | `{"enabled":false,"mode":"async"}` | Replication configuration (alternative to Galera) |
| mariadb.replication.enabled | bool | `false` | Enable async replication |
| mariadb.replication.mode | string | `"async"` | Replication mode (async, semi-sync) |
| mariadb.resources | object | `{}` | Resource requests/limits for MariaDB pods |
| mariadb.storage | object | `{"size":"8Gi","storageClass":""}` | Storage configuration |
| mariadb.storage.size | string | `"8Gi"` | Storage size |
| mariadb.storage.storageClass | string | `""` | Storage class (empty for default) |
| mariadb.tls | object | `{"enabled":false,"existingSecret":""}` | TLS configuration |
| mariadb.tls.enabled | bool | `false` | Enable TLS |
| mariadb.tls.existingSecret | string | `""` | Use existing secret for TLS certificates |
| mariadb.tolerations | list | `[]` |  |

### Authentication

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| auth.cas | object | `{"authorizationEndpoint":"","clearpassKey":"","enabled":false,"groupAttribute":"","groupFormat":"plain","groupLdapAttribute":"","groupLdapBaseDn":"","redirectUri":""}` | CAS (Central Authentication Service) SSO |
| auth.cas.authorizationEndpoint | string | `""` | CAS server authorization endpoint |
| auth.cas.clearpassKey | string | `""` | Path to private key for ClearPass |
| auth.cas.enabled | bool | `false` | Enable CAS authentication |
| auth.cas.groupAttribute | string | `""` | CAS attribute for group membership |
| auth.cas.groupFormat | string | `"plain"` | Group name format (plain or ldap) |
| auth.cas.groupLdapAttribute | string | `""` | LDAP attribute for group filtering |
| auth.cas.groupLdapBaseDn | string | `""` | LDAP base DN for group filtering |
| auth.cas.redirectUri | string | `""` | Redirect URI for CAS callback |
| auth.database | object | `{"enabled":true}` | Enable database authentication (always enabled when database configured) |
| auth.duo | object | `{"apiHostname":"","authTimeout":5,"bypassHosts":"","clientId":"","clientSecret":"","enabled":false,"enforceHosts":"","existingSecret":"","redirectUri":""}` | Duo two-factor authentication |
| auth.duo.apiHostname | string | `""` | Duo API hostname |
| auth.duo.authTimeout | int | `5` | Authentication timeout in minutes |
| auth.duo.bypassHosts | string | `""` | Comma-separated IPs/subnets to bypass Duo |
| auth.duo.clientId | string | `""` | Duo client ID |
| auth.duo.clientSecret | string | `""` | Duo client secret (use existingSecret for production) |
| auth.duo.enabled | bool | `false` | Enable Duo 2FA |
| auth.duo.enforceHosts | string | `""` | Comma-separated IPs/subnets that must use Duo |
| auth.duo.existingSecret | string | `""` | Existing secret with Duo credentials |
| auth.duo.redirectUri | string | `""` | Redirect URI for Duo callback |
| auth.header | object | `{"enabled":false,"httpAuthHeader":"REMOTE_USER"}` | HTTP Header authentication |
| auth.header.enabled | bool | `false` | Enable HTTP header authentication |
| auth.header.httpAuthHeader | string | `"REMOTE_USER"` | HTTP header containing authenticated username |
| auth.json | object | `{"enabled":false,"existingSecret":"","secretKey":""}` | JSON authentication |
| auth.json.enabled | bool | `false` | Enable JSON authentication |
| auth.json.existingSecret | string | `""` | Existing secret with JSON secret key |
| auth.json.secretKey | string | `""` | 128-bit secret key as 32-character hex string |
| auth.ldap | object | `{"enabled":false,"encryption":"none","existingSecret":"","extraConfig":{},"hostname":"","port":389,"searchBindDn":"","searchBindPassword":"","userBaseDn":"","usernameAttribute":"uid"}` | LDAP authentication |
| auth.ldap.enabled | bool | `false` | Enable LDAP authentication |
| auth.ldap.encryption | string | `"none"` | LDAP encryption (none, ssl, starttls) |
| auth.ldap.existingSecret | string | `""` | Existing secret with LDAP bind password |
| auth.ldap.extraConfig | object | `{}` | Additional LDAP configuration |
| auth.ldap.hostname | string | `""` | LDAP server hostname |
| auth.ldap.port | int | `389` | LDAP server port |
| auth.ldap.searchBindDn | string | `""` | Search bind DN (optional) |
| auth.ldap.searchBindPassword | string | `""` | Search bind password (use existingSecret for production) |
| auth.ldap.userBaseDn | string | `""` | User base DN |
| auth.ldap.usernameAttribute | string | `"uid"` | Username attribute |
| auth.oidc | object | `{"authorizationEndpoint":"","clientId":"","clientSecret":"","enabled":false,"existingSecret":"","extraConfig":{},"issuer":"","jwksEndpoint":"","redirectUri":"","scope":"openid profile email","usernameClaim":"preferred_username"}` | OpenID Connect authentication |
| auth.oidc.authorizationEndpoint | string | `""` | Authorization endpoint URL |
| auth.oidc.clientId | string | `""` | Client ID |
| auth.oidc.clientSecret | string | `""` | Client secret (use existingSecret for production) |
| auth.oidc.enabled | bool | `false` | Enable OIDC authentication |
| auth.oidc.existingSecret | string | `""` | Existing secret with OIDC client credentials |
| auth.oidc.extraConfig | object | `{}` | Additional OIDC configuration |
| auth.oidc.issuer | string | `""` | Issuer URL |
| auth.oidc.jwksEndpoint | string | `""` | JWKS endpoint URL |
| auth.oidc.redirectUri | string | `""` | Redirect URI |
| auth.oidc.scope | string | `"openid profile email"` | Scopes |
| auth.oidc.usernameClaim | string | `"preferred_username"` | Username claim |
| auth.radius | object | `{"authPort":1812,"authProtocol":"pap","caFile":"","caPassword":"","caType":"","eapTtlsInnerProtocol":"","enabled":false,"existingSecret":"","hostname":"localhost","keyFile":"","keyPassword":"","keyType":"","nasIp":"","retries":5,"sharedSecret":"","timeout":60,"trustAll":false}` | RADIUS authentication |
| auth.radius.authPort | int | `1812` | RADIUS authentication port |
| auth.radius.authProtocol | string | `"pap"` | Authentication protocol |
| auth.radius.caFile | string | `""` | Path to CA file |
| auth.radius.caPassword | string | `""` | CA file password |
| auth.radius.caType | string | `""` | CA file type |
| auth.radius.eapTtlsInnerProtocol | string | `""` | EAP-TTLS inner protocol |
| auth.radius.enabled | bool | `false` | Enable RADIUS authentication |
| auth.radius.existingSecret | string | `""` | Existing secret with RADIUS shared secret |
| auth.radius.hostname | string | `"localhost"` | RADIUS server hostname |
| auth.radius.keyFile | string | `""` | Path to client key file |
| auth.radius.keyPassword | string | `""` | Key file password |
| auth.radius.keyType | string | `""` | Key file type |
| auth.radius.nasIp | string | `""` | Network Access Server IP |
| auth.radius.retries | int | `5` | Connection retries |
| auth.radius.sharedSecret | string | `""` | RADIUS shared secret (use existingSecret for production) |
| auth.radius.timeout | int | `60` | Connection timeout in seconds |
| auth.radius.trustAll | bool | `false` | Trust all certificates |
| auth.saml | object | `{"callbackUrl":"","enabled":false,"entityId":"","existingSecret":"","extraConfig":{},"idpMetadataUrl":""}` | SAML authentication |
| auth.saml.callbackUrl | string | `""` | Callback URL |
| auth.saml.enabled | bool | `false` | Enable SAML authentication |
| auth.saml.entityId | string | `""` | Entity ID |
| auth.saml.existingSecret | string | `""` | Existing secret with SAML credentials |
| auth.saml.extraConfig | object | `{}` | Additional SAML configuration |
| auth.saml.idpMetadataUrl | string | `""` | IdP metadata URL |
| auth.ssl | object | `{"authUri":"","clientCertificateHeader":"X-Client-Certificate","clientVerifiedHeader":"X-Client-Verified","enabled":false,"maxDomainValidity":5,"maxTokenValidity":5,"primaryUri":"","subjectBaseDn":"","subjectUsernameAttribute":""}` | SSL/Certificate authentication |
| auth.ssl.authUri | string | `""` | URI requiring client certificate |
| auth.ssl.clientCertificateHeader | string | `"X-Client-Certificate"` | HTTP header containing URL-encoded client certificate |
| auth.ssl.clientVerifiedHeader | string | `"X-Client-Verified"` | HTTP header indicating certificate verification status |
| auth.ssl.enabled | bool | `false` | Enable SSL certificate authentication |
| auth.ssl.maxDomainValidity | int | `5` | Temporary subdomain validity in minutes |
| auth.ssl.maxTokenValidity | int | `5` | Token validity duration in minutes |
| auth.ssl.primaryUri | string | `""` | URI without client certificate requirement |
| auth.ssl.subjectBaseDn | string | `""` | Base DN to restrict valid certificate subject DNs |
| auth.ssl.subjectUsernameAttribute | string | `""` | LDAP attribute from certificate DN to extract username |
| auth.totp | object | `{"enabled":false,"issuer":"Apache Guacamole","keyLength":32,"mode":"optional"}` | TOTP (Two-Factor) authentication |
| auth.totp.enabled | bool | `false` | Enable TOTP |
| auth.totp.issuer | string | `"Apache Guacamole"` | Issuer name shown in authenticator apps |
| auth.totp.keyLength | int | `32` | Key length (16, 24, or 32) |
| auth.totp.mode | string | `"optional"` | TOTP mode (required or optional) |

### Proxy

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| proxy.allowedIpsRegex | string | `"127\\.0\\.0\\.1|::1|10\\..*|172\\.(1[6-9]|2[0-9]|3[0-1])\\..*|192\\.168\\..*"` | Trusted proxy IP regex |
| proxy.enabled | bool | `true` | Enable remote IP valve for reverse proxy |
| proxy.ipHeader | string | `"X-Forwarded-For"` | IP header name |
| proxy.protocolHeader | string | `"X-Forwarded-Proto"` | Protocol header name |

### Vault / Secrets Management

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| vault.ksm | object | `{"allowUnverifiedCert":false,"allowUserConfig":false,"apiCallInterval":"","config":"","enabled":false,"existingSecret":"","stripWindowsDomains":false}` | Keeper Secrets Manager (KSM) integration |
| vault.ksm.allowUnverifiedCert | bool | `false` | Accept unverified certificates |
| vault.ksm.allowUserConfig | bool | `false` | Allow users to configure their own KSM vaults |
| vault.ksm.apiCallInterval | string | `""` | Minimum milliseconds between API calls |
| vault.ksm.config | string | `""` | Base64-encoded KSM configuration |
| vault.ksm.enabled | bool | `false` | Enable KSM integration |
| vault.ksm.existingSecret | string | `""` | Existing secret with KSM config |
| vault.ksm.stripWindowsDomains | bool | `false` | Strip Windows domain prefixes from usernames |

### QuickConnect

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| quickConnect.allowedParameters | string | `""` | Allowed parameters (comma-separated whitelist) |
| quickConnect.deniedParameters | string | `""` | Denied parameters (comma-separated blacklist) |
| quickConnect.enabled | bool | `false` | Enable QuickConnect for ad-hoc connections |

### Recording

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| recording.createRecordingIndex | bool | `true` | Create search index |
| recording.enabled | bool | `false` | Enable session recording |
| recording.path | string | `"/recordings"` | Recording path inside guacd container |
| recording.persistence.accessModes | list | `["ReadWriteOnce"]` | Access modes |
| recording.persistence.enabled | bool | `false` | Enable persistence for recordings |
| recording.persistence.existingClaim | string | `""` | Existing PVC name |
| recording.persistence.size | string | `"10Gi"` | Storage size |
| recording.persistence.storageClass | string | `""` | Storage class |
| recording.playback | object | `{"enabled":false,"searchPath":"/recordings"}` | Enable recording playback in web UI |

### API & Session

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| api.session.maxConnections | int | `0` | Maximum concurrent connections total (0 for unlimited) |
| api.session.maxConnectionsPerUser | int | `0` | Maximum concurrent connections per user (0 for unlimited) |
| api.session.timeout | int | `60` | Session timeout in minutes (0 for no timeout) |

### Brute Force Protection

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| bruteForce.attemptWindow | int | `5` | Time window for counting failed attempts (minutes) |
| bruteForce.enabled | bool | `true` | Enable brute force protection |
| bruteForce.lockoutDuration | int | `15` | Lockout duration in minutes |
| bruteForce.maxAttempts | int | `5` | Maximum failed login attempts before lockout |

### Ingress

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ingress.annotations | object | `{}` | Ingress annotations |
| ingress.className | string | `""` | Ingress class name |
| ingress.enabled | bool | `false` | Enable ingress |
| ingress.hosts | list | `[{"host":"guacamole.local","paths":[{"path":"/","pathType":"Prefix"}]}]` | Ingress hosts |
| ingress.tls | list | `[]` | Ingress TLS configuration |

### Network Policy

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| networkPolicy.enabled | bool | `false` | Enable network policies |
| networkPolicy.extraEgressRules | list | `[]` | Additional egress rules |
| networkPolicy.extraIngressRules | list | `[]` | Additional ingress rules |
| networkPolicy.ingressNamespaceSelector | object | `{}` | Allow ingress from specific namespaces |
| networkPolicy.ingressPodSelector | object | `{}` | Allow ingress from specific pods |

### Service Account & RBAC

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| rbac.create | bool | `true` | Create RBAC resources (Role and RoleBinding) |
| serviceAccount.annotations | object | `{}` | Service account annotations |
| serviceAccount.create | bool | `true` | Create service accounts |
| serviceAccount.name | string | `""` | Service account name (auto-generated if not set) |

### Extensions

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| extensions.enabled | bool | `false` | Enable custom extension loading |
| extensions.extraVolumeMounts | list | `[]` | Extra volume mounts for custom extensions |
| extensions.extraVolumes | list | `[]` | Extra volumes for custom extensions |
| extensions.list | list | `[]` | List of extensions to download and install |

### Logging

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| logging.guacamole.level | string | `"info"` |  |
| logging.guacd.level | string | `"info"` |  |

### Advanced

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| advanced.allowedFilePaths | string | `""` | Allowed file transfer paths (comma-separated) |
| advanced.guacamoleHome | string | `"/etc/guacamole"` | GUACAMOLE_HOME directory |
| advanced.tomcat | object | `{"connectionTimeout":20000,"maxThreads":200}` | Tomcat configuration |
| advanced.websocket | object | `{"enabled":true}` | Enable WebSocket tunnel |

## Examples

### Production Setup with OIDC

```yaml
guacamole:
  replicaCount: 3
  pdb:
    enabled: true
    minAvailable: 2

guacd:
  replicaCount: 3
  pdb:
    enabled: true

postgresql:
  enabled: true
  instances: 3
  ha:
    enabled: true
  tls:
    enabled: true
  backup:
    enabled: true
    schedule: "0 2 * * *"
    s3:
      destinationPath: s3://backups/guacamole
      secretName: s3-creds

auth:
  oidc:
    enabled: true
    authorizationEndpoint: "https://idp.example.com/auth"
    issuer: "https://idp.example.com"
    jwksEndpoint: "https://idp.example.com/certs"
    clientId: "guacamole"
    existingSecret: oidc-secret
  totp:
    enabled: true
    mode: required

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/proxy-buffering: "off"
  hosts:
    - host: guacamole.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: guacamole-tls
      hosts:
        - guacamole.example.com
```

### Session Recording

```yaml
recording:
  enabled: true
  playback:
    enabled: true
  persistence:
    enabled: true
    size: 100Gi
    storageClass: fast-storage
```

## Troubleshooting

### Database Initialization

Check the db-init job logs:

```bash
kubectl get jobs -n guacamole
kubectl logs job/guacamole-db-init -n guacamole --all-containers
```

### Operator CRDs

Verify operator status:

```bash
# CloudNative-PG
kubectl get clusters.postgresql.cnpg.io -n guacamole

# MariaDB
kubectl get mariadbs.k8s.mariadb.com -n guacamole

# MySQL
kubectl get innodbclusters.mysql.oracle.com -n guacamole
```

### WebSocket Issues

Ensure ingress has proper timeouts:

```yaml
ingress:
  annotations:
    nginx.ingress.kubernetes.io/proxy-buffering: "off"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
```

## Links

- [Apache Guacamole](https://guacamole.apache.org/)
- [Guacamole Documentation](https://guacamole.apache.org/doc/gug/)
- [CloudNative-PG](https://cloudnative-pg.io/)
- [MariaDB Operator](https://github.com/mariadb-operator/mariadb-operator)
- [MySQL Operator](https://dev.mysql.com/doc/mysql-operator/en/)
