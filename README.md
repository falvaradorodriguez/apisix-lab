# APISIX + FastAPI + Keycloak LAB

A lab setup for integrating APISIX, FastAPI, and Keycloak.
This repository provides a complete environment to run a FastAPI-based API protected with Keycloak and exposed via APISIX. 
Ideal for testing security and access control in API architectures.


## 📌 Requirements

Docker and Docker Compose

## 📡 Keycloak Configuration

1. Access Keycloak at `http://localhost:8080`

2. Log in with:
   - Username: admin
   - Password: admin

3. Create a new Realm named `apisix_test_realm`

4. Configure a client with:
   - Client ID: apisix
   - Client Protocol: openid-connect
   - Access Type: confidential
   - Client Secret: xxxx

5. Create a user:
   - Username: user
   - Password: xxx
   - Enable the user and assign the appropriate role

## 🔗 APISIX Configuration

1. Access the APISIX API at http://localhost:9180

2. Create a new Upstream pointing to FastAPI:

    ```bash
        curl --location --request POST 'http://localhost:9180/apisix/admin/upstreams' \
        --header 'Content-Type: application/json' \
        --header "X-API-KEY: a3b7d5e812c49f6038e2ab91f4d6c7e5" \
        --data-raw '{
            "name": "fastapi",
            "nodes": {
                "fastapi-app:8000": 1
            },
            "type": "roundrobin"
        }'
    ```

3. Create a route with Keycloak authentication and redirecting all traffic from /service/* to FastAPI:

    ```bash
        curl --location --request POST 'http://localhost:9180/apisix/admin/routes' \
        --header 'Content-Type: application/json' \
        --header "X-API-KEY: a3b7d5e812c49f6038e2ab91f4d6c7e5" \
        --data-raw '{
            "name": "fast-api-serivice",
            "uri": "/service/*",
            "upstream_id": "<UPSTREAM_ID>",
            "plugins": {
                "proxy-rewrite": {
                    "regex_uri": ["^/service/(.*)", "/$1"]
                },
                "openid-connect": {
                    "client_id": "apisix",
                    "client_secret": "<CLIENT_SECRET>",
                    "discovery": "http://keycloak:8080/realms/apisix_test_realm/.well-known/openid-configuration",
                    "realm": "apisix_test_realm",
                    "bearer_only": true,
                    "use_jwks": true
                }
            }
        }'
    ```

## 🛠 Testing

1. Obtain a Keycloak token:

    ```bash
        ACCESS_TOKEN=$(curl --location 'http://localhost:8080/realms/apisix_test_realm/protocol/openid-connect/token' \
        --header 'Content-Type: application/x-www-form-urlencoded' \
        --data-urlencode 'grant_type=password' \
        --data-urlencode 'client_id=apisix' \
        --data-urlencode 'client_secret=<CLIENT_SECRET>' \
        --data-urlencode 'username=user' \
        --data-urlencode 'password=<USER_SECRET>' \
        --data-urlencode 'scope=openid' | jq -r .access_token)
    ```

2. Call the API through APISIX:

    ```bash
        curl --location 'http://localhost:9080/service/hello' --header "Authorization: Bearer $ACCESS_TOKEN"
    ```
