# template

This project is a Nuxt.js application with a Docker-based blue/green deployment setup.

## Development

To run the application in a development environment, use the following commands:

1.  **Start the environment:**
    ```bash
    make dev-up
    ```
    This will start the Nuxt.js development server with hot-reloading.

2.  **Stop the environment:**
    ```bash
    make dev-down
    ```

The application will be available at [http://localhost](http://localhost).

## Staging Environment

The staging environment uses a blue/green deployment strategy.

### Initial Setup

1.  **Start the environment:**
    ```bash
    make staging-up
    ```
    This will build the Docker images, start the containers, and set up the initial Nginx configuration to point to the "blue" environment.

### Deployment Workflow

1.  **Deploy a new version:**
    ```bash
    make staging-deploy
    ```
    This will deploy the new code to the inactive environment (e.g., "green" if "blue" is active).

2.  **Verify the deployment:**
    ```bash
    make staging-verify
    ```
    This will show the logs of the newly deployed instance, allowing you to check for errors and manually verify its functionality.

3.  **Switch to the new version:**
    ```bash
    make staging-switch
    ```
    This will switch the Nginx proxy to point to the newly deployed environment.

4.  **Clean up the old environment:**
    ```bash
    make staging-clean
    ```
    This will stop the container of the previous environment to save resources.

### Other Commands

*   **Check status:**
    ```bash
    make staging-status
    ```
    This shows which environment ("blue" or "green") is currently active.

*   **Rollback:**
    ```bash
    make staging-rollback
    ```
    This will switch Nginx back to the previous environment if something goes wrong.

*   **Stop the environment:**
    ```bash
    make staging-down
    ```

## Production Environment

The production environment follows the same blue/green deployment process as staging.

### Initial Setup

1.  **Start the environment:**
    ```bash
    make prod-up
    ```

### Deployment Workflow

1.  **Deploy a new version:**
    ```bash
    make prod-deploy
    ```

2.  **Verify the deployment:**
    ```bash
    make prod-verify
    ```

3.  **Switch to the new version:**
    ```bash
    make prod-switch
    ```

4.  **Clean up the old environment:**
    ```bash
    make prod-clean
    ```

### Other Commands

*   **Check status:**
    ```bash
    make prod-status
    ```

*   **Rollback:**
    ```bash
    make prod-rollback
    ```

*   **Stop the environment:**
    ```bash
    make prod-down
    ```
