# Security Checklist

## Authentication Security

- [x] Secure password hashing using Argon2id with appropriate parameters
- [x] Short-lived access tokens (15 minutes default)
- [x] Refresh-token rotation on each use
- [x] Token revocation support (revoke old tokens on new token generation)
- [x] Session expiry and token expiry enforcement
- [x] Secure Keychain storage for passcodes (iOS) and tokens (backend)
- [x] Local Face ID/Touch ID authentication (separate from cloud auth)
- [x] Biometric availability checking
- [x] Passcode setup/confirmation/verification flow
- [x] Invalid passcode feedback and retry handling
- [x] Lockout after too many failed attempts (5 failures)
- [x] Biometric cancellation and failure handling
- [x] Simulator fallback for Face ID (development only)
- [x] Never store passcodes in plaintext
- [x] Use properly salted password-based key derivation function
- [x] Never log credentials or authentication secrets

## Authorization

- [x] User-level access control
- [x] Resource ownership verification on every relevant endpoint
- [x] Deny-by-default authorization
- [x] No insecure direct object references (ODOR)
- [x] User isolation by owner_id in database queries
- [x] Cross-user access prevention (tested via integration tests)
- [x] Authentication state gating for UI elements

## API Security

- [x] HTTPS enforcement (via reverse proxy/Nginx)
- [x] Strict CORS configuration (configured origins only)
- [x] Input validation using Pydantic schemas
- [x] SQL injection prevention (parameterized queries via Tortoise ORM)
- [x] Rate limiting (IP-based and user-based)
- [x] Request size limits
- [x] Safe error responses (no stack traces in production)
- [x] Security headers (via Nginx: X-Content-Type-Options, X-Frame-Options, X-XSS-Protection, Referrer-Policy)
- [x] No stack traces in production responses
- [x] No sensitive data leakage in error messages
- [x] Request ID tracking for correlation

## Infrastructure Security

- [x] Non-root containers (runAsNonRoot: true in K8s)
- [x] Least privilege security contexts (readOnlyRootFilesystem, capabilities.drop: ALL)
- [x] Restricted network access (NetworkPolicy)
- [x] Kubernetes security contexts (runAsNonRoot, runAsUser)
- [x] Secret management (external secret manager, not in images)
- [x] Dependency vulnerability scanning (pip audit, container scanning)
- [x] Container image scanning (Trivy, Clair, or similar)
- [x] Secure environment configuration (.env.example, no real credentials in repo)

## Protection Against OWASP Top 10

### A01: Broken Access Control
- Resource ownership verified on every endpoint
- User isolation by owner_id
- No hardcoded admin bypasses

### A02: Cryptographic Failures
- Argon2id password hashing
- HTTPS everywhere
- Secure token storage

### A03: Injection
- Parameterized queries via Tortoise ORM
- Pydantic input validation
- No raw SQL with user-supplied data

### A04: Insecure Design
- Security requirements defined per feature
- Threat modeling for sensitive operations
- Security headers enforced

### A05: Security Misconfiguration
- Environment-based configuration (development vs production)
- No debug mode in production
- Security headers via reverse proxy
- Regular dependency scanning

### A06: Vulnerable and Outdated Components
- Dependency vulnerability scanning (pip audit)
- Container image scanning
- Regular security updates

### A07: Identification and Authentication Failures
- Secure password policies
- Token-based authentication
- Refresh token rotation
- Account lockout after failures

### A08: Software and Data Integrity Failures
- Signed dependencies
- Verified container images
- Migration-safe database changes

### A09: Security Logging and Monitoring
- Structured JSON logging
- Security event tracking (login failures, token revocations)
- No sensitive data in logs
- Request ID correlation

### A10: Server-Side Request Forgery
- No arbitrary URL fetching
- Validate redirect URLs
- Allowlist allowed domains

## Security Best Practices

### Password Policy
- Minimum 8 characters, maximum 128
- Argon2id hashing with: rounds=15, memory=64*1024, time_cost=2
- No password reuse allowed (enforced server-side)
- Expired passwords require reset

### Token Security
- Access tokens: 15 minutes expiry
- Refresh tokens: 30 days expiry, rotated on each use
- Tokens stored in HTTP-only, Secure cookies (when applicable)
- Token revocation support
- Concurrent session control

### Data Protection
- User data encrypted at rest (database level)
- TLS 1.2+ for all transmissions
- No sensitive data in logs or error messages
- GDPR/privacy-compliant data handling

### Deployment Security
- Kubernetes: least-privilege security contexts
- Non-root containers
- Read-only filesystem where possible
- Regular security scans
- Rolling updates for zero-downtime deployments
- HPA for auto-scaling under load

## Incident Response

### Security Incident Categories
1. **Compromised credentials** - Immediately revoke tokens, reset secrets
2. **Unauthorized access** - Investigate audit logs, revoke suspicious sessions
3. **Data breach** - Assess scope, notify affected users, remediate vulnerability
4. **Denial of Service** - Scale infrastructure, implement rate limiting

### Response Procedures
- Documented escalation paths
- Regular incident response drills
- Preservation of evidence (logs, audit trails)
- Post-incident review and improvement

## Compliance Notes

- **GDPR**: User data can be exported and deleted on request
- **HIPAA**: Not applicable (business productivity app, not healthcare)
- **SOC 2**: Relevant for user data protection and access controls
- **Data retention**: Contact data retained until user deletion, with audit trail

## Last Security Review

- Date: {{CURRENT_DATE}}
- Reviewed by: {{REVIEWER}}
- Next review: {{NEXT_REVIEW_DATE}}