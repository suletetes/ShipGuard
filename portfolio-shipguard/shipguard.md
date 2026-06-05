# ShipGuard

## Zero-downtime deployment platform with security gates

![ShipGuard Architecture](shipguard-architecture.png)

## Summary

I built ShipGuard to solve a problem I kept seeing: deployments that either require manual babysitting or fail silently until users complain. ShipGuard is a complete AWS CI/CD pipeline that deploys code to production using blue/green with canary traffic shifting, and rolls back automatically if errors spike. No human intervention needed for the rollback, just a CloudWatch alarm and CodeDeploy doing its job.

## What I built

A five-stage CodePipeline that takes code from GitHub all the way to production:

- Security scanning (npm audit, Trivy, git-secrets) blocks the build if high/critical vulnerabilities are found
- Staging deployment with health validation before anything touches production
- Manual approval gate so a human signs off after verifying staging
- Blue/green production deployment: 10% of traffic goes to the new version first, then the rest follows if no errors
- Automatic rollback triggered by a CloudWatch alarm monitoring 5xx error rate

The entire infrastructure is defined in three CloudFormation templates. Nothing is click-ops.

## Technical decisions

**Why blue/green instead of rolling updates?** Rolling updates still drop connections during instance replacement. Blue/green with an ALB gives you true zero downtime because the old instances keep serving until traffic fully shifts.

**Why canary instead of all-at-once traffic shift?** If the new version has a bug that only shows up under real traffic, canary catches it when only 10% of users are affected. All-at-once means everyone gets the broken version simultaneously.

**Why CloudWatch alarm for rollback instead of custom logic?** CodeDeploy has native alarm integration. When the alarm fires, CodeDeploy handles the rollback without any custom code. Less code means fewer things to break.

**Why separate stacks per environment?** Independent lifecycle management. I can tear down staging without touching production, and a bad template change to one environment doesn't cascade.

## Tech stack

- AWS CodePipeline, CodeBuild, CodeDeploy
- Application Load Balancer with dual target groups
- EC2 Auto Scaling Groups
- CloudWatch Alarms
- SNS for notifications
- CloudFormation (infrastructure as code)
- TypeScript/Express (the deployed application)

## What I learned

Writing the CodeDeploy blue/green configuration taught me how traffic routing actually works at the ALB level. The TimeBasedCanary deployment config only supports a single canary step natively (10% then the rest), so getting the 10% → 50% → 100% pattern I originally wanted required understanding the limitations of the service and designing around them.

The IAM role chain was the trickiest part. CodePipeline needs to assume CodeBuild's role, which needs S3 access, which needs to match the bucket policy. Getting the trust relationships right across four service roles took iteration.

## Links

- [GitHub Repository](https://github.com/suletetes/ShipGuard)
