{{/*
Expand the name of the chart.
*/}}
{{- define "guacamole.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "guacamole.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "guacamole.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "guacamole.labels" -}}
helm.sh/chart: {{ include "guacamole.chart" . }}
{{ include "guacamole.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "guacamole.selectorLabels" -}}
app.kubernetes.io/name: {{ include "guacamole.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "guacamole.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "guacamole.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Guacd fullname
*/}}
{{- define "guacamole.guacd.fullname" -}}
{{- printf "%s-guacd" (include "guacamole.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Guacd labels
*/}}
{{- define "guacamole.guacd.labels" -}}
{{ include "guacamole.labels" . }}
app.kubernetes.io/component: guacd
{{- end }}

{{/*
Guacd selector labels
*/}}
{{- define "guacamole.guacd.selectorLabels" -}}
{{ include "guacamole.selectorLabels" . }}
app.kubernetes.io/component: guacd
{{- end }}

{{/*
Guacamole client labels
*/}}
{{- define "guacamole.client.labels" -}}
{{ include "guacamole.labels" . }}
app.kubernetes.io/component: guacamole
{{- end }}

{{/*
Guacamole client selector labels
*/}}
{{- define "guacamole.client.selectorLabels" -}}
{{ include "guacamole.selectorLabels" . }}
app.kubernetes.io/component: guacamole
{{- end }}

{{/*
Database hostname
Note: Service naming conventions for operators:
- CloudNative-PG creates a service named *-rw for the primary
- MySQL Operator creates a service named * (cluster name)
- MariaDB Operator creates a service named * (MariaDB name)
*/}}
{{- define "guacamole.database.hostname" -}}
{{- if .Values.database.external.enabled }}
{{- required "database.external.hostname is required when database.external.enabled is true" .Values.database.external.hostname }}
{{- else if .Values.postgresql.enabled }}
{{- printf "%s-postgresql-rw" (include "guacamole.fullname" .) }}
{{- else if .Values.mysql.enabled }}
{{- printf "%s-mysql" (include "guacamole.fullname" .) }}
{{- else if .Values.mariadb.enabled }}
{{- printf "%s-mariadb" (include "guacamole.fullname" .) }}
{{- else }}
{{- fail "One of postgresql.enabled, mysql.enabled, mariadb.enabled, or database.external.enabled must be true" }}
{{- end }}
{{- end }}

{{/*
Database port
*/}}
{{- define "guacamole.database.port" -}}
{{- if .Values.database.external.enabled }}
{{- if .Values.database.external.port }}
{{- .Values.database.external.port }}
{{- else if eq .Values.database.type "postgresql" }}
{{- 5432 }}
{{- else if eq .Values.database.type "mysql" }}
{{- 3306 }}
{{- else if eq .Values.database.type "mariadb" }}
{{- 3306 }}
{{- else if eq .Values.database.type "sqlserver" }}
{{- 1433 }}
{{- else }}
{{- 5432 }}
{{- end }}
{{- else if .Values.postgresql.enabled }}
{{- 5432 }}
{{- else if .Values.mysql.enabled }}
{{- 3306 }}
{{- else if .Values.mariadb.enabled }}
{{- 3306 }}
{{- end }}
{{- end }}

{{/*
Database name
*/}}
{{- define "guacamole.database.name" -}}
{{- if .Values.database.external.enabled }}
{{- .Values.database.external.database | default "guacamole" }}
{{- else if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.database | default "guacamole" }}
{{- else if .Values.mysql.enabled }}
{{- .Values.mysql.auth.database | default "guacamole" }}
{{- else if .Values.mariadb.enabled }}
{{- .Values.mariadb.auth.database | default "guacamole" }}
{{- end }}
{{- end }}

{{/*
Database username
*/}}
{{- define "guacamole.database.username" -}}
{{- if .Values.database.external.enabled }}
{{- .Values.database.external.username | default "guacamole" }}
{{- else if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.username | default "guacamole" }}
{{- else if .Values.mysql.enabled }}
{{- .Values.mysql.auth.username | default "guacamole" }}
{{- else if .Values.mariadb.enabled }}
{{- .Values.mariadb.auth.username | default "guacamole" }}
{{- end }}
{{- end }}

{{/*
Database secret name
Note: Secret naming conventions for operators:
- CloudNative-PG: *-postgresql-credentials (with keys: username, password)
- MySQL Operator: *-mysql-credentials (with keys: rootUser, rootHost, rootPassword)
- MariaDB Operator: *-mariadb-credentials (with keys: root-password, password)
*/}}
{{- define "guacamole.database.secretName" -}}
{{- if .Values.database.external.enabled }}
{{- if .Values.database.external.existingSecret }}
{{- .Values.database.external.existingSecret }}
{{- else }}
{{- printf "%s-db-credentials" (include "guacamole.fullname" .) }}
{{- end }}
{{- else if .Values.postgresql.enabled }}
{{- if .Values.postgresql.auth.existingSecret }}
{{- .Values.postgresql.auth.existingSecret }}
{{- else }}
{{- printf "%s-postgresql-credentials" (include "guacamole.fullname" .) }}
{{- end }}
{{- else if .Values.mysql.enabled }}
{{- if .Values.mysql.auth.existingSecret }}
{{- .Values.mysql.auth.existingSecret }}
{{- else }}
{{- printf "%s-mysql-credentials" (include "guacamole.fullname" .) }}
{{- end }}
{{- else if .Values.mariadb.enabled }}
{{- if .Values.mariadb.auth.existingSecret }}
{{- .Values.mariadb.auth.existingSecret }}
{{- else }}
{{- printf "%s-mariadb-credentials" (include "guacamole.fullname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Database secret key for password
*/}}
{{- define "guacamole.database.secretKey" -}}
{{- if .Values.database.external.enabled }}
{{- .Values.database.external.existingSecretPasswordKey | default "password" }}
{{- else }}
{{- "password" }}
{{- end }}
{{- end }}

{{/*
Guacamole image
*/}}
{{- define "guacamole.image" -}}
{{- printf "%s:%s" .Values.guacamole.image.repository (.Values.guacamole.image.tag | default .Chart.AppVersion) }}
{{- end }}

{{/*
Guacd image
*/}}
{{- define "guacamole.guacd.image" -}}
{{- printf "%s:%s" .Values.guacd.image.repository (.Values.guacd.image.tag | default .Chart.AppVersion) }}
{{- end }}

{{/*
OIDC environment variables
*/}}
{{- define "guacamole.oidc.env" -}}
- name: OPENID_AUTHORIZATION_ENDPOINT
  value: {{ required "auth.oidc.authorizationEndpoint is required when auth.oidc.enabled is true" .Values.auth.oidc.authorizationEndpoint | quote }}
- name: OPENID_ISSUER
  value: {{ required "auth.oidc.issuer is required when auth.oidc.enabled is true" .Values.auth.oidc.issuer | quote }}
- name: OPENID_JWKS_ENDPOINT
  value: {{ required "auth.oidc.jwksEndpoint is required when auth.oidc.enabled is true" .Values.auth.oidc.jwksEndpoint | quote }}
- name: OPENID_CLIENT_ID
  value: {{ required "auth.oidc.clientId is required when auth.oidc.enabled is true" .Values.auth.oidc.clientId | quote }}
{{- if .Values.auth.oidc.existingSecret }}
- name: OPENID_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.auth.oidc.existingSecret }}
      key: client-secret
{{- else if .Values.auth.oidc.clientSecret }}
- name: OPENID_CLIENT_SECRET
  value: {{ .Values.auth.oidc.clientSecret | quote }}
{{- end }}
{{- if .Values.auth.oidc.redirectUri }}
- name: OPENID_REDIRECT_URI
  value: {{ .Values.auth.oidc.redirectUri | quote }}
{{- end }}
- name: OPENID_SCOPE
  value: {{ .Values.auth.oidc.scope | quote }}
- name: OPENID_USERNAME_CLAIM_TYPE
  value: {{ .Values.auth.oidc.usernameClaim | quote }}
{{- range $key, $value := .Values.auth.oidc.extraConfig }}
- name: OPENID_{{ $key | upper | replace "-" "_" }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}

{{/*
LDAP environment variables
*/}}
{{- define "guacamole.ldap.env" -}}
- name: LDAP_HOSTNAME
  value: {{ required "auth.ldap.hostname is required when auth.ldap.enabled is true" .Values.auth.ldap.hostname | quote }}
- name: LDAP_PORT
  value: {{ .Values.auth.ldap.port | quote }}
- name: LDAP_ENCRYPTION_METHOD
  value: {{ .Values.auth.ldap.encryption | quote }}
- name: LDAP_USER_BASE_DN
  value: {{ required "auth.ldap.userBaseDn is required when auth.ldap.enabled is true" .Values.auth.ldap.userBaseDn | quote }}
- name: LDAP_USERNAME_ATTRIBUTE
  value: {{ .Values.auth.ldap.usernameAttribute | quote }}
{{- if .Values.auth.ldap.searchBindDn }}
- name: LDAP_SEARCH_BIND_DN
  value: {{ .Values.auth.ldap.searchBindDn | quote }}
{{- if .Values.auth.ldap.existingSecret }}
- name: LDAP_SEARCH_BIND_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.auth.ldap.existingSecret }}
      key: bind-password
{{- else if .Values.auth.ldap.searchBindPassword }}
- name: LDAP_SEARCH_BIND_PASSWORD
  value: {{ .Values.auth.ldap.searchBindPassword | quote }}
{{- end }}
{{- end }}
{{- range $key, $value := .Values.auth.ldap.extraConfig }}
- name: LDAP_{{ $key | upper | replace "-" "_" }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}

{{/*
SAML environment variables
*/}}
{{- define "guacamole.saml.env" -}}
- name: SAML_IDP_METADATA_URL
  value: {{ required "auth.saml.idpMetadataUrl is required when auth.saml.enabled is true" .Values.auth.saml.idpMetadataUrl | quote }}
- name: SAML_ENTITY_ID
  value: {{ required "auth.saml.entityId is required when auth.saml.enabled is true" .Values.auth.saml.entityId | quote }}
{{- if .Values.auth.saml.callbackUrl }}
- name: SAML_CALLBACK_URL
  value: {{ .Values.auth.saml.callbackUrl | quote }}
{{- end }}
{{- range $key, $value := .Values.auth.saml.extraConfig }}
- name: SAML_{{ $key | upper | replace "-" "_" }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}

{{/*
TOTP environment variables
*/}}
{{- define "guacamole.totp.env" -}}
- name: TOTP_ISSUER
  value: {{ .Values.auth.totp.issuer | quote }}
- name: TOTP_DIGITS
  value: "6"
- name: TOTP_PERIOD
  value: "30"
- name: TOTP_MODE
  value: {{ .Values.auth.totp.mode | quote }}
{{- end }}

{{/*
Duo environment variables
*/}}
{{- define "guacamole.duo.env" -}}
- name: DUO_API_HOSTNAME
  value: {{ required "auth.duo.apiHostname is required when auth.duo.enabled is true" .Values.auth.duo.apiHostname | quote }}
- name: DUO_CLIENT_ID
  value: {{ required "auth.duo.clientId is required when auth.duo.enabled is true" .Values.auth.duo.clientId | quote }}
{{- if .Values.auth.duo.existingSecret }}
- name: DUO_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.auth.duo.existingSecret }}
      key: client-secret
{{- else if .Values.auth.duo.clientSecret }}
- name: DUO_CLIENT_SECRET
  value: {{ .Values.auth.duo.clientSecret | quote }}
{{- end }}
{{- if .Values.auth.duo.redirectUri }}
- name: DUO_REDIRECT_URI
  value: {{ .Values.auth.duo.redirectUri | quote }}
{{- end }}
{{- if .Values.auth.duo.authTimeout }}
- name: DUO_AUTH_TIMEOUT
  value: {{ .Values.auth.duo.authTimeout | quote }}
{{- end }}
{{- if .Values.auth.duo.bypassHosts }}
- name: DUO_BYPASS_HOSTS
  value: {{ .Values.auth.duo.bypassHosts | quote }}
{{- end }}
{{- if .Values.auth.duo.enforceHosts }}
- name: DUO_ENFORCE_HOSTS
  value: {{ .Values.auth.duo.enforceHosts | quote }}
{{- end }}
{{- end }}

{{/*
RADIUS environment variables
*/}}
{{- define "guacamole.radius.env" -}}
- name: RADIUS_HOSTNAME
  value: {{ .Values.auth.radius.hostname | quote }}
- name: RADIUS_AUTH_PORT
  value: {{ .Values.auth.radius.authPort | quote }}
{{- if .Values.auth.radius.existingSecret }}
- name: RADIUS_SHARED_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.auth.radius.existingSecret }}
      key: shared-secret
{{- else if .Values.auth.radius.sharedSecret }}
- name: RADIUS_SHARED_SECRET
  value: {{ .Values.auth.radius.sharedSecret | quote }}
{{- end }}
- name: RADIUS_AUTH_PROTOCOL
  value: {{ .Values.auth.radius.authProtocol | quote }}
{{- if .Values.auth.radius.retries }}
- name: RADIUS_RETRIES
  value: {{ .Values.auth.radius.retries | quote }}
{{- end }}
{{- if .Values.auth.radius.timeout }}
- name: RADIUS_TIMEOUT
  value: {{ .Values.auth.radius.timeout | quote }}
{{- end }}
{{- if .Values.auth.radius.trustAll }}
- name: RADIUS_TRUST_ALL
  value: {{ .Values.auth.radius.trustAll | quote }}
{{- end }}
{{- if .Values.auth.radius.nasIp }}
- name: RADIUS_NAS_IP
  value: {{ .Values.auth.radius.nasIp | quote }}
{{- end }}
{{- if .Values.auth.radius.eapTtlsInnerProtocol }}
- name: RADIUS_EAP_TTLS_INNER_PROTOCOL
  value: {{ .Values.auth.radius.eapTtlsInnerProtocol | quote }}
{{- end }}
{{- if .Values.auth.radius.keyFile }}
- name: RADIUS_KEY_FILE
  value: {{ .Values.auth.radius.keyFile | quote }}
{{- end }}
{{- if .Values.auth.radius.keyType }}
- name: RADIUS_KEY_TYPE
  value: {{ .Values.auth.radius.keyType | quote }}
{{- end }}
{{- if .Values.auth.radius.keyPassword }}
- name: RADIUS_KEY_PASSWORD
  value: {{ .Values.auth.radius.keyPassword | quote }}
{{- end }}
{{- if .Values.auth.radius.caFile }}
- name: RADIUS_CA_FILE
  value: {{ .Values.auth.radius.caFile | quote }}
{{- end }}
{{- if .Values.auth.radius.caType }}
- name: RADIUS_CA_TYPE
  value: {{ .Values.auth.radius.caType | quote }}
{{- end }}
{{- if .Values.auth.radius.caPassword }}
- name: RADIUS_CA_PASSWORD
  value: {{ .Values.auth.radius.caPassword | quote }}
{{- end }}
{{- end }}

{{/*
CAS environment variables
*/}}
{{- define "guacamole.cas.env" -}}
- name: CAS_AUTHORIZATION_ENDPOINT
  value: {{ required "auth.cas.authorizationEndpoint is required when auth.cas.enabled is true" .Values.auth.cas.authorizationEndpoint | quote }}
- name: CAS_REDIRECT_URI
  value: {{ required "auth.cas.redirectUri is required when auth.cas.enabled is true" .Values.auth.cas.redirectUri | quote }}
{{- if .Values.auth.cas.clearpassKey }}
- name: CAS_CLEARPASS_KEY
  value: {{ .Values.auth.cas.clearpassKey | quote }}
{{- end }}
{{- if .Values.auth.cas.groupAttribute }}
- name: CAS_GROUP_ATTRIBUTE
  value: {{ .Values.auth.cas.groupAttribute | quote }}
{{- end }}
{{- if .Values.auth.cas.groupFormat }}
- name: CAS_GROUP_FORMAT
  value: {{ .Values.auth.cas.groupFormat | quote }}
{{- end }}
{{- if .Values.auth.cas.groupLdapBaseDn }}
- name: CAS_GROUP_LDAP_BASE_DN
  value: {{ .Values.auth.cas.groupLdapBaseDn | quote }}
{{- end }}
{{- if .Values.auth.cas.groupLdapAttribute }}
- name: CAS_GROUP_LDAP_ATTRIBUTE
  value: {{ .Values.auth.cas.groupLdapAttribute | quote }}
{{- end }}
{{- end }}

{{/*
JSON authentication environment variables
*/}}
{{- define "guacamole.json.env" -}}
{{- if .Values.auth.json.existingSecret }}
- name: JSON_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.auth.json.existingSecret }}
      key: secret-key
{{- else if .Values.auth.json.secretKey }}
- name: JSON_SECRET_KEY
  value: {{ .Values.auth.json.secretKey | quote }}
{{- end }}
{{- end }}

{{/*
HTTP Header authentication environment variables
*/}}
{{- define "guacamole.header.env" -}}
- name: HTTP_AUTH_HEADER
  value: {{ .Values.auth.header.httpAuthHeader | quote }}
{{- end }}

{{/*
SSL/Certificate authentication environment variables
*/}}
{{- define "guacamole.ssl.env" -}}
- name: SSL_AUTH_URI
  value: {{ required "auth.ssl.authUri is required when auth.ssl.enabled is true" .Values.auth.ssl.authUri | quote }}
- name: SSL_AUTH_PRIMARY_URI
  value: {{ required "auth.ssl.primaryUri is required when auth.ssl.enabled is true" .Values.auth.ssl.primaryUri | quote }}
{{- if .Values.auth.ssl.clientCertificateHeader }}
- name: SSL_AUTH_CLIENT_CERTIFICATE_HEADER
  value: {{ .Values.auth.ssl.clientCertificateHeader | quote }}
{{- end }}
{{- if .Values.auth.ssl.clientVerifiedHeader }}
- name: SSL_AUTH_CLIENT_VERIFIED_HEADER
  value: {{ .Values.auth.ssl.clientVerifiedHeader | quote }}
{{- end }}
{{- if .Values.auth.ssl.maxTokenValidity }}
- name: SSL_AUTH_MAX_TOKEN_VALIDITY
  value: {{ .Values.auth.ssl.maxTokenValidity | quote }}
{{- end }}
{{- if .Values.auth.ssl.subjectUsernameAttribute }}
- name: SSL_AUTH_SUBJECT_USERNAME_ATTRIBUTE
  value: {{ .Values.auth.ssl.subjectUsernameAttribute | quote }}
{{- end }}
{{- if .Values.auth.ssl.subjectBaseDn }}
- name: SSL_AUTH_SUBJECT_BASE_DN
  value: {{ .Values.auth.ssl.subjectBaseDn | quote }}
{{- end }}
{{- if .Values.auth.ssl.maxDomainValidity }}
- name: SSL_AUTH_MAX_DOMAIN_VALIDITY
  value: {{ .Values.auth.ssl.maxDomainValidity | quote }}
{{- end }}
{{- end }}

{{/*
Keeper Secrets Manager (KSM) environment variables
*/}}
{{- define "guacamole.ksm.env" -}}
{{- if .Values.vault.ksm.existingSecret }}
- name: KSM_CONFIG
  valueFrom:
    secretKeyRef:
      name: {{ .Values.vault.ksm.existingSecret }}
      key: ksm-config
{{- else if .Values.vault.ksm.config }}
- name: KSM_CONFIG
  value: {{ .Values.vault.ksm.config | quote }}
{{- end }}
{{- if .Values.vault.ksm.allowUserConfig }}
- name: KSM_ALLOW_USER_CONFIG
  value: {{ .Values.vault.ksm.allowUserConfig | quote }}
{{- end }}
{{- if .Values.vault.ksm.allowUnverifiedCert }}
- name: KSM_ALLOW_UNVERIFIED_CERT
  value: {{ .Values.vault.ksm.allowUnverifiedCert | quote }}
{{- end }}
{{- if .Values.vault.ksm.apiCallInterval }}
- name: KSM_API_CALL_INTERVAL
  value: {{ .Values.vault.ksm.apiCallInterval | quote }}
{{- end }}
{{- if .Values.vault.ksm.stripWindowsDomains }}
- name: KSM_STRIP_WINDOWS_DOMAINS
  value: {{ .Values.vault.ksm.stripWindowsDomains | quote }}
{{- end }}
{{- end }}

{{/*
QuickConnect environment variables
*/}}
{{- define "guacamole.quickconnect.env" -}}
- name: QUICKCONNECT_ENABLED
  value: "true"
{{- if .Values.quickConnect.allowedParameters }}
- name: QUICKCONNECT_ALLOWED_PARAMETERS
  value: {{ .Values.quickConnect.allowedParameters | quote }}
{{- end }}
{{- if .Values.quickConnect.deniedParameters }}
- name: QUICKCONNECT_DENIED_PARAMETERS
  value: {{ .Values.quickConnect.deniedParameters | quote }}
{{- end }}
{{- end }}

{{/*
Recording playback environment variables
*/}}
{{- define "guacamole.recording.env" -}}
{{- if .Values.recording.playback.enabled }}
- name: RECORDING_SEARCH_PATH
  value: {{ .Values.recording.playback.searchPath | quote }}
{{- end }}
{{- end }}

{{/*
API session environment variables
*/}}
{{- define "guacamole.api.env" -}}
{{- if .Values.api.session.timeout }}
- name: API_SESSION_TIMEOUT
  value: {{ .Values.api.session.timeout | quote }}
{{- end }}
{{- if .Values.api.session.maxConnectionsPerUser }}
- name: MYSQL_DEFAULT_MAX_CONNECTIONS_PER_USER
  value: {{ .Values.api.session.maxConnectionsPerUser | quote }}
- name: POSTGRESQL_DEFAULT_MAX_CONNECTIONS_PER_USER
  value: {{ .Values.api.session.maxConnectionsPerUser | quote }}
{{- end }}
{{- if .Values.api.session.maxConnections }}
- name: MYSQL_DEFAULT_MAX_CONNECTIONS
  value: {{ .Values.api.session.maxConnections | quote }}
- name: POSTGRESQL_DEFAULT_MAX_CONNECTIONS
  value: {{ .Values.api.session.maxConnections | quote }}
{{- end }}
{{- end }}

{{/*
Brute force protection environment variables
*/}}
{{- define "guacamole.bruteforce.env" -}}
{{- if .Values.bruteForce.enabled }}
- name: MYSQL_USER_PASSWORD_MAX_AGE
  value: {{ .Values.bruteForce.lockoutDuration | quote }}
- name: POSTGRESQL_USER_PASSWORD_MAX_AGE
  value: {{ .Values.bruteForce.lockoutDuration | quote }}
{{- end }}
{{- end }}

{{/*
Advanced configuration environment variables
*/}}
{{- define "guacamole.advanced.env" -}}
{{- if .Values.advanced.guacamoleHome }}
- name: GUACAMOLE_HOME
  value: {{ .Values.advanced.guacamoleHome | quote }}
{{- end }}
{{- end }}
