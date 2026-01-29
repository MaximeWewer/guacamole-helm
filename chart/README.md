# Guacamole Helm Chart

A production-ready Helm chart for [Apache Guacamole](https://guacamole.apache.org/).

## TL;DR

```bash
helm install guacamole . -n guacamole --create-namespace
```

## Introduction

This chart deploys Apache Guacamole on a Kubernetes cluster using **official Docker images** (no Bitnami dependencies). It includes:

- Guacamole web application (`guacamole/guacamole`)
- Guacd connection proxy (`guacamole/guacd`)
- Database with embedded templates:
  - PostgreSQL (`postgres`)
  - MySQL (`mysql`)
  - MariaDB (`mariadb`)
  - SQL Server (`mcr.microsoft.com/mssql/server`)
- Automatic schema initialization

## Prerequisites

- Kubernetes 1.25+
- Helm 3.x
- PV provisioner support (for database and recordings persistence)

## Installing the Chart

```bash
helm install guacamole . -n guacamole --create-namespace
```

## Uninstalling the Chart

```bash
helm uninstall guacamole -n guacamole
```

## Configuration

### Global Parameters

| Parameter           | Description                         | Default |
| ------------------- | ----------------------------------- | ------- |
| `nameOverride`      | Override chart name                 | `""`    |
| `fullnameOverride`  | Override full name                  | `""`    |
| `commonLabels`      | Labels to add to all resources      | `{}`    |
| `commonAnnotations` | Annotations to add to all resources | `{}`    |

### Guacamole Client Parameters

| Parameter                                                     | Description                      | Default                |
| ------------------------------------------------------------- | -------------------------------- | ---------------------- |
| `guacamole.enabled`                                           | Enable Guacamole deployment      | `true`                 |
| `guacamole.image.repository`                                  | Guacamole image repository       | `guacamole/guacamole`  |
| `guacamole.image.tag`                                         | Guacamole image tag              | `""` (uses appVersion) |
| `guacamole.image.pullPolicy`                                  | Image pull policy                | `IfNotPresent`         |
| `guacamole.imagePullSecrets`                                  | Image pull secrets               | `[]`                   |
| `guacamole.replicaCount`                                      | Number of replicas               | `1`                    |
| `guacamole.webappContext`                                     | Webapp context path              | `ROOT`                 |
| `guacamole.extraEnvVars`                                      | Additional environment variables | `[]`                   |
| `guacamole.extraEnvFrom`                                      | Additional envFrom sources       | `[]`                   |
| `guacamole.resources.requests.memory`                         | Memory request                   | `256Mi`                |
| `guacamole.resources.requests.cpu`                            | CPU request                      | `250m`                 |
| `guacamole.resources.limits.memory`                           | Memory limit                     | `512Mi`                |
| `guacamole.resources.limits.cpu`                              | CPU limit                        | `500m`                 |
| `guacamole.podSecurityContext.runAsNonRoot`                   | Run as non-root                  | `true`                 |
| `guacamole.podSecurityContext.runAsUser`                      | Run as user ID                   | `1000`                 |
| `guacamole.podSecurityContext.runAsGroup`                     | Run as group ID                  | `1000`                 |
| `guacamole.podSecurityContext.fsGroup`                        | Filesystem group ID              | `1000`                 |
| `guacamole.containerSecurityContext.allowPrivilegeEscalation` | Allow privilege escalation       | `false`                |
| `guacamole.livenessProbe.initialDelaySeconds`                 | Liveness probe initial delay     | `60`                   |
| `guacamole.livenessProbe.periodSeconds`                       | Liveness probe period            | `10`                   |
| `guacamole.readinessProbe.initialDelaySeconds`                | Readiness probe initial delay    | `30`                   |
| `guacamole.readinessProbe.periodSeconds`                      | Readiness probe period           | `5`                    |
| `guacamole.nodeSelector`                                      | Node selector                    | `{}`                   |
| `guacamole.tolerations`                                       | Tolerations                      | `[]`                   |
| `guacamole.affinity`                                          | Affinity rules                   | `{}`                   |
| `guacamole.podAntiAffinityPreset`                             | Pod anti-affinity preset         | `soft`                 |
| `guacamole.extraVolumeMounts`                                 | Additional volume mounts         | `[]`                   |
| `guacamole.extraVolumes`                                      | Additional volumes               | `[]`                   |
| `guacamole.terminationGracePeriodSeconds`                     | Termination grace period         | `30`                   |
| `guacamole.service.type`                                      | Service type                     | `ClusterIP`            |
| `guacamole.service.port`                                      | Service port                     | `8080`                 |
| `guacamole.service.annotations`                               | Service annotations              | `{}`                   |
| `guacamole.pdb.enabled`                                       | Enable PodDisruptionBudget       | `false`                |
| `guacamole.pdb.minAvailable`                                  | Minimum available pods           | `1`                    |
| `guacamole.hpa.enabled`                                       | Enable HorizontalPodAutoscaler   | `false`                |
| `guacamole.hpa.minReplicas`                                   | Minimum replicas                 | `2`                    |
| `guacamole.hpa.maxReplicas`                                   | Maximum replicas                 | `10`                   |
| `guacamole.hpa.targetCPUUtilizationPercentage`                | Target CPU utilization           | `80`                   |
| `guacamole.hpa.targetMemoryUtilizationPercentage`             | Target memory utilization        | `80`                   |

### Guacd Parameters

| Parameter                                               | Description                       | Default                |
| ------------------------------------------------------- | --------------------------------- | ---------------------- |
| `guacd.enabled`                                         | Enable guacd deployment           | `true`                 |
| `guacd.image.repository`                                | Guacd image repository            | `guacamole/guacd`      |
| `guacd.image.tag`                                       | Guacd image tag                   | `""` (uses appVersion) |
| `guacd.image.pullPolicy`                                | Image pull policy                 | `IfNotPresent`         |
| `guacd.imagePullSecrets`                                | Image pull secrets                | `[]`                   |
| `guacd.replicaCount`                                    | Number of replicas                | `1`                    |
| `guacd.logLevel`                                        | Log level                         | `info`                 |
| `guacd.extraEnvVars`                                    | Additional environment variables  | `[]`                   |
| `guacd.extraEnvFrom`                                    | Additional envFrom sources        | `[]`                   |
| `guacd.resources.requests.memory`                       | Memory request                    | `256Mi`                |
| `guacd.resources.requests.cpu`                          | CPU request                       | `250m`                 |
| `guacd.resources.limits.memory`                         | Memory limit                      | `512Mi`                |
| `guacd.resources.limits.cpu`                            | CPU limit                         | `500m`                 |
| `guacd.podSecurityContext.runAsNonRoot`                 | Run as non-root                   | `true`                 |
| `guacd.podSecurityContext.runAsUser`                    | Run as user ID                    | `1000`                 |
| `guacd.containerSecurityContext.readOnlyRootFilesystem` | Read-only root filesystem         | `true`                 |
| `guacd.dnsPolicy`                                       | DNS policy (Default for node DNS) | `""`                   |
| `guacd.dnsConfig`                                       | Custom DNS configuration          | `{}`                   |
| `guacd.nodeSelector`                                    | Node selector                     | `{}`                   |
| `guacd.tolerations`                                     | Tolerations                       | `[]`                   |
| `guacd.affinity`                                        | Affinity rules                    | `{}`                   |
| `guacd.podAntiAffinityPreset`                           | Pod anti-affinity preset          | `soft`                 |
| `guacd.extraVolumeMounts`                               | Additional volume mounts          | `[]`                   |
| `guacd.extraVolumes`                                    | Additional volumes                | `[]`                   |
| `guacd.terminationGracePeriodSeconds`                   | Termination grace period          | `30`                   |
| `guacd.service.type`                                    | Service type                      | `ClusterIP`            |
| `guacd.service.port`                                    | Service port                      | `4822`                 |
| `guacd.service.annotations`                             | Service annotations               | `{}`                   |
| `guacd.pdb.enabled`                                     | Enable PodDisruptionBudget        | `false`                |
| `guacd.pdb.minAvailable`                                | Minimum available pods            | `1`                    |

### Service Account & RBAC Parameters

| Parameter                    | Description                 | Default |
| ---------------------------- | --------------------------- | ------- |
| `serviceAccount.create`      | Create service account      | `true`  |
| `serviceAccount.annotations` | Service account annotations | `{}`    |
| `serviceAccount.name`        | Service account name        | `""`    |
| `rbac.create`                | Create RBAC resources       | `true`  |

### Proxy Parameters

| Parameter               | Description            | Default                          |
| ----------------------- | ---------------------- | -------------------------------- |
| `proxy.enabled`         | Enable remote IP valve | `true`                           |
| `proxy.allowedIpsRegex` | Trusted proxy IP regex | `127\.0\.0\.1\|::1\|10\..*\|...` |
| `proxy.ipHeader`        | IP header name         | `X-Forwarded-For`                |
| `proxy.protocolHeader`  | Protocol header name   | `X-Forwarded-Proto`              |

### Database Parameters

| Parameter                                          | Description                                           | Default                               |
| -------------------------------------------------- | ----------------------------------------------------- | ------------------------------------- |
| `database.type`                                    | Database type (postgresql, mysql, mariadb, sqlserver) | `postgresql`                          |
| `database.external.enabled`                        | Use external database                                 | `false`                               |
| `database.external.hostname`                       | External database hostname                            | `""`                                  |
| `database.external.port`                           | External database port                                | `5432`                                |
| `database.external.database`                       | External database name                                | `guacamole`                           |
| `database.external.username`                       | External database username                            | `guacamole`                           |
| `database.external.password`                       | External database password                            | `""`                                  |
| `database.external.existingSecret`                 | Existing secret for credentials                       | `""`                                  |
| `database.external.existingSecretPasswordKey`      | Password key in secret                                | `password`                            |
| `database.init.enabled`                            | Enable schema initialization                          | `true`                                |
| `database.init.recreate`                           | Recreate schema on upgrade                            | `false`                               |
| `database.init.image.repository`                   | Init image repository                                 | `guacamole/guacamole`                 |
| `database.init.image.tag`                          | Init image tag                                        | `""`                                  |
| `database.init.image.pullPolicy`                   | Init image pull policy                                | `IfNotPresent`                        |
| `database.init.clientImages.postgresql.repository` | PostgreSQL client image                               | `postgresql`                          |
| `database.init.clientImages.postgresql.tag`        | PostgreSQL client tag                                 | `18`                                  |
| `database.init.clientImages.mysql.repository`      | MySQL client image                                    | `mysql`                               |
| `database.init.clientImages.mysql.tag`             | MySQL client tag                                      | `9`                                   |
| `database.init.clientImages.mariadb.repository`    | MariaDB client image                                  | `mariadb`                             |
| `database.init.clientImages.mariadb.tag`           | MariaDB client tag                                    | `12`                                  |
| `database.init.clientImages.sqlserver.repository`  | SQL Server client image                               | `mcr.microsoft.com/mssql/server`      |
| `database.init.clientImages.sqlserver.tag`         | SQL Server client tag                                 | `2025-latest`                         |
| `database.init.resources.requests.memory`          | Init memory request                                   | `128Mi`                               |
| `database.init.resources.requests.cpu`             | Init CPU request                                      | `100m`                                |
| `database.init.resources.limits.memory`            | Init memory limit                                     | `256Mi`                               |
| `database.init.resources.limits.cpu`               | Init CPU limit                                        | `200m`                                |
| `database.init.backoffLimit`                       | Init job backoff limit                                | `3`                                   |
| `database.init.ttlSecondsAfterFinished`            | TTL after completion                                  | `300`                                 |
| `database.init.useHooks`                           | Use Helm hooks                                        | `false`                               |
| `database.init.hookWeight`                         | Hook weight                                           | `-5`                                  |
| `database.init.hookDeletePolicy`                   | Hook delete policy                                    | `before-hook-creation,hook-succeeded` |

### PostgreSQL Parameters (Official Docker Image)

| Parameter                                                      | Description                          | Default           |
| -------------------------------------------------------------- | ------------------------------------ | ----------------- |
| `postgresql.enabled`                                           | Enable PostgreSQL                    | `true`            |
| `postgresql.image.repository`                                  | Image repository                     | `postgres`        |
| `postgresql.image.tag`                                         | Image tag                            | `18`              |
| `postgresql.image.pullPolicy`                                  | Image pull policy                    | `IfNotPresent`    |
| `postgresql.imagePullSecrets`                                  | Image pull secrets                   | `[]`              |
| `postgresql.auth.database`                                     | Database name                        | `guacamole`       |
| `postgresql.auth.username`                                     | Username                             | `guacamole`       |
| `postgresql.auth.password`                                     | Password (auto-generated)            | `""`              |
| `postgresql.auth.existingSecret`                               | Existing secret (key: password)      | `""`              |
| `postgresql.service.type`                                      | Service type                         | `ClusterIP`       |
| `postgresql.service.port`                                      | Service port                         | `5432`            |
| `postgresql.persistence.enabled`                               | Enable persistence                   | `true`            |
| `postgresql.persistence.size`                                  | Persistence size                     | `8Gi`             |
| `postgresql.persistence.storageClass`                          | Storage class                        | `""`              |
| `postgresql.persistence.accessModes`                           | Access modes                         | `[ReadWriteOnce]` |
| `postgresql.persistence.annotations`                           | PVC annotations                      | `{}`              |
| `postgresql.configuration`                                     | Custom postgresql.conf content       | `""`              |
| `postgresql.customConfigMap`                                   | Existing ConfigMap for configuration | `""`              |
| `postgresql.resources`                                         | Resources limits/requests            | `{}`              |
| `postgresql.podSecurityContext.fsGroup`                        | Filesystem group ID                  | `999`             |
| `postgresql.containerSecurityContext.runAsUser`                | Run as user ID                       | `999`             |
| `postgresql.containerSecurityContext.runAsGroup`               | Run as group ID                      | `999`             |
| `postgresql.containerSecurityContext.runAsNonRoot`             | Run as non-root                      | `true`            |
| `postgresql.containerSecurityContext.allowPrivilegeEscalation` | Allow privilege escalation           | `false`           |
| `postgresql.startupProbe.enabled`                              | Enable startup probe                 | `true`            |
| `postgresql.startupProbe.initialDelaySeconds`                  | Initial delay                        | `30`              |
| `postgresql.startupProbe.periodSeconds`                        | Period                               | `10`              |
| `postgresql.startupProbe.timeoutSeconds`                       | Timeout                              | `5`               |
| `postgresql.startupProbe.failureThreshold`                     | Failure threshold                    | `30`              |
| `postgresql.startupProbe.successThreshold`                     | Success threshold                    | `1`               |
| `postgresql.livenessProbe.enabled`                             | Enable liveness probe                | `true`            |
| `postgresql.livenessProbe.initialDelaySeconds`                 | Initial delay                        | `30`              |
| `postgresql.livenessProbe.periodSeconds`                       | Period                               | `10`              |
| `postgresql.livenessProbe.timeoutSeconds`                      | Timeout                              | `5`               |
| `postgresql.livenessProbe.failureThreshold`                    | Failure threshold                    | `6`               |
| `postgresql.livenessProbe.successThreshold`                    | Success threshold                    | `1`               |
| `postgresql.readinessProbe.enabled`                            | Enable readiness probe               | `true`            |
| `postgresql.readinessProbe.initialDelaySeconds`                | Initial delay                        | `5`               |
| `postgresql.readinessProbe.periodSeconds`                      | Period                               | `10`              |
| `postgresql.readinessProbe.timeoutSeconds`                     | Timeout                              | `5`               |
| `postgresql.readinessProbe.failureThreshold`                   | Failure threshold                    | `6`               |
| `postgresql.readinessProbe.successThreshold`                   | Success threshold                    | `1`               |
| `postgresql.terminationGracePeriodSeconds`                     | Termination grace period             | `120`             |
| `postgresql.updateStrategy.type`                               | StatefulSet update strategy          | `RollingUpdate`   |
| `postgresql.priorityClassName`                                 | Priority class name                  | `""`              |
| `postgresql.nodeSelector`                                      | Node selector                        | `{}`              |
| `postgresql.tolerations`                                       | Tolerations                          | `[]`              |
| `postgresql.affinity`                                          | Affinity rules                       | `{}`              |
| `postgresql.podAntiAffinityPreset`                             | Pod anti-affinity preset (soft/hard) | `""`              |
| `postgresql.podAnnotations`                                    | Pod annotations                      | `{}`              |
| `postgresql.podLabels`                                         | Pod labels                           | `{}`              |
| `postgresql.annotations`                                       | StatefulSet annotations              | `{}`              |
| `postgresql.extraEnvVars`                                      | Additional environment variables     | `[]`              |
| `postgresql.extraEnvFrom`                                      | Additional envFrom sources           | `[]`              |
| `postgresql.extraVolumeMounts`                                 | Additional volume mounts             | `[]`              |
| `postgresql.extraVolumes`                                      | Additional volumes                   | `[]`              |
| `postgresql.initContainers`                                    | Init containers                      | `[]`              |

### MySQL Parameters (Official Docker Image)

| Parameter                                                 | Description                                     | Default           |
| --------------------------------------------------------- | ----------------------------------------------- | ----------------- |
| `mysql.enabled`                                           | Enable MySQL                                    | `false`           |
| `mysql.image.repository`                                  | Image repository                                | `mysql`           |
| `mysql.image.tag`                                         | Image tag                                       | `9`               |
| `mysql.image.pullPolicy`                                  | Image pull policy                               | `IfNotPresent`    |
| `mysql.imagePullSecrets`                                  | Image pull secrets                              | `[]`              |
| `mysql.auth.database`                                     | Database name                                   | `guacamole`       |
| `mysql.auth.username`                                     | Username                                        | `guacamole`       |
| `mysql.auth.password`                                     | Password (auto-generated)                       | `""`              |
| `mysql.auth.rootPassword`                                 | Root password (auto-generated)                  | `""`              |
| `mysql.auth.existingSecret`                               | Existing secret (keys: password, root-password) | `""`              |
| `mysql.service.type`                                      | Service type                                    | `ClusterIP`       |
| `mysql.service.port`                                      | Service port                                    | `3306`            |
| `mysql.persistence.enabled`                               | Enable persistence                              | `true`            |
| `mysql.persistence.size`                                  | Persistence size                                | `8Gi`             |
| `mysql.persistence.storageClass`                          | Storage class                                   | `""`              |
| `mysql.persistence.accessModes`                           | Access modes                                    | `[ReadWriteOnce]` |
| `mysql.persistence.annotations`                           | PVC annotations                                 | `{}`              |
| `mysql.configuration`                                     | Custom my.cnf content                           | `""`              |
| `mysql.customConfigMap`                                   | Existing ConfigMap for configuration            | `""`              |
| `mysql.resources`                                         | Resources limits/requests                       | `{}`              |
| `mysql.podSecurityContext.fsGroup`                        | Filesystem group ID                             | `999`             |
| `mysql.containerSecurityContext.runAsUser`                | Run as user ID                                  | `999`             |
| `mysql.containerSecurityContext.runAsGroup`               | Run as group ID                                 | `999`             |
| `mysql.containerSecurityContext.runAsNonRoot`             | Run as non-root                                 | `true`            |
| `mysql.containerSecurityContext.allowPrivilegeEscalation` | Allow privilege escalation                      | `false`           |
| `mysql.startupProbe.enabled`                              | Enable startup probe                            | `true`            |
| `mysql.startupProbe.initialDelaySeconds`                  | Initial delay                                   | `30`              |
| `mysql.startupProbe.periodSeconds`                        | Period                                          | `10`              |
| `mysql.startupProbe.timeoutSeconds`                       | Timeout                                         | `5`               |
| `mysql.startupProbe.failureThreshold`                     | Failure threshold                               | `30`              |
| `mysql.startupProbe.successThreshold`                     | Success threshold                               | `1`               |
| `mysql.livenessProbe.enabled`                             | Enable liveness probe                           | `true`            |
| `mysql.livenessProbe.initialDelaySeconds`                 | Initial delay                                   | `30`              |
| `mysql.livenessProbe.periodSeconds`                       | Period                                          | `10`              |
| `mysql.livenessProbe.timeoutSeconds`                      | Timeout                                         | `5`               |
| `mysql.livenessProbe.failureThreshold`                    | Failure threshold                               | `6`               |
| `mysql.livenessProbe.successThreshold`                    | Success threshold                               | `1`               |
| `mysql.readinessProbe.enabled`                            | Enable readiness probe                          | `true`            |
| `mysql.readinessProbe.initialDelaySeconds`                | Initial delay                                   | `5`               |
| `mysql.readinessProbe.periodSeconds`                      | Period                                          | `10`              |
| `mysql.readinessProbe.timeoutSeconds`                     | Timeout                                         | `5`               |
| `mysql.readinessProbe.failureThreshold`                   | Failure threshold                               | `6`               |
| `mysql.readinessProbe.successThreshold`                   | Success threshold                               | `1`               |
| `mysql.terminationGracePeriodSeconds`                     | Termination grace period                        | `120`             |
| `mysql.updateStrategy.type`                               | StatefulSet update strategy                     | `RollingUpdate`   |
| `mysql.priorityClassName`                                 | Priority class name                             | `""`              |
| `mysql.nodeSelector`                                      | Node selector                                   | `{}`              |
| `mysql.tolerations`                                       | Tolerations                                     | `[]`              |
| `mysql.affinity`                                          | Affinity rules                                  | `{}`              |
| `mysql.podAntiAffinityPreset`                             | Pod anti-affinity preset (soft/hard)            | `""`              |
| `mysql.podAnnotations`                                    | Pod annotations                                 | `{}`              |
| `mysql.podLabels`                                         | Pod labels                                      | `{}`              |
| `mysql.annotations`                                       | StatefulSet annotations                         | `{}`              |
| `mysql.extraEnvVars`                                      | Additional environment variables                | `[]`              |
| `mysql.extraEnvFrom`                                      | Additional envFrom sources                      | `[]`              |
| `mysql.extraVolumeMounts`                                 | Additional volume mounts                        | `[]`              |
| `mysql.extraVolumes`                                      | Additional volumes                              | `[]`              |
| `mysql.initContainers`                                    | Init containers                                 | `[]`              |

### MariaDB Parameters (Official Docker Image)

| Parameter                                                   | Description                                     | Default           |
| ----------------------------------------------------------- | ----------------------------------------------- | ----------------- |
| `mariadb.enabled`                                           | Enable MariaDB                                  | `false`           |
| `mariadb.image.repository`                                  | Image repository                                | `mariadb`         |
| `mariadb.image.tag`                                         | Image tag                                       | `12`              |
| `mariadb.image.pullPolicy`                                  | Image pull policy                               | `IfNotPresent`    |
| `mariadb.imagePullSecrets`                                  | Image pull secrets                              | `[]`              |
| `mariadb.auth.database`                                     | Database name                                   | `guacamole`       |
| `mariadb.auth.username`                                     | Username                                        | `guacamole`       |
| `mariadb.auth.password`                                     | Password (auto-generated)                       | `""`              |
| `mariadb.auth.rootPassword`                                 | Root password (auto-generated)                  | `""`              |
| `mariadb.auth.existingSecret`                               | Existing secret (keys: password, root-password) | `""`              |
| `mariadb.service.type`                                      | Service type                                    | `ClusterIP`       |
| `mariadb.service.port`                                      | Service port                                    | `3306`            |
| `mariadb.persistence.enabled`                               | Enable persistence                              | `true`            |
| `mariadb.persistence.size`                                  | Persistence size                                | `8Gi`             |
| `mariadb.persistence.storageClass`                          | Storage class                                   | `""`              |
| `mariadb.persistence.accessModes`                           | Access modes                                    | `[ReadWriteOnce]` |
| `mariadb.persistence.annotations`                           | PVC annotations                                 | `{}`              |
| `mariadb.configuration`                                     | Custom my.cnf content                           | `""`              |
| `mariadb.customConfigMap`                                   | Existing ConfigMap for configuration            | `""`              |
| `mariadb.resources`                                         | Resources limits/requests                       | `{}`              |
| `mariadb.podSecurityContext.fsGroup`                        | Filesystem group ID                             | `999`             |
| `mariadb.containerSecurityContext.runAsUser`                | Run as user ID                                  | `999`             |
| `mariadb.containerSecurityContext.runAsGroup`               | Run as group ID                                 | `999`             |
| `mariadb.containerSecurityContext.runAsNonRoot`             | Run as non-root                                 | `true`            |
| `mariadb.containerSecurityContext.allowPrivilegeEscalation` | Allow privilege escalation                      | `false`           |
| `mariadb.startupProbe.enabled`                              | Enable startup probe                            | `true`            |
| `mariadb.startupProbe.initialDelaySeconds`                  | Initial delay                                   | `30`              |
| `mariadb.startupProbe.periodSeconds`                        | Period                                          | `10`              |
| `mariadb.startupProbe.timeoutSeconds`                       | Timeout                                         | `5`               |
| `mariadb.startupProbe.failureThreshold`                     | Failure threshold                               | `30`              |
| `mariadb.startupProbe.successThreshold`                     | Success threshold                               | `1`               |
| `mariadb.livenessProbe.enabled`                             | Enable liveness probe                           | `true`            |
| `mariadb.livenessProbe.initialDelaySeconds`                 | Initial delay                                   | `30`              |
| `mariadb.livenessProbe.periodSeconds`                       | Period                                          | `10`              |
| `mariadb.livenessProbe.timeoutSeconds`                      | Timeout                                         | `5`               |
| `mariadb.livenessProbe.failureThreshold`                    | Failure threshold                               | `6`               |
| `mariadb.livenessProbe.successThreshold`                    | Success threshold                               | `1`               |
| `mariadb.readinessProbe.enabled`                            | Enable readiness probe                          | `true`            |
| `mariadb.readinessProbe.initialDelaySeconds`                | Initial delay                                   | `5`               |
| `mariadb.readinessProbe.periodSeconds`                      | Period                                          | `10`              |
| `mariadb.readinessProbe.timeoutSeconds`                     | Timeout                                         | `5`               |
| `mariadb.readinessProbe.failureThreshold`                   | Failure threshold                               | `6`               |
| `mariadb.readinessProbe.successThreshold`                   | Success threshold                               | `1`               |
| `mariadb.terminationGracePeriodSeconds`                     | Termination grace period                        | `120`             |
| `mariadb.updateStrategy.type`                               | StatefulSet update strategy                     | `RollingUpdate`   |
| `mariadb.priorityClassName`                                 | Priority class name                             | `""`              |
| `mariadb.nodeSelector`                                      | Node selector                                   | `{}`              |
| `mariadb.tolerations`                                       | Tolerations                                     | `[]`              |
| `mariadb.affinity`                                          | Affinity rules                                  | `{}`              |
| `mariadb.podAntiAffinityPreset`                             | Pod anti-affinity preset (soft/hard)            | `""`              |
| `mariadb.podAnnotations`                                    | Pod annotations                                 | `{}`              |
| `mariadb.podLabels`                                         | Pod labels                                      | `{}`              |
| `mariadb.annotations`                                       | StatefulSet annotations                         | `{}`              |
| `mariadb.extraEnvVars`                                      | Additional environment variables                | `[]`              |
| `mariadb.extraEnvFrom`                                      | Additional envFrom sources                      | `[]`              |
| `mariadb.extraVolumeMounts`                                 | Additional volume mounts                        | `[]`              |
| `mariadb.extraVolumes`                                      | Additional volumes                              | `[]`              |
| `mariadb.initContainers`                                    | Init containers                                 | `[]`              |

### SQL Server Parameters (Official Microsoft Image)

| Parameter                             | Description        | Default                          |
| ------------------------------------- | ------------------ | -------------------------------- |
| `sqlserver.enabled`                   | Enable SQL Server  | `false`                          |
| `sqlserver.image.repository`          | Image repository   | `mcr.microsoft.com/mssql/server` |
| `sqlserver.image.tag`                 | Image tag          | `2025-latest`                    |
| `sqlserver.image.pullPolicy`          | Image pull policy  | `IfNotPresent`                   |
| `sqlserver.edition`                   | SQL Server edition | `Developer`                      |
| `sqlserver.acceptEula`                | Accept EULA        | `Y`                              |
| `sqlserver.agentEnabled`              | Enable SQL Agent   | `true`                           |
| `sqlserver.auth.saPassword`           | SA password        | `""`                             |
| `sqlserver.auth.database`             | Database name      | `guacamole`                      |
| `sqlserver.auth.username`             | Username           | `guacamole`                      |
| `sqlserver.auth.password`             | Password           | `""`                             |
| `sqlserver.auth.existingSecret`       | Existing secret    | `""`                             |
| `sqlserver.service.type`              | Service type       | `ClusterIP`                      |
| `sqlserver.service.port`              | Service port       | `1433`                           |
| `sqlserver.persistence.enabled`       | Enable persistence | `true`                           |
| `sqlserver.persistence.size`          | Persistence size   | `8Gi`                            |
| `sqlserver.persistence.storageClass`  | Storage class      | `""`                             |
| `sqlserver.resources.requests.memory` | Memory request     | `2Gi`                            |
| `sqlserver.resources.requests.cpu`    | CPU request        | `500m`                           |
| `sqlserver.resources.limits.memory`   | Memory limit       | `4Gi`                            |
| `sqlserver.resources.limits.cpu`      | CPU limit          | `2000m`                          |

### LDAP Authentication Parameters

| Parameter                      | Description                      | Default |
| ------------------------------ | -------------------------------- | ------- |
| `auth.ldap.enabled`            | Enable LDAP authentication       | `false` |
| `auth.ldap.hostname`           | LDAP server hostname             | `""`    |
| `auth.ldap.port`               | LDAP server port                 | `389`   |
| `auth.ldap.encryption`         | Encryption (none, ssl, starttls) | `none`  |
| `auth.ldap.userBaseDn`         | User base DN                     | `""`    |
| `auth.ldap.usernameAttribute`  | Username attribute               | `uid`   |
| `auth.ldap.searchBindDn`       | Search bind DN                   | `""`    |
| `auth.ldap.searchBindPassword` | Search bind password             | `""`    |
| `auth.ldap.existingSecret`     | Existing secret                  | `""`    |
| `auth.ldap.extraConfig`        | Additional LDAP config           | `{}`    |

### OIDC Authentication Parameters

| Parameter                         | Description                | Default                |
| --------------------------------- | -------------------------- | ---------------------- |
| `auth.oidc.enabled`               | Enable OIDC authentication | `false`                |
| `auth.oidc.authorizationEndpoint` | Authorization endpoint URL | `""`                   |
| `auth.oidc.issuer`                | Issuer URL                 | `""`                   |
| `auth.oidc.jwksEndpoint`          | JWKS endpoint URL          | `""`                   |
| `auth.oidc.clientId`              | Client ID                  | `""`                   |
| `auth.oidc.clientSecret`          | Client secret              | `""`                   |
| `auth.oidc.existingSecret`        | Existing secret            | `""`                   |
| `auth.oidc.redirectUri`           | Redirect URI               | `""`                   |
| `auth.oidc.scope`                 | Scopes                     | `openid profile email` |
| `auth.oidc.usernameClaim`         | Username claim             | `preferred_username`   |
| `auth.oidc.extraConfig`           | Additional OIDC config     | `{}`                   |

### SAML Authentication Parameters

| Parameter                  | Description                | Default |
| -------------------------- | -------------------------- | ------- |
| `auth.saml.enabled`        | Enable SAML authentication | `false` |
| `auth.saml.idpMetadataUrl` | IdP metadata URL           | `""`    |
| `auth.saml.entityId`       | Entity ID                  | `""`    |
| `auth.saml.callbackUrl`    | Callback URL               | `""`    |
| `auth.saml.existingSecret` | Existing secret            | `""`    |
| `auth.saml.extraConfig`    | Additional SAML config     | `{}`    |

### TOTP Authentication Parameters

| Parameter             | Description               | Default            |
| --------------------- | ------------------------- | ------------------ |
| `auth.totp.enabled`   | Enable TOTP               | `false`            |
| `auth.totp.issuer`    | Issuer name               | `Apache Guacamole` |
| `auth.totp.keyLength` | Key length (16, 24, 32)   | `32`               |
| `auth.totp.mode`      | Mode (required, optional) | `optional`         |

### Duo Authentication Parameters

| Parameter                 | Description            | Default |
| ------------------------- | ---------------------- | ------- |
| `auth.duo.enabled`        | Enable Duo 2FA         | `false` |
| `auth.duo.apiHostname`    | Duo API hostname       | `""`    |
| `auth.duo.clientId`       | Duo client ID          | `""`    |
| `auth.duo.clientSecret`   | Duo client secret      | `""`    |
| `auth.duo.existingSecret` | Existing secret        | `""`    |
| `auth.duo.redirectUri`    | Redirect URI           | `""`    |
| `auth.duo.authTimeout`    | Auth timeout (minutes) | `5`     |
| `auth.duo.bypassHosts`    | IPs to bypass Duo      | `""`    |
| `auth.duo.enforceHosts`   | IPs that must use Duo  | `""`    |

### RADIUS Authentication Parameters

| Parameter                          | Description             | Default     |
| ---------------------------------- | ----------------------- | ----------- |
| `auth.radius.enabled`              | Enable RADIUS           | `false`     |
| `auth.radius.hostname`             | RADIUS server hostname  | `localhost` |
| `auth.radius.authPort`             | RADIUS auth port        | `1812`      |
| `auth.radius.sharedSecret`         | Shared secret           | `""`        |
| `auth.radius.existingSecret`       | Existing secret         | `""`        |
| `auth.radius.authProtocol`         | Auth protocol           | `pap`       |
| `auth.radius.retries`              | Connection retries      | `5`         |
| `auth.radius.timeout`              | Timeout (seconds)       | `60`        |
| `auth.radius.trustAll`             | Trust all certificates  | `false`     |
| `auth.radius.nasIp`                | NAS IP                  | `""`        |
| `auth.radius.eapTtlsInnerProtocol` | EAP-TTLS inner protocol | `""`        |
| `auth.radius.keyFile`              | Client key file         | `""`        |
| `auth.radius.keyType`              | Key file type           | `""`        |
| `auth.radius.keyPassword`          | Key file password       | `""`        |
| `auth.radius.caFile`               | CA file                 | `""`        |
| `auth.radius.caType`               | CA file type            | `""`        |
| `auth.radius.caPassword`           | CA file password        | `""`        |

### CAS Authentication Parameters

| Parameter                        | Description                | Default |
| -------------------------------- | -------------------------- | ------- |
| `auth.cas.enabled`               | Enable CAS                 | `false` |
| `auth.cas.authorizationEndpoint` | CAS authorization endpoint | `""`    |
| `auth.cas.redirectUri`           | Redirect URI               | `""`    |
| `auth.cas.clearpassKey`          | ClearPass key path         | `""`    |
| `auth.cas.groupAttribute`        | Group attribute            | `""`    |
| `auth.cas.groupFormat`           | Group format (plain, ldap) | `plain` |
| `auth.cas.groupLdapBaseDn`       | LDAP base DN               | `""`    |
| `auth.cas.groupLdapAttribute`    | LDAP attribute             | `""`    |

### JSON Authentication Parameters

| Parameter                  | Description                       | Default |
| -------------------------- | --------------------------------- | ------- |
| `auth.json.enabled`        | Enable JSON auth                  | `false` |
| `auth.json.secretKey`      | 128-bit secret key (32 hex chars) | `""`    |
| `auth.json.existingSecret` | Existing secret                   | `""`    |

### HTTP Header Authentication Parameters

| Parameter                    | Description        | Default       |
| ---------------------------- | ------------------ | ------------- |
| `auth.header.enabled`        | Enable header auth | `false`       |
| `auth.header.httpAuthHeader` | HTTP header name   | `REMOTE_USER` |

### SSL/Certificate Authentication Parameters

| Parameter                           | Description               | Default                |
| ----------------------------------- | ------------------------- | ---------------------- |
| `auth.ssl.enabled`                  | Enable SSL auth           | `false`                |
| `auth.ssl.authUri`                  | URI requiring client cert | `""`                   |
| `auth.ssl.primaryUri`               | URI without client cert   | `""`                   |
| `auth.ssl.clientCertificateHeader`  | Client cert header        | `X-Client-Certificate` |
| `auth.ssl.clientVerifiedHeader`     | Client verified header    | `X-Client-Verified`    |
| `auth.ssl.maxTokenValidity`         | Token validity (minutes)  | `5`                    |
| `auth.ssl.subjectUsernameAttribute` | Username attribute        | `""`                   |
| `auth.ssl.subjectBaseDn`            | Subject base DN           | `""`                   |
| `auth.ssl.maxDomainValidity`        | Domain validity (minutes) | `5`                    |

### Vault / KSM Parameters

| Parameter                       | Description               | Default |
| ------------------------------- | ------------------------- | ------- |
| `vault.ksm.enabled`             | Enable KSM integration    | `false` |
| `vault.ksm.config`              | Base64-encoded KSM config | `""`    |
| `vault.ksm.existingSecret`      | Existing secret           | `""`    |
| `vault.ksm.allowUserConfig`     | Allow user KSM config     | `false` |
| `vault.ksm.allowUnverifiedCert` | Allow unverified certs    | `false` |
| `vault.ksm.apiCallInterval`     | API call interval (ms)    | `""`    |
| `vault.ksm.stripWindowsDomains` | Strip Windows domains     | `false` |

### QuickConnect Parameters

| Parameter                        | Description         | Default |
| -------------------------------- | ------------------- | ------- |
| `quickConnect.enabled`           | Enable QuickConnect | `false` |
| `quickConnect.allowedParameters` | Allowed parameters  | `""`    |
| `quickConnect.deniedParameters`  | Denied parameters   | `""`    |

### Recording Parameters

| Parameter                             | Description              | Default           |
| ------------------------------------- | ------------------------ | ----------------- |
| `recording.enabled`                   | Enable session recording | `false`           |
| `recording.path`                      | Recording path           | `/recordings`     |
| `recording.createRecordingIndex`      | Create search index      | `true`            |
| `recording.playback.enabled`          | Enable playback          | `false`           |
| `recording.playback.searchPath`       | Playback search path     | `/recordings`     |
| `recording.persistence.enabled`       | Enable persistence       | `false`           |
| `recording.persistence.size`          | Storage size             | `10Gi`            |
| `recording.persistence.storageClass`  | Storage class            | `""`              |
| `recording.persistence.accessModes`   | Access modes             | `[ReadWriteOnce]` |
| `recording.persistence.existingClaim` | Existing PVC             | `""`              |

### Ingress Parameters

| Parameter             | Description         | Default         |
| --------------------- | ------------------- | --------------- |
| `ingress.enabled`     | Enable Ingress      | `false`         |
| `ingress.className`   | Ingress class name  | `""`            |
| `ingress.annotations` | Ingress annotations | `{}`            |
| `ingress.hosts`       | Ingress hosts       | See values.yaml |
| `ingress.tls`         | Ingress TLS config  | `[]`            |

### Network Policy Parameters

| Parameter                                | Description                | Default |
| ---------------------------------------- | -------------------------- | ------- |
| `networkPolicy.enabled`                  | Enable network policies    | `false` |
| `networkPolicy.ingressNamespaceSelector` | Ingress namespace selector | `{}`    |
| `networkPolicy.ingressPodSelector`       | Ingress pod selector       | `{}`    |
| `networkPolicy.extraIngressRules`        | Additional ingress rules   | `[]`    |
| `networkPolicy.extraEgressRules`         | Additional egress rules    | `[]`    |

### Logging Parameters

| Parameter                 | Description         | Default |
| ------------------------- | ------------------- | ------- |
| `logging.guacamole.level` | Guacamole log level | `info`  |
| `logging.guacd.level`     | Guacd log level     | `info`  |

### API & Session Parameters

| Parameter                           | Description               | Default |
| ----------------------------------- | ------------------------- | ------- |
| `api.session.timeout`               | Session timeout (minutes) | `60`    |
| `api.session.maxConnectionsPerUser` | Max connections per user  | `0`     |
| `api.session.maxConnections`        | Max total connections     | `0`     |

### Brute Force Protection Parameters

| Parameter                    | Description                   | Default |
| ---------------------------- | ----------------------------- | ------- |
| `bruteForce.enabled`         | Enable brute force protection | `true`  |
| `bruteForce.maxAttempts`     | Max failed attempts           | `5`     |
| `bruteForce.lockoutDuration` | Lockout duration (minutes)    | `15`    |
| `bruteForce.attemptWindow`   | Attempt window (minutes)      | `5`     |

### Extensions Parameters

| Parameter                      | Description              | Default |
| ------------------------------ | ------------------------ | ------- |
| `extensions.enabled`           | Enable custom extensions | `false` |
| `extensions.list`              | List of extensions       | `[]`    |
| `extensions.extraVolumeMounts` | Extra volume mounts      | `[]`    |
| `extensions.extraVolumes`      | Extra volumes            | `[]`    |

### Advanced Parameters

| Parameter                           | Description                 | Default          |
| ----------------------------------- | --------------------------- | ---------------- |
| `advanced.guacamoleHome`            | GUACAMOLE_HOME directory    | `/etc/guacamole` |
| `advanced.skipSchemaCreation`       | Skip schema creation        | `false`          |
| `advanced.allowedFilePaths`         | Allowed file transfer paths | `""`             |
| `advanced.websocket.enabled`        | Enable WebSocket            | `true`           |
| `advanced.tomcat.maxThreads`        | Tomcat max threads          | `200`            |
| `advanced.tomcat.connectionTimeout` | Connection timeout (ms)     | `20000`          |

## Examples

### Basic PostgreSQL

```yaml
postgresql:
  enabled: true
  auth:
    password: "secure-password"
```

### MySQL with OIDC

```yaml
database:
  type: mysql

postgresql:
  enabled: false

mysql:
  enabled: true
  auth:
    password: "mysql-password"
    rootPassword: "root-password"

auth:
  oidc:
    enabled: true
    authorizationEndpoint: "https://idp.example.com/auth"
    issuer: "https://idp.example.com"
    jwksEndpoint: "https://idp.example.com/certs"
    clientId: "guacamole"
    existingSecret: "guacamole-oidc"
```

### High Availability

```yaml
guacamole:
  replicaCount: 3
  pdb:
    enabled: true
    minAvailable: 2
  hpa:
    enabled: true
    minReplicas: 2
    maxReplicas: 10

guacd:
  replicaCount: 3
  pdb:
    enabled: true
    minAvailable: 2
```

### With Recording

```yaml
recording:
  enabled: true
  playback:
    enabled: true
  persistence:
    enabled: true
    size: 100Gi
```

### PostgreSQL with Custom Configuration

```yaml
postgresql:
  enabled: true
  auth:
    password: "secure-password"
  configuration: |
    max_connections = 200
    shared_buffers = 256MB
    work_mem = 8MB
  resources:
    requests:
      memory: 512Mi
      cpu: 250m
    limits:
      memory: 1Gi
      cpu: 1000m
  podAntiAffinityPreset: hard
```

### MySQL with Security Context

```yaml
database:
  type: mysql

postgresql:
  enabled: false

mysql:
  enabled: true
  auth:
    password: "mysql-password"
    rootPassword: "root-password"
  podSecurityContext:
    fsGroup: 999
  containerSecurityContext:
    runAsUser: 999
    runAsGroup: 999
    runAsNonRoot: true
    allowPrivilegeEscalation: false
  startupProbe:
    enabled: true
    failureThreshold: 60
  resources:
    requests:
      memory: 256Mi
      cpu: 100m
    limits:
      memory: 1Gi
      cpu: 500m
```
