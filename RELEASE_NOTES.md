Beeuni VOXL includes the 0.3.3 updates: Windows support in the source, viewer login, Host/Origin checks, a configurable favicon, file handling fixes, and capture and streaming improvements.

These binaries target Linux amd64 and arm64 on Ubuntu 24.04. They retain the Beeuni title and icon. Native x264, libyuv, Opus, PulseAudio and XCB libraries are required.

Login is enabled by default. Existing authenticated proxy deployments must explicitly configure login and allowed host names before upgrading. This release does not update running Beeuni environments automatically.

Verify downloads with `sha256sum -c SHA256SUMS` before decompressing.
