# Use the Flutter base image
FROM cirrusci/flutter:stable

# Set the working directory
WORKDIR /app

# Copy the project files into the container
COPY . /app

# Install project dependencies
RUN flutter pub get

# Run the tests
RUN flutter test