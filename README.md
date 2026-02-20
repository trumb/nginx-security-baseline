# Nginx Security Baseline

Reusable nginx security hardening for all deployments. Includes an nginx snippet, fail2ban configs, a one-line installer, and a GitHub Action to enforce compliance.

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

### Blocked Paths
- Dotfiles (`.git`, `.env`, `.htaccess`)
- Script extensions (`.php`, `.asp`, `.jsp`, `.cgi`)
- Config files (`docker-compose.yml`, `Dockerfile`, `Makefile`, `.vscode/sftp.json`)
- Exploit paths (`/wp-admin`, `/phpmyadmin`, `/actuator`, `/shell`, `/console`, `/_ignition`, etc.)

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
