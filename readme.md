# Dagster Mini POC: Understanding Code Locations and Isolated Deployments

## Introduction

This guide walks through setting up a Dagster Proof of Concept (POC) without using `docker-compose`. The goal is to explicitly run each command to help build intuition around Dagster code locations and how each service interacts in an isolated CD pipeline, similar to deploying each service in separate GitHub repositories.

By following this guide, you will:
- Understand how Dagster's webserver, daemon, and code locations interact.
- Learn the importance of running Postgres first as the orchestrator backend.
- Appreciate why explicit Docker commands help clarify service dependencies.

### Repository Structure
```
.
├── Dockerfile  # Webserver & Daemon Image
├── dagster.yaml
├── finance_code_location
│   ├── Dockerfile  # Finance Code Location Image
│   ├── definitions
│   │   ├── __init__.py
│   │   └── assets.py
│   └── requirements.txt
├── marketing_code_location
│   ├── Dockerfile  # Marketing Code Location Image
│   ├── definitions
│   │   ├── __init__.py
│   │   └── assets.py
│   └── requirements.txt
├── ml_code_location
│   ├── Dockerfile  # ML Code Location Image
│   ├── definitions
│   │   ├── __init__.py
│   │   └── assets.py
│   └── requirements.txt
└── workspace.yaml
```

Each code location (`finance_code_location`, `marketing_code_location`, and `ml_code_location`) has its own Dockerfile. The main `Dockerfile` at the root directory is used for the Dagster webserver and daemon.

## Setup Using `Makefile`

### **1. Create the Network and Start PostgreSQL**
```sh
make network
make postgres
```

### **2. Build the Docker Images**
```sh
make build
```

### **3. Run Code Location Services**
```sh
make run
```

### **4. Start Dagster Webserver and Daemon**
```sh
make webserver
make daemon
```

### **5. Open the Dagster UI**
```sh
make open
```
This opens Dagster at: [http://localhost:3000](http://localhost:3000)

### **6. Run Everything with a single command**
```sh
make all
```

### **7. Stop and Clean Everything**
```sh
make clean
```
This will:
✅ Stop and remove all containers
✅ Remove the network
✅ Force-delete built images

