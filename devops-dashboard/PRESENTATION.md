# Presentation Script (7–10 minutes)

Tip: keep the AWS Console open in one tab, the live dashboard URL in another, and this script alongside on a second screen or printed.

---

### Slide 1 — Project Title
**Show:** Title slide — "Highly Available Three-Tier Web Application with Automated CI/CD and Infrastructure as Code on AWS"
**Say:** "This project builds a real, production-style AWS deployment — not a toy demo — to demonstrate the full DevOps lifecycle: infrastructure as code, CI/CD automation, and high availability."
**Terms:** Three-tier architecture, DevOps lifecycle, Infrastructure as Code.
**Possible question:** "Why three-tier?" → Separates presentation, application, and data concerns so each can scale and fail independently.

### Slide 2 — Problem Statement
**Show:** Bullet list of what a typical single-server student project lacks.
**Say:** "Most student projects run on one server with no redundancy and manual deployment. This project instead shows what a real engineering team ships: multi-AZ compute, automated pipelines, and monitoring."
**Terms:** Single point of failure, manual deployment risk.

### Slide 3 — Architecture
**Show:** The Mermaid architecture diagram from the README.
**Say:** "Traffic enters through an Application Load Balancer in public subnets, is routed to Flask application servers in private subnets across two Availability Zones, which talk to a private RDS MySQL database. Nothing in the app or database tier is reachable directly from the internet."
**Terms:** VPC, public/private subnets, Availability Zone.
**Possible question:** "Why keep RDS private?" → Reduces attack surface; only the app tier's security group can reach port 3306.

### Slide 4 — Three-Tier Design
**Show:** The tier table (Presentation / Application / Database).
**Say:** "Tier 1 is the ALB. Tier 2 is Flask + Gunicorn running on EC2 inside an Auto Scaling Group. Tier 3 is RDS MySQL. Each tier has its own security group enforcing least-privilege access to the tier below it."
**Terms:** Security group, least privilege.

### Slide 5 — High Availability
**Show:** ASG console: 2 instances across 2 AZs, ALB target group healthy.
**Say:** "We run a minimum of two instances split across two Availability Zones. The ALB health-checks `/health` every 15 seconds. If an instance fails, the ALB stops sending it traffic and the Auto Scaling Group replaces it automatically — no human involved."
**Terms:** Health check, fault tolerance, multi-AZ.
**Possible question:** "What if an entire AZ goes down?" → The other AZ's instance keeps serving traffic; ASG can launch replacements in the surviving AZ.

### Slide 6 — CI/CD Pipeline
**Show:** CodePipeline console with Source → Build → Deploy stages.
**Say:** "A push to the `main` branch on GitHub automatically triggers CodePipeline. CodeBuild installs dependencies, runs our pytest suite, and packages the app. A second CodeBuild stage then triggers a rolling instance refresh to deploy it."
**Terms:** Continuous Integration, Continuous Deployment, buildspec.

### Slide 7 — Infrastructure as Code + Immutable Infrastructure
**Show:** `terraform plan` output or the `terraform/` folder structure.
**Say:** "Every AWS resource — VPC, ALB, ASG, RDS, IAM roles, CloudWatch alarms — is defined in Terraform, version-controlled, and reproducible with `terraform apply`. We never modify a running server; every deployment replaces instances with fresh ones built from the same launch template."
**Terms:** Infrastructure as Code, immutable infrastructure, Launch Template.
**Possible question:** "What's the difference between mutable and immutable infrastructure?" → Mutable = patch servers in place (config drift risk); immutable = replace with a new, identically-built instance every time.

### Slide 8 — Auto Scaling + Fault Tolerance
**Show:** CloudWatch CPU metric graph and the target-tracking scaling policy.
**Say:** "Auto Scaling uses target tracking on CPU utilization, targeting 60%. Under load it adds instances up to 4; when load drops it scales back to a minimum of 2, keeping cost efficient without sacrificing availability."
**Terms:** Target tracking, scaling policy.

### Slide 9 — Monitoring + Well-Architected
**Show:** CloudWatch alarms list; Well-Architected pillar table from the README.
**Say:** "CloudWatch tracks CPU, unhealthy hosts, 5xx errors, and latency, alarming through SNS. We map every design decision back to the six AWS Well-Architected pillars — for example, private subnets and IAM least-privilege satisfy the Security pillar."
**Terms:** CloudWatch alarm, SNS, Well-Architected Framework.

### Slide 10 — Live Demo
**Show:** Follow the 14-step demonstration in the README section 16.
**Say (while doing it):** "Here's the dashboard live... now I'll push a small change to GitHub... watch CodePipeline pick it up automatically... now I'll deliberately terminate one EC2 instance to prove fault tolerance... watch the ALB mark it unhealthy and Auto Scaling replace it, while the site keeps responding the whole time."

### Slide 11 — Results / Benefits
**Show:** Summary bullets: zero manual server changes, automated recovery, automated deployment, full observability.
**Say:** "The result is a system that deploys itself, heals itself, and reports its own health — the core promise of DevOps automation."

### Slide 12 — Conclusion
**Show:** Recap diagram: Developer → Git → CI/CD → Immutable Infra → HA compute → Monitoring.
**Say:** "This project demonstrates that DevOps isn't just tooling — it's a discipline of automation, repeatability, and resilience, applied end-to-end on real AWS infrastructure."

---

**Closing line for questions:** "Happy to open the Terraform code, the pipeline, or trigger the failure demo again if anyone wants to see a specific part in more detail."
