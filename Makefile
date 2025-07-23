
# Makefile for multi-environment deployments

.DEFAULT_GOAL := help

# Variables
STAGING_BLUE_CONF = nginx/staging-blue.conf
STAGING_GREEN_CONF = nginx/staging-green.conf
STAGING_ENABLED_CONF = nginx/staging.conf

PROD_BLUE_CONF = nginx/prod-blue.conf
PROD_GREEN_CONF = nginx/prod-green.conf
PROD_ENABLED_CONF = nginx/prod.conf

# --- Development Environment ---
dev-up: ## Start the development environment
	@echo "Starting development environment..."
	@docker-compose -f docker-compose.dev.yml up -d --build

dev-down: ## Stop the development environment
	@echo "Stopping development environment..."
	@docker-compose -f docker-compose.dev.yml down

# --- Staging Environment ---
staging-up: ## Start the staging environment
	@echo "Starting staging environment..."
	@mkdir -p nginx/sites-enabled
	@rm -f $(STAGING_ENABLED_CONF) && cp nginx/sites-available/staging-blue.conf $(STAGING_ENABLED_CONF)
	@docker-compose -f docker-compose.staging.yml up -d --build

staging-down: ## Stop the staging environment
	@echo "Stopping staging environment..."
	@docker-compose -f docker-compose.staging.yml down

staging-deploy: ## Deploy a new version to the inactive staging environment
	@if [ -L $(STAGING_ENABLED_CONF) ] && [ "$(shell readlink $(STAGING_ENABLED_CONF))" = "$(STAGING_BLUE_CONF)" ]; then \
		echo "Deploying to green"; \
		docker-compose -f docker-compose.staging.yml build app-green; \
		docker-compose -f docker-compose.staging.yml up -d app-green; \
	else \
		echo "Deploying to blue"; \
		docker-compose -f docker-compose.staging.yml build app-blue; \
		docker-compose -f docker-compose.staging.yml up -d app-blue; \
	fi

staging-switch: ## Switch the Nginx proxy to the new version in staging
	@if [ -L $(STAGING_ENABLED_CONF) ] && [ "$(shell readlink $(STAGING_ENABLED_CONF))" = "$(STAGING_BLUE_CONF)" ]; then \
		echo "Switching to green"; \
		cp $(STAGING_GREEN_CONF) $(STAGING_ENABLED_CONF); \
	else \
		echo "Switching to blue"; \
		cp $(STAGING_BLUE_CONF) $(STAGING_ENABLED_CONF); \
	fi
	@docker-compose -f docker-compose.staging.yml restart nginx

staging-rollback: ## Switch back to the previous version in staging
	@if [ -L $(STAGING_ENABLED_CONF) ] && [ "$(shell readlink $(STAGING_ENABLED_CONF))" = "$(STAGING_BLUE_CONF)" ]; then \
		echo "Rolling back to green"; \
		cp $(STAGING_GREEN_CONF) $(STAGING_ENABLED_CONF); \
    else \
        echo "Rolling back to blue"; \
        cp $(STAGING_BLUE_CONF) $(STAGING_ENABLED_CONF); \
	fi
	@docker-compose -f docker-compose.staging.yml restart nginx

staging-clean: ## Shut down the inactive blue or green instance in staging
	@if [ -L $(STAGING_ENABLED_CONF) ] && [ "$(shell readlink $(STAGING_ENABLED_CONF))" = "$(STAGING_BLUE_CONF)" ]; then \
		echo "Cleaning up green"; \
		docker-compose -f docker-compose.staging.yml stop app-green; \
	else \
		echo "Cleaning up blue"; \
		docker-compose -f docker-compose.staging.yml stop app-blue; \
	fi



staging-status: ## Checks the current active environment in staging
	@if [ -L $(STAGING_ENABLED_CONF) ]; then \
		echo "Staging is currently pointing to: $(shell readlink $(STAGING_ENABLED_CONF))"; \
	else \
		echo "Staging is not configured"; \
	fi

staging-verify: ## Verify the newly deployed staging instance
	@if [ -L $(STAGING_ENABLED_CONF) ] && [ "$(shell readlink $(STAGING_ENABLED_CONF))" = "$(STAGING_BLUE_CONF)" ]; then \
		echo "Verifying green instance (port 3002). Check logs below:";         docker-compose -f docker-compose.staging.yml logs app-green;     else         echo "Verifying blue instance (port 3001). Check logs below:";         docker-compose -f docker-compose.staging.yml logs app-blue;     fi

# --- Production Environment ---

prod-up: ## Start the production environment
	@echo "Starting production environment..."
	@mkdir -p nginx/sites-enabled
	@rm -f $(PROD_ENABLED_CONF) && cp nginx/sites-available/prod-blue.conf $(PROD_ENABLED_CONF)
	@docker-compose -f docker-compose.prod.yml up -d --build

prod-down: ## Stop the production environment
	@echo "Stopping production environment..."
	@docker-compose -f docker-compose.prod.yml down

prod-deploy: ## Deploy a new version to the inactive production environment
	@if [ -L $(PROD_ENABLED_CONF) ] && [ "$(shell readlink $(PROD_ENABLED_CONF))" = "$(PROD_BLUE_CONF)" ]; then \
		echo "Deploying to green"; \
		docker-compose -f docker-compose.prod.yml build app-green; \
		docker-compose -f docker-compose.prod.yml up -d app-green; \
	else \
		echo "Deploying to blue"; \
		docker-compose -f docker-compose.prod.yml build app-blue; \
		docker-compose -f docker-compose.prod.yml up -d app-blue; \
	fi

prod-switch: ## Switch the Nginx proxy to the new version in production
	@if [ -L $(PROD_ENABLED_CONF) ] && [ "$(shell readlink $(PROD_ENABLED_CONF))" = "$(PROD_BLUE_CONF)" ]; then \
		echo "Switching to green"; \
		cp $(PROD_GREEN_CONF) $(PROD_ENABLED_CONF); \
	else \
		echo "Switching to blue"; \
		cp $(PROD_BLUE_CONF) $(PROD_ENABLED_CONF); \
	fi
	@docker-compose -f docker-compose.prod.yml restart nginx

prod-rollback: ## Switch back to the previous version in production
	@if [ -L $(PROD_ENABLED_CONF) ] && [ "$(shell readlink $(PROD_ENABLED_CONF))" = "$(PROD_BLUE_CONF)" ]; then \
		echo "Rolling back to green"; \
		cp $(PROD_GREEN_CONF) $(PROD_ENABLED_CONF); \
	else \
		echo "Rolling back to blue"; \
		cp $(PROD_BLUE_CONF) $(PROD_ENABLED_CONF); \
	fi
	@docker-compose -f docker-compose.prod.yml restart nginx

prod-clean: ## Shut down the inactive blue or green instance in production
	@if [ -L $(PROD_ENABLED_CONF) ] && [ "$(shell readlink $(PROD_ENABLED_CONF))" = "$(PROD_BLUE_CONF)" ]; then \
		echo "Cleaning up green"; \
		docker-compose -f docker-compose.prod.yml stop app-green; \
	else \
		echo "Cleaning up blue"; \
		docker-compose -f docker-compose.prod.yml stop app-blue; \
	fi




prod-status: ## Checks the current active environment in production
	@if [ -L $(PROD_ENABLED_CONF) ]; then \
		echo "Production is currently pointing to: $(shell readlink $(PROD_ENABLED_CONF))"; \
	else \
		echo "Production is not configured"; \
	fi

prod-verify: ## Verify the newly deployed production instance
	@if [ -L $(PROD_ENABLED_CONF) ] && [ "$(shell readlink $(PROD_ENABLED_CONF))" = "$(PROD_BLUE_CONF)" ]; then \
		echo "Verifying green instance (port 3002). Check logs below:"; \
		docker-compose -f docker-compose.prod.yml logs app-green; \
	else \
		echo "Verifying blue instance (port 3001). Check logs below:"; \
		docker-compose -f docker-compose.prod.yml logs app-blue; \
	fi

help: ## Display this help screen
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
