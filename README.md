# Easy Job Getter

A minimal AWS Lambda function that creates up to five commits per weekday at 5:15 PM UTC. This solution uses the Serverless Framework and a standard Alpine container image for a lightweight deployment.

NOTE: This as a joke, albeit one that uses real life DevOps skills. I want to mock influencers that say that you should have a visible Github profile with many contributions to hire you. But this can be faked. So let's create such a thing that uses AWS Lambda, Serverless, some bash scripting and patience. Up to five commits per day, every day! You got this!

## Prerequisites

- [Node.js](https://nodejs.org/) (for Serverless Framework)
- [Serverless Framework](https://www.serverless.com/)
- [Docker](https://www.docker.com/) installed and running
- An AWS account with configured credentials
- AWS CLI with access to create ECR repositories

## Setup

1. Create a dedicated repository for fake commits:
   - Create a new empty repository on your Git provider (GitHub, GitLab, Bitbucket, etc.)
   - Initialize it with a README or any initial file
   - Copy the SSH URL of your repository (e.g., `git@github.com:username/fake-commits.git`)

2. Clone or download this project:
   ```
   git clone git@github.com/kiinoda/job_getter
   cd job_getter
   ```

3. Install Serverless Framework if you haven't already:
   ```
   npm install -g serverless
   ```

4. Edit `serverless.yml` to update the hardcoded values:
   ```yaml
   environment:
     GIT_COMMITTER_EMAIL: "your-email@example.com"  # Change this
     REPO_URL: "git@github.com:username/fake-commits.git"  # Change this to your repo URL
   ```

5. Create a dedicated SSH key for this Lambda function:
   ```
   # Generate a new Ed25519 SSH key without passphrase
   ssh-keygen -t ed25519 -f ./id_ed25519 -N ""
   
   # Display the public key
   cat ./id_ed25519.pub
   ```
   
   Copy the displayed public key and add it to your repository as a deploy key with write access.

6. Deploy the Lambda function:
   ```
   serverless deploy
   ```
   
   Note: The first deployment will create an ECR repository and upload a container image. This may take a few minutes.

## How It Works

1. The Serverless Framework:
   - Creates an ECR repository for your container image
   - Builds and pushes a standard Alpine-based Docker image (only ~25MB) with Git pre-installed
   - Creates a Lambda function using the container image
   - Sets up an IAM role with necessary permissions
   - Creates a CloudWatch Events rule for scheduling
   - Configures permissions for CloudWatch Events to invoke the Lambda

2. The Lambda function is triggered every weekday at 5:15 PM UTC and:
   - Uses the pre-installed Git in the Alpine container
   - Clones your repository
   - Creates a random text file
   - Commits and pushes the changes
   - Cleans up after itself

## Customizing Configuration

### Modifying the Schedule

You can change when commits happen by editing the `schedule` in serverless.yml:

```yaml
events:
  - schedule: cron(15 17 ? * MON-FRI *)  # 5:15 PM UTC on weekdays
```

The cron format is: `cron(minutes hours day-of-month month day-of-week year)`.

Common examples:
- Every day at 10am UTC: `cron(0 10 * * ? *)`
- Weekends at noon UTC: `cron(0 12 ? * SAT-SUN *)`
- Every hour on weekdays: `cron(0 * ? * MON-FRI *)`

## Security Considerations

- Always use a dedicated SSH key for this Lambda function
- Limit the key's access to only the specific repository needed
- Use repository deploy keys (not personal account keys) whenever possible
- Ed25519 keys provide better security than older RSA or DSA keys
- For improved security, you can use AWS Secrets Manager instead:
  ```
  # Store the SSH key in Secrets Manager
  aws secretsmanager create-secret --name GitSSHKey --secret-string "$(cat id_ed25519)"
  ```
  Then modify your Lambda to retrieve the key from Secrets Manager.

## Testing Locally

You can test the bootstrap script locally using Docker:

```bash
# Build the Docker image
docker build -t fake-commit-lambda .

# Run the container with your environment variables
docker run -it --rm \
  -e GIT_COMMITTER_NAME="Fake Committer" \
  -e GIT_COMMITTER_EMAIL="your-email@example.com" \
  -e REPO_URL="git@github.com:username/fake-commits.git" \
  fake-commit-lambda \
  invoke '{"source":"aws.events","detail-type":"Scheduled Event"}'
```

## Deployment Commands

- To deploy:
  ```
  serverless deploy
  ```

- To update after making changes:
  ```
  serverless deploy
  ```

- To invoke the function manually:
  ```
  serverless invoke -f fakeCommit
  ```

- To view logs:
  ```
  serverless logs -f fakeCommit
  ```

- To remove all resources:
  ```
  serverless remove
  ```
