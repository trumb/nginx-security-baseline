# Nginx Security Baseline

Reusable nginx security hardening for all deployments. Includes an nginx snippet that blocks **35 attack categories**, fail2ban configs, a one-line installer, and a GitHub Action to enforce compliance.

All rules derived from **live honeypot data** — real scanners probing real servers. Updated 2026-03-23.

## Quick Start

### On a server

```bash
curl -sSL https://raw.githubusercontent.com/trumb/nginx-security-baseline/main/install.sh | sudo bash
```

Then add to each nginx server block:

```nginx
include /etc/nginx/snippets/security-hardening.conf;
```

### In a Dockerfile

```dockerfile
COPY security-hardening.conf /etc/nginx/snippets/security-hardening.conf
```

And in your nginx config:

```nginx
include /etc/nginx/snippets/security-hardening.conf;
```

### In GitHub Actions

Add to any repo's CI workflow:

```yaml
- name: Check nginx security baseline
  uses: trumb/nginx-security-baseline@main
```

With Dockerfile checking enabled:

```yaml
- name: Check nginx security baseline
  uses: trumb/nginx-security-baseline@main
  with:
    check-fail2ban: 'true'
```

## What It Does

### Security Headers
- `X-Frame-Options: SAMEORIGIN`
- `X-Content-Type-Options: nosniff`
- `X-XSS-Protection: 1; mode=block`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Strict-Transport-Security: max-age=31536000`
- `Permissions-Policy: camera=(), microphone=(), geolocation=()`

### Blocked Paths (35 Categories)

| Category | Examples |
|----------|----------|
| **Dotfiles** | `.git`, `.env` (21+ variants), `.aws/credentials`, `.DS_Store` |
| **Script extensions** | `.php`, `.asp`, `.jsp`, `.cgi` |
| **Source maps** | `*.js.map`, `*.json.map` (20+ variants) |
| **Config files** | `credentials.json`, `config.env`, `config.json`, `docker-compose.yml` |
| **WordPress** | `wp-admin`, `wp-content`, `wp-json`, `xmlrpc.php`, `wlwmanifest.xml` |
| **Spring Actuator** | `actuator/env`, `manage/env`, `actuator/gateway/routes` |
| **Swagger/OpenAPI** | `swagger-ui.html`, `api-docs`, `swagger.json` |
| **PHP/Laravel debug** | `_profiler`, `telescope`, `_ignition`, `_wdt`, `horizon` |
| **Container/K8s** | `v2/_catalog`, `api/v1/namespaces/default/secrets` |
| **JS dev tools** | `@vite/client`, `webpack-dev-server`, `_next/data` |
| **Atlassian** | `login.action`, `META-INF/maven/...` |
| **MS Exchange** | `/ecp/` (ProxyShell/ProxyLogon) |
| **GraphQL** | `graphql`, `api/graphql`, `api/gql` |
| **Admin panels** | `phpmyadmin`, `adminer`, `solr`, `hudson`, `druid`, `jenkins` |
| **Path traversal** | `cgi-bin/.%2e/`, `..%2F`, `%%32%65`, `/etc/passwd` |
| **HNAP/Router** | `/HNAP1` (D-Link/Netgear/Mirai) |
| **VPN gateways** | `/+CSCOE+/` (Cisco), `/dana-na/` (Pulse Secure/Ivanti) |
| **Apache Struts** | `/struts/utils.js`, `/struts2-showcase/` |
| **Log4Shell/JNDI** | `${jndi:ldap://...}` in URI, Referer, UA |
| **SSH key theft** | `/id_rsa`, `/id_ed25519` |
| **IoT/OEM devices** | `/boaform/` (TP-Link), `/GponForm/` (GPON), `/sdk` (Hikvision) |
| **Package files** | `composer.json`, `yarn.lock`, `package.json`, `pom.xml` |
| **App settings** | `appsettings.json`, `settings.py`, `WEB-INF/web.xml` |
| **XDEBUG** | `?XDEBUG_SESSION_START=phpstorm` |
| **Enterprise apps** | `/developmentserver/` (SAP), `/PassTrixMain.cc` (ManageEngine) |
| **And more...** | InfluxDB, Lotus Notes, network infrastructure, phishing kits |

### Fail2ban Jails
| Jail | What it catches | Threshold | Ban |
|------|----------------|-----------|-----|
| `nginx-badbots` | Exploit path probes, traversal, CONNECT | 3 in 10 min | 24h |
| `nginx-uploadfuzz` | Upload endpoint enumeration | 10 in 60s | 24h |
| `nginx-scanners` | Generic repeated 404/405 | 15 in 5 min | 1h |

## GitHub Action Inputs

| Input | Default | Description |
|-------|---------|-------------|
| `check-fail2ban` | `false` | Also check Dockerfiles for security snippet |
| `security-snippet-path` | `/etc/nginx/snippets/security-hardening.conf` | Expected include path |

## File Structure

```
├── security-hardening.conf     # The nginx snippet (copy to /etc/nginx/snippets/)
├── action.yml                  # GitHub Action definition
├── install.sh                  # One-line server installer
├── fail2ban/
│   ├── filter.d/
│   │   ├── nginx-badbots.conf
│   │   ├── nginx-uploadfuzz.conf
│   │   └── nginx-scanners.conf
│   └── jail.d/
│       └── nginx.conf
└── README.md
```

## Changelog

### v2.0.0 (2026-03-23)
- **35 attack categories** (up from 19) — added HNAP, VPN gateways, Struts, Log4Shell, SSH key theft, IoT/OEM, package files, app settings, XDEBUG, enterprise apps, InfluxDB, network infra, and more
- Enhanced path traversal coverage (double-encoding, /etc/passwd variants)
- All rules derived from live honeypot log analysis (Feb 23 – Mar 23, 2026)
