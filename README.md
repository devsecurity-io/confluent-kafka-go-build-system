# Confluent Kafka Go Build System

# Introduction

Recently I was faced with the challenge to cross-build a *Confluent Kafka Go*
dependent application for Linux on macOS. Even though the Go toolchain supports
cross-compilation, in the present case building for another platform is not
a trivial task as *Confluent Kafka Go* is actually a wrapper around the C
library *librdkafka* and as such is heavily making use of *cgo*.

*cgo* is an interface which allows to create Go packages that call C code.
The ability to call C code from Go is a great feature of the language and
its accompanying toolchain because it opens the immense world of existing C
code to the Go domain. This feature, however, comes for the price of a
decreased protability of Go programs which are using "cgo". Unfortunately this
applies also for the *Confluent Kafka Go* library. As stated in this
[thread](https://github.com/confluentinc/confluent-kafka-go/issues/119#issuecomment-361141449)
compilation for other target platforms as the one "you are currently on" is not
supported by the library. Moreover, a comment in this thread suggests to use a
Docker container in order to build for other platforms.

Using Docker as a build environment is exactly the approach I came up with.
Heavily inspired by the following [blog post](https://medium.com/@thejasongerard/building-a-static-go-binary-with-librdkafka-on-macos-f79702f50fb)
and its related [GitHub repository](https://github.com/jasongerard/go-librdkafka-static)
the present build environment was created.

## Contribution

In comparison to the original implementation the following improvements have
been made:

* Makefile of the build system (container image) has been separated from the
  Makefile for the target application
* Target application is not built by creating a temporary container. Instead
  only the build container is used. After termination of the build container
  its state is automatically reset to the initial state such that no container
  must be deleted after the target application has been built.
* *librdkafka* has been updated to the latest 1.5.3 version
* Reinstatement of static builds of the target application after official
  support was removed in *Confluent Kafka Go* 1.4.0

## Limitations

* With this build system only musil-based builds are supported. glibc-based
  builds are not supported. This is, however, not really a limitation since the
  objective of this build system is to create statically linked applications
  which run well on both system types.
* Generally the build system should run on all host systems which have a
  *Docker* runtime environment installed. It has, however, only be tested on
  macOS. Testing on other platforms is higly appreciated.
