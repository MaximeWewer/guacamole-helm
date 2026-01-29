# Guacamole Helm Chart

A production-ready Helm chart for deploying [Apache Guacamole](https://guacamole.apache.org/) - a clientless remote desktop gateway supporting VNC, RDP, SSH, Telnet, and Kubernetes.

## Features

- **Multi-Database Support**: PostgreSQL 18+, MySQL 9+, MariaDB 12+, SQL Server 2025 (official Docker images)
- **Automatic Schema Initialization**: Init containers handle database schema creation
- **No External Dependencies**: All database templates are embedded (no Bitnami subcharts)
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

## Installation

### Quick Start

```bash
helm install guacamole ./charts -n guacamole --create-namespace
```

### From Repository

```bash
helm repo add guacamole https://github.com/maximewewer/guacamole-helm
helm repo update
helm install guacamole guacamole/guacamole -n guacamole --create-namespace
```

## Database Configuration

This chart provides **embedded database templates** using official Docker images - no external dependencies required. The default configuration is production-ready out of the box.

### Embedded Databases (Recommended for simplicity)

| Database   | Image      | Version | Default |
| ---------- | ---------- | ------- | ------- |
| PostgreSQL | `postgres` | 18      | Yes     |
| MySQL      | `mysql`    | 9       | No      |
| MariaDB    | `mariadb`  | 12      | No      |
| SQL Server | `mssql`    | 2025    | No      |

**Basic usage** - works out of the box:

```yaml
postgresql:
  enabled: true
  auth:
    password: "your-secure-password"
```

**Advanced configuration** - for production tuning:

```yaml
postgresql:
  enabled: true
  auth:
    password: "your-secure-password"
  # Custom PostgreSQL configuration
  configuration: |
    max_connections = 200
    shared_buffers = 256MB
  # Security contexts
  podSecurityContext:
    fsGroup: 999
  containerSecurityContext:
    runAsNonRoot: true
    allowPrivilegeEscalation: false
  # Probes tuning
  startupProbe:
    enabled: true
    failureThreshold: 60
  # Resources
  resources:
    requests:
      memory: 512Mi
      cpu: 250m
    limits:
      memory: 1Gi
  # Anti-affinity for HA
  podAntiAffinityPreset: hard
```

Available advanced options for all databases:

- `configuration` / `customConfigMap` - Custom database configuration
- `podSecurityContext` / `containerSecurityContext` - Security settings
- `startupProbe` / `livenessProbe` / `readinessProbe` - Health checks
- `resources` - CPU/Memory limits
- `affinity` / `podAntiAffinityPreset` - Scheduling constraints
- `extraEnvVars` / `extraVolumes` / `initContainers` - Extensibility

See [charts/README.md](charts/README.md) for the complete parameter reference.

### External Database (BYO Database)

For managed databases (RDS, Cloud SQL, Azure Database) or existing infrastructure:

```yaml
# Disable embedded database
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

This approach is recommended when you need:

- Managed database services with automated backups
- High availability / Multi-AZ deployments
- Advanced features (read replicas, auto-scaling)
- Compliance with organizational database policies
- TLS/SSL encrypted connections

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

database:
  type: postgresql
  init:
    enabled: true

postgresql:
  enabled: true
  auth:
    existingSecret: guacamole-postgresql-secret
  persistence:
    enabled: true
    size: 20Gi
  resources:
    requests:
      memory: 256Mi
      cpu: 100m
    limits:
      memory: 1Gi
      cpu: 500m

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
helm upgrade guacamole ./charts -n guacamole -f your-values.yaml
```

## Uninstalling

```bash
helm uninstall guacamole -n guacamole

# Remove PVCs if desired
kubectl delete pvc -l app.kubernetes.io/instance=guacamole -n guacamole
```

## Parameters Reference

See [charts/README.md](charts/README.md) for the complete list of configurable parameters, or [charts/values.yaml](charts/values.yaml) for defaults.

### Key Parameters

| Parameter                | Description                   | Default      |
| ------------------------ | ----------------------------- | ------------ |
| `guacamole.enabled`      | Enable Guacamole deployment   | `true`       |
| `guacamole.replicaCount` | Number of replicas            | `1`          |
| `guacd.enabled`          | Enable guacd deployment       | `true`       |
| `guacd.replicaCount`     | Number of replicas            | `1`          |
| `database.type`          | Database type                 | `postgresql` |
| `database.init.enabled`  | Enable schema initialization  | `true`       |
| `postgresql.enabled`     | Deploy PostgreSQL             | `true`       |
| `mysql.enabled`          | Deploy MySQL                  | `false`      |
| `mariadb.enabled`        | Deploy MariaDB                | `false`      |
| `sqlserver.enabled`      | Deploy SQL Server             | `false`      |
| `auth.oidc.enabled`      | Enable OIDC auth              | `false`      |
| `auth.ldap.enabled`      | Enable LDAP auth              | `false`      |
| `auth.saml.enabled`      | Enable SAML auth              | `false`      |
| `auth.totp.enabled`      | Enable TOTP 2FA               | `false`      |
| `auth.duo.enabled`       | Enable Duo 2FA                | `false`      |
| `auth.radius.enabled`    | Enable RADIUS auth            | `false`      |
| `auth.cas.enabled`       | Enable CAS auth               | `false`      |
| `auth.header.enabled`    | Enable HTTP header auth       | `false`      |
| `auth.ssl.enabled`       | Enable SSL cert auth          | `false`      |
| `vault.ksm.enabled`      | Enable Keeper Secrets Manager | `false`      |
| `quickConnect.enabled`   | Enable QuickConnect           | `false`      |
| `recording.enabled`      | Enable session recording      | `false`      |
| `ingress.enabled`        | Enable Ingress                | `false`      |
| `networkPolicy.enabled`  | Enable network policies       | `false`      |

## Troubleshooting

### Database Connection Issues

Check the init container logs:

```bash
kubectl logs <guacamole-pod> -c db-init
kubectl logs <guacamole-pod> -c db-apply
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
- [Guacamole Docker](https://guacamole.apache.org/doc/gug/guacamole-docker.html)
