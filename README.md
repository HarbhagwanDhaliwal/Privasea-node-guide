# Privasea Acceleration Node Setup Guide

This guide provides step-by-step instructions to set up and run the Privasea Acceleration Node.

## Prerequisites

- Docker installed on your system
- Basic command-line knowledge
- Your keystore file (for authentication)

---

## Step 1: Pull the Docker Image

First, pull the latest version of the Privasea Acceleration Node Docker image by running:

```bash
docker pull privasea/acceleration-node-beta:latest
```

---

## Step 2: Locate and Rename Keystore File

Before running the node, ensure the keystore file is correctly named.

1. Navigate to the configuration directory:

   ```bash
   Check for file & rename the keystore file in folder to name wallet_keystore
   Check the Keystore & Rename
   The first command this directory and list the files inside it:
   cd /privasea/config && ls
   You will see a list of files in this folder. One of the files you need to find will be the keystore file, which typically looks like this:
   + example like: UTC--2025-01-06T06-11-07.485797065Z--f07c3ef23ae7beb8cd8ba5ff546e35fd4b332b34
   Once you find the keystore file, you need copy file like; UTC--2025-01-06T06..xxxxx to rename it to wallet_keystore
   mv ./UTC--2025-01-06T06..xxxxxxxxxxxxxxxxxxx ./wallet_keystore
   docker run  -d   -v "/privasea/config:/app/config" \
   -e KEYSTORE_PASSWORD=123456 \
   privasea/acceleration-node-beta:latest
   ```

2. Identify the keystore file, which typically has a name like:

   ```
   UTC--2025-01-06T06-11-07.485797065Z--f07c3ef23ae7beb8cd8ba5ff546e35fd4b332b34
   ```

3. Rename the keystore file to `wallet_keystore`:

   ```bash
   mv ./UTC--2025-01-06T06..xxxxxxxxxxxxxxxxxxx ./wallet_keystore
   ```

---

## Step 3: Run the Node

Once the keystore file is correctly set, start the node with the following command:

```bash
docker run -d \
  -v "/privasea/config:/app/config" \
  -e KEYSTORE_PASSWORD=123456 \
  privasea/acceleration-node-beta:latest
```

Replace `123456` with your actual keystore password.

---

## Step 4: Monitor the Node

You can check the container logs to monitor the progress:

```bash
docker logs -f <container_id>
```

Find the container ID using:

```bash
docker ps
```

Expected successful messages include:

- `read mgrNodeInfo info is ok`
- `get sharedKey success !!!`
- `upload result to ipfs success !!!`
- `Processing tasks success!!!`
- `update task result success!!!`

---

## Step 5: Managing the Node

### Stop the Node

```bash
docker stop <container_id>
```

### Restart the Node

```bash
docker restart <container_id>
```

### Remove the Node

If needed, remove the container completely:

```bash
docker rm -f <container_id>
```

---

## Step 6: Troubleshooting

If you encounter any issues, check the following:

- Ensure the keystore file is correctly named as `wallet_keystore`
- Verify Docker is running and accessible
- Review the container logs for any error messages

---

## Conclusion

Following this guide will help you successfully set up and run the Privasea Acceleration Node. If you need further assistance, refer to the official documentation or community support channels.

