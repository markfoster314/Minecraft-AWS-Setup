# Minecraft-AWS-Setup

Scripts and reference material for manually setting up a Minecraft server on AWS. Companion to our setup guide.

## Contents

Each script is a self-contained EC2 **user-data** script for a specific Minecraft version range. They all install the right Amazon Corretto JDK, download the server jar, accept the EULA, and register a `systemd` service so the server starts on boot.

| Script                                | Minecraft versions   | Java | Default heap |
| ------------------------------------- | -------------------- | ---- | ------------ |
| `scripts/launch_1-7-10_to_1-16-5.sh`  | `1.7.10` – `1.16.5`  | 8    | 1.5 GB       |
| `scripts/launch_1-17_to_1-20-4.sh`    | `1.17` – `1.20.4`    | 17   | 2 GB         |
| `scripts/launch_1-20-5_to_1-21-11.sh` | `1.20.5` – `1.21.11` | 21   | 4 GB         |
| `scripts/launch_26-1_up.sh`           | `26.1` and newer     | 25   | 4 GB         |

> **Note on 1.17 / 1.17.1**: these officially target Java 16, but Corretto 16 is non-LTS and not in the AL2023 yum repo. The `1-17_to_1-20-4` script uses Corretto 17, which is backward-compatible.

## Usage

1. Pick the script that matches your target Minecraft version.
2. Edit it and set `MINECRAFTSERVERURL` to the official Minecraft server jar URL (no spaces around `=`).
3. Paste the script into the **User data** field when launching the EC2 instance, or run it on the instance as `root`.
4. Configure the security group as described below before connecting via EC2 Instance Connect.

### Requirements

- **Amazon Linux 2023** AMI (provides the Corretto packages via `yum`).
- **Instance type**: size for the heap your script reserves — `t3.small` works for the Java 8 script, `t3.medium` for Java 17, `t3.large` (or larger) for Java 21 / 25.
- Adjust the `-Xmx` / `-Xms` flags inside the script if you want a different heap size.

## Security Group: EC2 Instance Connect IP Ranges

To use **EC2 Instance Connect** (browser-based SSH) you must allow inbound TCP/22 from the AWS-owned CIDR for your region.

Common US regions:

| Region      | CIDR                |
| ----------- | ------------------- |
| `us-east-1` | `18.206.107.24/29`  |
| `us-east-2` | `3.16.146.0/29`     |
| `us-west-1` | `13.52.6.112/29`    |
| `us-west-2` | `18.237.140.160/29` |

You'll also want to allow inbound TCP/25565 from `0.0.0.0/0` (or a narrower range) so players can reach the Minecraft server.

### Finding the CIDR for other regions

1. Open the [AWS IP address ranges page](https://docs.aws.amazon.com/vpc/latest/userguide/aws-ip-ranges.html#aws-ip-download) and download `ip-ranges.json`.
2. Open the file in a browser to view as raw data.
3. Search (`Ctrl+F` / `Cmd+F`) for `EC2_INSTANCE_CONNECT`.
4. Use the `ip_prefix` whose `region` matches yours.

## License

See [LICENSE](LICENSE).
