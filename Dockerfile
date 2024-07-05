# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /usr/src/app

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        build-essential \
        libpq-dev \
        python3-dev \
        libxml2-dev \
        libxslt1-dev \
        libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone the open-data CKAN fork and switch to the specified branch
RUN git clone --branch master https://github.com/open-data/ckan.git

# Install CKAN
RUN pip install -e ./ckan
RUN pip install -r ./ckan/requirements.txt

# Clone and install necessary extensions
# ckanext-canada from our fork
RUN git clone https://github.com/gc-performance/ckanext-canada.git
RUN pip install -e ./ckanext-canada

# ckanext-scheming
RUN git clone https://github.com/ckan/ckanext-scheming.git
RUN pip install -e ./ckanext-scheming

# ckanext-security
RUN git clone https://github.com/open-data/ckanext-security.git
RUN pip install -e ./ckanext-security

# ckanext-fluent
RUN git clone https://github.com/ckan/ckanext-fluent.git
RUN pip install -e ./ckanext-fluent

# ckanext-recombinant
RUN git clone https://github.com/open-data/ckanext-recombinant.git
RUN pip install -e ./ckanext-recombinant

# Copy the CKAN configuration file into the container
COPY development.ini /etc/ckan/default/development.ini

# Expose port 5000 for web interface
EXPOSE 5000

# Run CKAN
CMD ["ckan", "-c", "/etc/ckan/default/development.ini", "run", "--host", "0.0.0.0"]