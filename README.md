First of all, I wanted to thank you for the opportunity — I really enjoyed this challenge!
I should mention that I had some AWS credits, so I ran a quick test on EKS (using a single very small node for a short time) which didn't cost anything :)
The Terraform and chart deployment sections will be commented out, but they have been fully tested and are working.

This document describes what I did and some of the choices I made for a monorepo containing both Terraform and the application code.

## Terraform
For the infrastructure I used two separate Terraform stacks. The first is the bootstrap, which takes care of creating all the base components. Although it's not best practice, I used my root account to create the TF state bucket, a service account and the OIDC provider. I'm a big fan of OIDC — no tokens or keys to manage, you just assign the necessary permissions and bind everything to a GitHub repository.
After setting everything up I migrated the TF state to the bucket.
For the TF state bucket I added a bucket policy that restricts access exclusively to the Terraform user and the GitHub Actions OIDC role, so even if someone obtained the bucket ARN they wouldn't be able to access the state.

I then worked on the API infrastructure, using the OIDC-configured user for the apply.
To allow pods to communicate with AWS services (DynamoDB and S3) I used IRSA (IAM Roles for Service Accounts), which lets you bind an IAM Role directly to a Kubernetes Service Account without managing static credentials — the pod assumes the role through the EKS cluster's OIDC provider.

### Terraform Pipeline
Since the same repository contains two Terraform stacks, I set up the pipelines so that pushes go to the develop branch, a PR is opened, and a job kicks off to detect which stack was modified (it can be both, although the bootstrap changes rarely). If the plan succeeds, the PR is merged and the Terraform apply runs.

## API Server
I used the existing code with very few changes:
1) Added a health check endpoint for the liveness and readiness probes
2) Since we use a Service Account to communicate with internal AWS services, I removed the static key authentication
3) Various changes to user_service.py

Those are the only changes made.

### Dockerfile
Not much to say here — it's a Flask app using Poetry as the package manager and the Dockerfile is fairly standard.

### Helm Chart
I created the chart using `helm create api`, which gives a solid set of default files to start from.
On top of `values.yaml` I always add an override file — in this case `values-prd.yaml` — containing only the parameters that differ in production: HPA, PDB, env vars, Service Account and resource limits.

### EKS
I was a bit behind on EKS and things have changed, especially around authentication — it no longer relies solely on the ConfigMap but now integrates with IAM. I took the opportunity to try it out, which cost me a few extra commits!
For the ingress controller I created a Makefile with the commands to run.
I usually manage the ingress controller, ELK, Prometheus, Grafana, Istio and similar components with a Makefile that pins specific versions, so they stay consistent across environments.
These components change very rarely once installed, so I've always found Make a practical way to handle them.

## Release
For the application, every push to develop triggers a pipeline that builds and pushes the Docker image using the commit SHA as the tag.
When it's time to promote to production, a tag/release is created on the develop branch and a PR is opened from develop to main. This triggers a build job that tags the Docker image with the release tag.
When the PR is opened, a job runs `helm diff` to show exactly what will change (typically the image tag, and potentially secrets or ConfigMaps). Once everything looks good, the PR is merged and `helm upgrade` is triggered.

## Infrastructure Cleanup
Once the review is complete, all AWS infrastructure was destroyed using a manual GitHub Actions pipeline (`terraform-destroy.yml`) that supports selective or full teardown, requiring an explicit `DESTROY` confirmation to prevent accidental runs.

```
~ $ curl -i -X POST http://k8s-producti-primaapi-68f93b86fb-1173729742.eu-south-1.elb.amazonaws.com/user \
>      -F "name=d3p4rt" \
>      -F "email=d3p4rt@protonmail.com" \
>      -F "avatar=@avatar.png"
HTTP/1.1 201 CREATED
Date: Mon, 04 May 2026 21:42:10 GMT
Content-Type: application/json
Content-Length: 27
Connection: keep-alive
Server: Werkzeug/3.0.3 Python/3.11.15

{"success":"User created"}


~ $ aws s3 ls s3://prima-tech-challenge-40-avatars --recursive
2026-05-04 21:42:11          5 avatar.png


~ $ curl -i -X GET http://k8s-producti-primaapi-68f93b86fb-1173729742.eu-south-1.elb.amazonaws.com/users
HTTP/1.1 200 OK
Date: Mon, 04 May 2026 21:43:37 GMT
Content-Type: application/json
Content-Length: 146
Connection: keep-alive
Server: Werkzeug/3.0.3 Python/3.11.15

[{"avatar_url":"https://prima-tech-challenge-40-avatars.s3.eu-south-1.amazonaws.com/avatar.png","email":"d3p4rt@protonmail.com","name":"d3p4rt"}]

```

## Final Thoughts
I tested the full flow end to end and the API server behaves as expected.

I've kept this description brief to avoid going into too much detail — if you decide to move forward I'd be happy to answer any questions about the challenge during the interview!

### Disclaimer
I intentionally left in a few errors and typos caused by tiredness during commits and pipeline runs. I think it's also valuable to show how you recover from mistakes, rather than presenting only a polished final result.

Thank you again for the opportunity.

Davide Quaranta aka D3p4rt on GitHub


![Avatar](https://avatars.githubusercontent.com/u/52236879?s=400&u=5919ba5028342ad4676bfc4200d7ddfb527c0ef5&v=4)