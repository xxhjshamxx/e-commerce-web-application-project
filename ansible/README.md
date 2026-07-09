# Ansible DevOps Playbook

Full, role-based Ansible project that:

| Play / Tag | What it does |
|---|---|
| `ping`   | Checks Ansible connectivity to every host, then runs a real ICMP ping from each managed host to `8.8.8.8`, `1.1.1.1`, and `github.com` |
| `docker` | Installs Docker Engine (CE) the official way — repo + GPG key, `docker-ce`, `docker-ce-cli`, `containerd.io`, Buildx and Compose plugins — on Ubuntu/Debian **and** RHEL/CentOS/Rocky/Alma, starts/enables the service, adds users to the `docker` group |
| `tools`  | Installs any package from the distro repos (`tools_extra_packages`), plus optional direct-download installs of `kubectl`, `terraform`, `awscli`, `helm` |
| `cleanup`| Deletes files/directories, deletes files matching a glob pattern, removes packages, optionally prunes Docker, and runs apt/dnf autoremove |

Tested with `ansible-core 2.21` and `ansible-lint 26`. Every module used is
`ansible.builtin.*` — **no external collections required**.

## Structure

```
ansible-devops/
├── ansible.cfg
├── site.yml                    # master playbook (imports the 4 below)
├── inventory/
│   ├── hosts.ini
│   └── group_vars/all.yml      # every variable you'd ever want to change
├── playbooks/
│   ├── ping.yml
│   ├── install_docker.yml
│   ├── install_tools.yml
│   └── cleanup.yml
└── roles/
    ├── common/          # base packages, facts
    ├── docker/          # Docker Engine install (Debian + RedHat)
    ├── tools/           # generic + specific tool installs
    ├── cleanup/         # deletion tasks
    └── network_check/   # ping / connectivity
```

> **Why `group_vars` lives inside `inventory/` and not at the project root:**
> Ansible resolves `group_vars`/`host_vars` relative to the **inventory
> file's directory**, not the playbook's directory. Since `site.yml`
> imports playbooks from a `playbooks/` subfolder, a root-level
> `group_vars/` would silently fail to load when those sub-playbooks run
> (confirmed by actually executing this project, not just by reading the
> docs). Keeping it next to `inventory/hosts.ini` makes it load correctly
> no matter which playbook you run it from.

## 1. Configure your hosts

Edit `inventory/hosts.ini`:

```ini
[servers]
web1 ansible_host=10.0.0.11 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
web2 ansible_host=10.0.0.12 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
```

`[local]` is already configured to run everything against the control
machine itself (`ansible_connection=local`) so you can dry-run the whole
thing before touching real servers.

## 2. Check connectivity first

```bash
ansible-playbook site.yml --tags ping
```

## 3. Install Docker

```bash
ansible-playbook site.yml --tags docker
```

Supports Ubuntu, Debian, RHEL 8+, CentOS 8+, Rocky Linux, AlmaLinux.
Old/conflicting Docker packages (`docker.io`, `podman-docker`, etc.) are
removed automatically before installing Docker CE.

## 4. Install extra tools

Edit `inventory/group_vars/all.yml` to add any apt/dnf package to `tools_extra_packages`,
or flip one of these to `true` to fetch it straight from the vendor:

```yaml
tools_install_kubectl: true
tools_install_terraform: true
tools_install_awscli: true
tools_install_helm: true
```

Then:

```bash
ansible-playbook site.yml --tags tools
```

## 5. Clean up (delete files / packages / docker data)

```bash
ansible-playbook site.yml --tags cleanup
```

Controlled entirely from `inventory/group_vars/all.yml`:

```yaml
cleanup_paths: [/tmp/ansible_demo, /tmp/old_build_artifacts]
cleanup_find_root: /var/cache/apt/archives
cleanup_find_patterns: ["*.deb"]
cleanup_packages: []
cleanup_docker_prune: false      # true = docker system prune -af --volumes (DESTRUCTIVE)
cleanup_apt_autoremove: true
```

## Run everything at once

```bash
ansible-playbook site.yml                    # ping + docker + tools + cleanup
ansible-playbook site.yml --skip-tags cleanup   # everyday use, skip deletions
ansible-playbook site.yml --check               # dry-run (no changes made)
```

## Validate before running against real servers

```bash
ansible-playbook site.yml --syntax-check
ansible-lint site.yml
```

## Notes / assumptions

- Docker role targets **Ubuntu/Debian** and **RHEL/CentOS/Rocky/Alma 8+**
  (dnf-based). Legacy CentOS 7 / RHEL 7 (yum-only, no dnf) is not covered.
- `cleanup_docker_prune` is `false` by default because it is destructive
  (removes all stopped containers, unused images/networks/volumes).
- All registered variables and role defaults are prefixed with the role
  name (`docker_`, `tools_`, `cleanup_`, `network_check_`) to avoid
  variable collisions if these roles are reused elsewhere.
