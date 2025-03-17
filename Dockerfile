# Build stage for ARM64
FROM --platform=linux/arm64 ubuntu:jammy AS build

# Install dependencies
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    git \
    chromium-browser \
    wget \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
ENV PATH=$JAVA_HOME/bin:$PATH
ENV JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8

RUN git clone https://github.com/zaproxy/gradle-plugin-common.git /zap/gradle-plugin-common
WORKDIR /zap/gradle-plugin-common
RUN git checkout 8f49f6a7e276a515a8bba1b1b7f598e4a5aefdb6 # This is the one we're relying on atm for our version of the ZAP extensions
RUN ./gradlew publishToMavenLocal

# Clone forked repositories
RUN git clone https://github.com/cytix-software/zaproxy.git /zap/zaproxy
RUN git clone https://github.com/cytix-software/zap-extensions.git /zap/zap-extensions

# Build zaproxy (now with plugin available)
WORKDIR /zap/zaproxy
RUN ./gradlew publishToMavenLocal  # Depends on the tagged plugin [[2]][[6]]

# Build zap-extensions
WORKDIR /zap/zap-extensions
RUN ./gradlew publishToMavenLocal
RUN ./gradlew copyMandatoryAddOns

# Build zaproxy (now with plugin available)
WORKDIR /zap/zaproxy
RUN ./gradlew distCrossplatform
RUN cp -rp "./zap/src/main/dist/plugin" "./zap/build/distFiles/"

# Copy init.sh and set permissions
COPY init.sh /zap/zaproxy/build/zap/
WORKDIR /zap/zaproxy/build/zap
RUN chmod +x init.sh

# Runtime configuration
ENV API_KEY=MY_SUPER_SECRET_API_KEY
ENV ZAP_PORT=8080
EXPOSE ${ZAP_PORT}
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 CMD curl --fail http://localhost:${ZAP_PORT} || exit 1

CMD ["./init.sh"]
