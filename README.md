# Dockerfile for running a DRY project

To use update your `docker-compose.yml` file to include the following:

```yaml
  project_name-site:
    build: https://github.com/TallieuTallieu/dry-docker.git
```

You can fix the version of the image by using a specific tag:

```yaml
  project_name-site:
    build: https://github.com/TallieuTallieu/dry-docker.git#v1.0.1
```

Run `docker-compose up --build` to update the image.

## Puppeteer Support

The Dockerfile supports optional installation of Puppeteer dependencies (Chrome/Chromium libraries) through the `ENABLE_PUPPETEER` build argument.

### Enable Puppeteer dependencies

To build the image with Puppeteer support, you can either:

**Option 1: Using docker-compose build command**
```bash
docker-compose build --build-arg ENABLE_PUPPETEER=true
```

**Option 2: In your docker-compose.yml file**
```yaml
  project_name-site:
    build:
      context: https://github.com/TallieuTallieu/dry-docker.git
      args:
        ENABLE_PUPPETEER: true
```

**Option 3: For local Dockerfile**
```yaml
  project_name-site:
    build:
      context: .
      args:
        ENABLE_PUPPETEER: true
```

By default, Puppeteer dependencies are **not installed** to keep the image size smaller. Only enable this if your project requires headless browser automation.

## Changes for a specific project

You can make changes to the Dockerfile for a specific project by creating a new branch and using this in the `build` line in the `docker-compose.yml` file.  

```yaml
  project_name-site:
    build: https://github.com/TallieuTallieu/dry-docker.git#branch_name
```

Or you can copy and paste the Dockerfile into your project and make changes there.

## Changes to the Dockerfile

If you make changes to the Dockerfile, make sure you create a new tag using [semantic versioning](https://semver.org/) and describe the changes in the tag description.

```bash
git tag -a 1.0.1 -m "Description of changes"
git push origin 1.0.1
```
