---
title: CORS Fails Silently with credentials:include
date: 2025-01-15
tags: [gotchas, cors, fetch-api]
related: []
---

# CORS Fails Silently with credentials:include

Fetch requests with `credentials: "include"` fail silently when the server responds with `Access-Control-Allow-Origin: *` — the wildcard is not allowed with credentials.

## Context

API calls from the frontend worked in development (same-origin) but failed in staging (cross-origin). No error appeared in the network tab response — the browser just blocked it. Console showed:

```
Access to fetch at 'https://api.staging.example.com/users' from origin
'https://app.staging.example.com' has been blocked by CORS policy:
The value of the 'Access-Control-Allow-Origin' header in the response
must not be the wildcard '*' when the request's credentials mode is 'include'.
```

## Solution

The server must echo back the specific requesting origin, not `*`:

```nginx
# nginx.conf — WRONG
add_header Access-Control-Allow-Origin *;

# nginx.conf — CORRECT
add_header Access-Control-Allow-Origin $http_origin;
add_header Access-Control-Allow-Credentials true;
```

Also required: `Access-Control-Allow-Credentials: true` must be present.

## Key Takeaway

When using `credentials: "include"` (cookies, auth headers), the CORS response **must** specify the exact origin and include `Allow-Credentials: true`. The `*` wildcard is explicitly forbidden by the spec in this mode. This applies to both `fetch()` and `XMLHttpRequest.withCredentials`.
