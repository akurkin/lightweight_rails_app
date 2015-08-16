# Dockerized Lightweight Rails app

Skinny rails app built using some example that can be found on the internets. Modified to actually do some work that you'll find in a common rails app:

- database integration
- `ActiveRecord`-based models
- views
- controllers
- specs
- rake tasks to manage db

The idea of the app: Render quotes randomly from database

### Docker integration

This repo includes few files that will help you get started with running it on docker:

- Dockerfile - contains definition of the base image for this app (`rails:onbuild`)
- `docker-compose.yml` - file that includes dependency services required for application to run, i.e. mysql
- `docker-compose.development.yml` - this is same file as `docker-compose.yml`, but tailored for execution of specs and running service in development environment. By setting volume from your current directory into container's directory, so that you always have latest code as soon as you save the change in the file.

# Prerequisites

To get up and running on **your machine**, you'd need to install:

- docker
- docker-machine (to provision docker hosts on your local or in the cloud)
- docker-compose (to orchestrate containers)

If you want to learn more and don't know where to start, check out this excellent guide on [Getting started with docker-compose for Development environment](http://howtocookmicroservices.com/docker-compose/)


# Running (deploying) with Docker

1. Clone repo
1. Create docker host on your laptop
    `docker-machine create -d virtualbox --virtualbox-memory "2048" quotes`
1. Inside repo, start application:
    `docker-compose up -d`
    It will pull, build and then launch mysql and web containers defined in `docker-compose.yml` file
1. Create database and seed initial data:
    `docker-compose run web rake db:reset`
    Be careful, if it's 2nd time you're running it - your database will be deleted, created again and schema with data reloaded.

# Running specs

`docker-compose -f docker-compose.development.yml run -e RAILS_ENV=test web rspec`

This command will launch container and execute specs.

# Deploying without Docker

Of course this rails application like any other can be deployed to any PAAS product, i.e. heroku.

# Application structure

1. Controllers and Models are located in `app.rb` file
2. Views are located in `views` directory
3. Specs are in their normal location - `spec` directory
4. Database configuration is in `db/database.yml` (vs `config/database.yml` with default rails structure)
5. Database migrations and seeds are in `db` direcotry

# Why?

To have a lightweight example of rails app to play with different options for deployment. It must have traits similar to common rails app:

- integration with external services (i.e. database)
- tests
- views
