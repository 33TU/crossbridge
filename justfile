build_jobs := env("BUILD_JOBS", "16")
light_image := env("CROSSBRIDGE_LIGHT_IMAGE", "ghcr.io/33tu/crossbridge:15.0.0.3-light")
full_image := env("CROSSBRIDGE_FULL_IMAGE", "ghcr.io/33tu/crossbridge:15.0.0.3-full")

# List available recipes.
default:
    @just --list

# Build the core SDK and samples 01-12.
build-light:
    docker build --build-arg LIGHTSDK=1 --build-arg BUILD_JOBS={{ build_jobs }} -t {{ light_image }} .

# Build the SDK with all optional third-party libraries.
build-full:
    docker build --build-arg LIGHTSDK=0 --build-arg BUILD_JOBS={{ build_jobs }} -t {{ full_image }} .
