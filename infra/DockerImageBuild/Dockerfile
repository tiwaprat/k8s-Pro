# Use Ubuntu as base image
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install OpenJDK 17 and other essentials
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk curl && \
    apt-get clean

# Set working directory inside container
WORKDIR /app

# Copy the jar from local machine to container
COPY student.jar student.jar

# Expose the port if your app listens on one (optional, e.g., 8080)
EXPOSE 8080

# Run the jar
CMD ["java", "-jar", "student.jar"]
