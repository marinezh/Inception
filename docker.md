## 1️⃣ Install Docker

```bash
sudo apt install -y docker.io
```
Enable + start Docker:
```bash
sudo systemctl enable docker
sudo systemctl start docker
```
Allow user to run Docker without sudo:
```bash
sudo usermod -aG docker mzhivoto
```
Reboot (important):
```bash
sudo reboot
```
After reboot, test:
```bash
docker ps
```
✅ If no error → Docker works.

## 2️⃣ Install Docker Compose

```bash
sudo apt install -y docker-compose
```
Test:
```bash
docker compose version
```
✅ should see docker-compose version 1.29.x
