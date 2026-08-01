# CrossBridge

CrossBridge is the open-source version of Adobe FlasCC, formerly the
[Alchemy](https://en.wikipedia.org/wiki/Adobe_Alchemy) project. It provides a
C/C++ development environment targeting the Adobe Flash Runtime.

This fork preserves CrossBridge 15.0.0.3 and makes its historical toolchain
usable on modern Linux, macOS, and Windows systems through Docker.

## Features

- LLVM-GCC 4.2 compiler with an Adobe AVM2 backend
- C and C++ compilation to native executables, SWF, and SWC
- POSIX threads and OpenMP support
- SWIG-generated ActionScript interoperability
- GDB support for debugging code running in Flash Player
- Bundled sample projects

## Quick start

Install Docker, clone this repository, and enter it:

```sh
git clone https://github.com/33TU/crossbridge.git
cd crossbridge
```

The usage examples below assume the repository's `bin/` directory is on
`PATH`. On Windows, `crossbridge.ps1` is the equivalent PowerShell launcher.

Now enter the samples directory and build Hello World:

```sh
cd samples
crossbridge make T01
```

In PowerShell, invoke the PowerShell launcher by name:

```powershell
Set-Location samples
crossbridge.ps1 make T01
```

The launcher pulls `ghcr.io/33tu/crossbridge:15.0.0.3-light` when necessary,
mounts the current directory at `/work`, and writes the generated files back
to the current directory.

To compile only `hello.c`:

```sh
crossbridge \
  gcc 01_HelloWorld/hello.c -emit-swf -swf-version=26 \
  -o 01_HelloWorld/hello.swf
```

## Docker images

Two image variants are available:

| Image | Contents |
| --- | --- |
| `ghcr.io/33tu/crossbridge:15.0.0.3-light` | Core SDK and the dependencies required by samples 01-12 |
| `ghcr.io/33tu/crossbridge:15.0.0.3-full` | Core SDK plus all optional third-party libraries |

The light image is the default. It supports ordinary C/C++, pthreads, OpenMP,
SWIG, and Stage3D development. The full image additionally includes libraries
such as SDL, FreeGLUT, libffi, OpenSSL, image and audio codecs, and other ports.

Select the full image explicitly on Linux or macOS:

```sh
CROSSBRIDGE_IMAGE=ghcr.io/33tu/crossbridge:15.0.0.3-full \
  crossbridge make T13
```

Or in PowerShell:

```powershell
$env:CROSSBRIDGE_IMAGE = "ghcr.io/33tu/crossbridge:15.0.0.3-full"
crossbridge.ps1 make T13
```

CrossBridge is an x86-era toolchain, so the images target `linux/amd64`.
Docker can run them through emulation on ARM hosts.

## Building the images

The prebuilt images avoid the lengthy SDK build. To build them locally, install
[Just](https://just.systems/) and run:

```sh
just build-light
just build-full
```

The default is 16 parallel build jobs. Override it when needed:

```sh
BUILD_JOBS=8 just build-light
```

The build compiles the historical LLVM, GCC, target libraries, tools, tests,
and sample projects from source. A clean build can take a while.

## Legacy documentation

The original [SDK readme](README.html) documents native Windows/Cygwin and
macOS installations. Additional historical material is available under
[`docs/`](docs/).

Adobe Flash Player has reached end of life. Running generated SWFs requires a
compatible standalone player or another Flash-capable runtime environment.

## Licensing

CrossBridge and its bundled third-party components retain their respective
licenses. Review [`LICENSE.md`](LICENSE.md) and the license files distributed with
individual components before redistributing modified SDKs or container images.
