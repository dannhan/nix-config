# nix-config

NixOS + home-manager for a single machine. Secrets use
[sops-nix](https://github.com/Mic92/sops-nix) with age.

## Layout

- `configuration.nix` — system config, including the sops-nix wiring
- `home.nix` — home-manager config
- `flake.nix` — inputs/outputs (`.#nixos`, `.#ruyam@nixos`)
- `modules/` — home-manager sub-modules
- `dotfiles/` — niri and friends
- `secrets.yaml` — encrypted secrets (committed)
- `.sops.yaml` — which public key `secrets.yaml` is encrypted for

## Secrets

`.sops.yaml` holds the age **public** key. `~/.config/sops/age/keys.txt` holds the
**private** key and is never committed. sops encrypts with the public key;
sops-nix decrypts with the private key at activation (every boot and every
rebuild) into `/run/secrets/<name>`, which lives in RAM. Nothing decrypted ever
reaches `/nix/store`.

```bash
sops secrets.yaml        # edit; saving re-encrypts
sops -d secrets.yaml     # read only
```

To add a secret: add `my-secret: value` to `secrets.yaml`, declare
`sops.secrets."my-secret" = { };` in `configuration.nix`, then point the service
at `config.sops.secrets."my-secret".path`.

`secrets.yaml` must stay git-tracked — flakes cannot read ignored files. Never
track `keys.txt`, and back it up: losing it loses every secret permanently.

### eduroam

The secret *is* the env file NetworkManager reads:

```yaml
eduroam-env: |
  EDUROAM_IDENTITY=...
  EDUROAM_PASSWORD=...
```

`environmentFiles` points at `config.sops.secrets."eduroam-env".path` and the
profile uses `$EDUROAM_IDENTITY` / `$EDUROAM_PASSWORD`. Plaintext cannot live in
the Nix config: everything evaluated ends up world-readable in `/nix/store`.

After changing it, refresh the profile or reboot:

```bash
sudo systemctl restart NetworkManager-ensure-profiles
```

### New machine

Restore `~/.config/sops/age/keys.txt` (mode 600), add its public key
(`age-keygen -y <keys.txt>`) to `.sops.yaml`, then `sops updatekeys secrets.yaml`.

### Rebuild

```bash
sudo nixos-rebuild switch --flake .#nixos
```
