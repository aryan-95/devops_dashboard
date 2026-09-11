# Viva Questions & Answers

**1. What is DevOps?**
A set of practices that unifies software development and IT operations, emphasizing automation, continuous delivery, and collaboration to ship software faster and more reliably.

**2. What is CI/CD?**
Continuous Integration automatically tests and merges code changes frequently; Continuous Deployment/Delivery automatically ships those changes to an environment. Here, GitHub → CodePipeline → CodeBuild implements both.

**3. Why Terraform instead of manual console clicks?**
Terraform gives version-controlled, repeatable, reviewable infrastructure. The exact same `.tf` files can recreate the entire environment, eliminating manual configuration drift.

**4. What is Infrastructure as Code (IaC)?**
Defining infrastructure (networks, servers, databases) in machine-readable configuration files rather than manual setup, so it can be versioned, tested, and reproduced.

**5. What is immutable infrastructure?**
Once a server is deployed, it is never modified in place. To change anything, you build and deploy a new instance and destroy the old one. This project achieves it via Launch Templates + ASG Instance Refresh.

**6. Why use an Application Load Balancer (ALB)?**
It distributes incoming traffic across multiple healthy EC2 instances, performs health checks, and enables zero-touch failover when an instance goes down.

**7. Why use Auto Scaling?**
It automatically adjusts the number of running instances based on demand (CPU utilization here), and automatically replaces unhealthy instances — giving both elasticity and fault tolerance.

**8. Why deploy across multiple Availability Zones?**
An Availability Zone is an isolated AWS data center. Spreading instances across two AZs means a single data-center-level failure doesn't take down the whole application.

**9. What happens when an EC2 instance fails?**
The ALB's health check to `/health` starts failing; after 2 consecutive failures the target is marked unhealthy and removed from rotation. The ASG detects the unhealthy instance, terminates it, and launches a replacement from the Launch Template.

**10. Why is RDS kept private (not publicly accessible)?**
To minimize the attack surface — a public database is a direct target for attackers. Only the application tier's security group is permitted to reach it on port 3306.

**11. What is a security group?**
A stateful virtual firewall attached to AWS resources that controls inbound/outbound traffic by port, protocol, and source/destination.

**12. What is IAM?**
AWS Identity and Access Management — controls who (or what service) can do what to which AWS resources, following the principle of least privilege.

**13. What is a Launch Template?**
A reusable, versioned blueprint (AMI, instance type, security groups, user-data) that the Auto Scaling Group uses to launch new EC2 instances consistently.

**14. What is a Target Group?**
A logical grouping of instances that the ALB routes traffic to and health-checks; the ASG automatically registers new instances into it.

**15. What is health checking, and how is it configured here?**
Periodic HTTP requests (here, `GET /health` every 15s) used to verify an instance is actually serving traffic correctly, not just "running."

**16. What is a rolling deployment?**
Replacing instances gradually (e.g., 50% at a time) rather than all at once, so the application keeps serving traffic throughout the deployment.

**17. How does AWS CodePipeline work here?**
It orchestrates three stages: Source (pulls code from GitHub via a CodeStar Connection whenever `main` changes), Build (runs CodeBuild to test/package), and Deploy (runs CodeBuild again to trigger a rolling ASG instance refresh).

**18. What does AWS CodeBuild do?**
Executes the steps defined in `buildspec.yml` — installing dependencies, running the pytest suite, validating the app, and producing a deployment artifact — inside a managed, ephemeral build container.

**19. What is Git branching, and what workflow is used here?**
Branching lets multiple people work in isolation. This project uses `main` → `develop` → `feature/*` branches; feature branches are merged via Pull Request into `main`, which triggers the pipeline.

**20. What are the six AWS Well-Architected pillars?**
Operational Excellence, Security, Reliability, Performance Efficiency, Cost Optimization, and Sustainability.

**21. Why use CloudWatch?**
For observability — collecting metrics (CPU, latency, error counts), logs (app and boot logs), and alarms that notify (via SNS) when thresholds are breached, enabling proactive operations.

**22. How does the architecture scale?**
Horizontally: the ASG's target-tracking policy adds EC2 instances when average CPU exceeds 60%, up to a max of 4, and scales back in when load drops, down to a minimum of 2.

**23. How are database credentials protected?**
Terraform generates a random password, stores it as a `SecureString` in SSM Parameter Store, and EC2 instances retrieve it at boot using their IAM instance profile — never hardcoded in code or Terraform files.

**24. What is the difference between a public and private subnet?**
A public subnet has a route to an Internet Gateway (directly reachable from the internet); a private subnet does not — it can only reach the internet outbound via a NAT Gateway, and nothing can initiate an inbound connection from the internet.

**25. Why is a NAT Gateway needed?**
It lets instances in private subnets (the app tier) make outbound requests — e.g., to `git clone` from GitHub or install packages — without exposing them to inbound internet traffic.

**26. What is the purpose of the `user_data.sh` script?**
It bootstraps a brand-new EC2 instance automatically at boot: installs dependencies, pulls the latest application code, fetches DB credentials from SSM, and starts the app as a systemd service — implementing immutable, repeatable deployment.

**27. Why Gunicorn instead of Flask's built-in server?**
Flask's development server is single-threaded and not meant for production; Gunicorn is a production-grade WSGI server that manages multiple worker processes for real traffic.

**28. What's stored in the RDS MySQL database?**
A `deployments` table (version, environment, status, deployed_at) and a `health_checks` table (instance_id, status, checked_at), demonstrating real database connectivity from the app tier.

**29. How would you achieve true zero-downtime deployment?**
By keeping at least one healthy instance in rotation at all times during deployment (via rolling replacement with a minimum healthy percentage), combined with ALB connection draining — which this project implements, while being careful to describe it as "designed for minimal disruption" rather than a guaranteed SLA.

**30. What would you monitor to know the system is unhealthy before users notice?**
CloudWatch alarms on unhealthy target count, 5xx error rate, and target response time — all configured in `cloudwatch.tf` — catch degradation before it becomes a full outage.

**31. Why keep the Terraform structure flat instead of heavily modularized?**
For a project of this scope, flat `.tf` files organized by resource type (vpc.tf, alb.tf, rds.tf, etc.) are easier to read, explain, and review than deeply nested modules — modularization pays off at much larger scale.

**32. How do you tear down the environment to avoid charges?**
`terraform destroy` from the `terraform/` directory removes every resource Terraform created, in dependency order.
