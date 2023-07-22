# JavaScript/Duktape on Unikraft

## Requirements

In order to set up, configure, build and run Duktape on Unikraft, the following packages are required:

* `build-essential` / `base-devel` / `@development-tools` (the meta-package that includes `make`, `gcc` and other development-related packages)
* `sudo`
* `flex`
* `bison`
* `git`
* `wget`
* `uuid-runtime`
* `qemu-system-x86`
* `qemu-system-arm`
* `qemu-kvm`
* `sgabios`
* `gcc-aarch64-linux-gnu`

GCC >= 8 is required to build Duktape on Unikraft.

On Ubuntu/Debian or other `apt`-based distributions, run the following command to install the requirements:

```console
apt-get install -y --no-install-recommends \
    build-essential \
    sudo \
    gcc-aarch64-linux-gnu \
    libncurses-dev \
    libyaml-dev \
    flex \
    bison \
    git \
    wget \
    uuid-runtime \
    qemu-kvm \
    qemu-system-x86 \
    qemu-system-arm \
    sgabios
```

In addition, Python 2.7 needs to be installed under the name `python2`:

```console
sudo apt install python2
```

Also `pyYaml` needs to be installed.
This can be done in two ways:

```console
sudo apt install python-pip
pip2 install pyYaml
```

or it can be installed with:

```console
sudo apt-get install python-yaml
```

## Set Up

The following repositories are required for Duktape:

* The application repository (this repository): [`app-duktape`](https://github.com/unikraft/app-duktape)
* The Unikraft core repository: [`unikraft`](https://github.com/unikraft/unikraft)
* Library repositories:
  * The Duktape library repository: [`lib-duktape`](https://github.com/unikraft/lib-duktape)
  * The standard C library: [`lib-musl`](https://github.com/unikraft/lib-musl)

Follow the steps below for the setup:

  1. First clone the [`app-duktape` repository](https://github.com/unikraft/app-duktape) in the `duktape/` directory:

     ```console
     git clone https://github.com/unikraft/app-duktape duktape
     ```

     Enter the `duktape/` directory:

     ```console
     cd duktape/
     ```

  1. While inside the `duktape/` directory, create the `.unikraft/` directory:

     ```console
     mkdir .unikraft
     ```

     Enter the `.unikraft/` directory:

     ```console
     cd .unikraft/
     ```

  1. While inside the `.unikraft` directory, clone the [`unikraft` repository](https://github.com/unikraft/unikraft):

     ```console
     git clone https://github.com/unikraft/unikraft unikraft
     ```

  1. While inside the `.unikraft/` directory, create the `libs/` directory:

     ```console
     mkdir libs
     ```

  1. While inside the `.unikraft/` directory, clone the library repositories in the `libs/` directory:

     ```console
     git clone https://github.com/unikraft/lib-duktape libs/duktape
     git clone https://github.com/unikraft/lib-musl libs/musl
     ```

  1. Get back to the application directory:

     ```console
     cd ../
     ```

     Use the `tree` command to inspect the contents of the `.unikraft/` directory.
     It should print something like this:

     ```console
     tree -F -L 2 .unikraft/
       .unikraft/
       |-- libs/
       |   |-- duktape/
       |   `-- musl/
       `-- unikraft/
           |-- arch/
           |-- Config.uk
           |-- CONTRIBUTING.md
           |-- COPYING.md
           |-- include/
           |-- lib/
           |-- Makefile
           |-- Makefile.uk
           |-- plat/
           |-- README.md
           |-- support/
           `-- version.mk

     9 directories, 7 files
     ```

 1. At last, make an empty directory to be mounted as a root filesystem in the `/duktape` root folder of the project.

   ```console
   mkdir fs0
   ```

## Configure

Configuring, building and running a Unikraft application depends on our choice of platform and architecture.
Currently, supported platforms are QEMU (KVM), Xen and linuxu.
QEMU (KVM) is known to be working, so we focus on that.
Supported architectures for qemu KVM are x86_64 and AArch64, and so for these architectures, default configurations can be found.

Use the corresponding the configuration files (`config-...`), according to your choice of platform and architecture.

For making a different configuration then default, please note, that the following are required:

1. The Musl library
1. A mounted filesystem
1. The duktape library

### QEMU x86_64

Use the `config-qemu-x86_64` configuration file together with `make defconfig` to create the configuration file:

```console
UK_DEFCONFIG=$(pwd)/config-qemu-x86_64 make defconfig
```

This results in the creation of the `.config` file:

```console
ls .config
.config
```

The `.config` file will be used in the build step.

### QEMU AArch64

Use the `config-qemu-aarch64` configuration file together with `make defconfig` to create the configuration file:

```console
UK_DEFCONFIG=$(pwd)/config-qemu-aarch64 make defconfig
```

Similar to the x86_64 configuration, this results in the creation of the `.config` file that will be used in the build step.

## Build

Building uses as input the `.config` file from above, and results in a unikernel image as output.
The unikernel output image, together with intermediary build files, are stored in the `build/` directory.

### Clean Up

Before starting a build on a different platform or architecture, you must clean up the build output.
This may also be required in case of a new configuration.

Cleaning up is done with 3 possible commands:

* `make clean`: cleans all actual build output files (binary files, including the unikernel image)
* `make properclean`: removes the entire `build/` directory
* `make distclean`: removes the entire `build/` directory **and** the `.config` file

Typically, you would use `make properclean` to remove all build artifacts, but keep the configuration file.

### QEMU x86_64

Building for QEMU x86_64 assumes you did the QEMU x86_64 configuration step above.
Build the Unikraft Duktape image for QEMU x86_64 by using:

```console
make prepare
make -j $(nproc)
```

This results in the output:

```
[...]
  LD      duktape_qemu-x86_64.dbg
  UKBI    duktape_qemu-x86_64.dbg.bootinfo
  SCSTRIP duktape_qemu-x86_64
  GZ      duktape_qemu-x86_64.gz
make[1]: Leaving directory '/home/joachim/Desktop/unikraft/ELF/duktape/.unikraft/unikraft'
```

At the end of the build command, the `duktape_qemu-x86_64` unikernel image is generated.
This image is to be used in the run step.

### QEMU AArch64

If you had configured and build a unikernel image for another platform or architecture (such as x86_64) before, then:

1. Do a cleanup step with `make properclean`.

1. Configure for QEMU AAarch64, as shown above.

1. Follow the instructions below to build for QEMU AArch64.

Building for QEMU AArch64 assumes you did the QEMU AArch64 configuration step above.
Build the Unikraft Duktape image for QEMU AArch64 by using the same command as for x86_64:

```console
make -j $(nproc)
[...]
  LD      duktape_qemu-arm64.dbg
  UKBI    duktape_qemu-arm64.dbg.bootinfo
  SCSTRIP duktape_qemu-arm64
  GZ      duktape_qemu-arm64.gz
```

Similarly to x86_64, at the end of the build command, the `duktape_qemu-arm64` unikernel image is generated.
This image is to be used in the run step.

## Run

Run the resulting image with the `run-...` scripts.

### QEMU x86_64

To run the QEMU x86_64 build, use `run-qemu-x86_64.sh`:

```console
./run-qemu-x86_64.sh

SeaBIOS (version 1.15.0-1)


iPXE (https://ipxe.org) 00:03.0 CA00 PCI2.10 PnP PMM+07F8B2F0+07ECB2F0 CA00
                                                        
Booting from ROM..Powered by
o.   .o       _ _               __ _
Oo   Oo  ___ (_) | __ __  __ _ ' _) :_
oO   oO ' _ `| | |/ /  _)' _` | |_|  _)
oOo oOO| | | | |   (| | | (_) |  _) :_
 OoOoO ._, ._:_:_,\_._,  .__,_:_, \___)
                  Atlas 0.13.1~e467cdf6
((o) Duktape 2.4.0 (RELEASE-0.13.1-1-gd3381b5-dirty)
duk> 5 + 2
= 7
duk> a = 36
= 36
duk> Math.sqrt(a)
= 6
duk> 
```

To close the QEMU Duktape instance, use the `Ctrl+a x` keyboard shortcut;
that is press the `Ctrl` and `a` keys at the same time and then, separately, press the `x` key.

### QEMU AArch64

To run the AArch64 build, use `run-qemu-aarch64.sh`:

```console
./run-qemu-aarch64.sh
[    0.017201] ERR:  [libkvmvirtio] <virtio_bus.c @  140> Failed to find the driver for the virtio device 0x4029c020 (id:1)
[    0.018329] ERR:  [libkvmvirtio] <virtio_pci.c @  425> Failed to register the virtio device: -14
[    0.018600] ERR:  [libkvmpci] <pci_bus_arm64.c @  100> PCI 00:01.00: Failed to initialize device driver
Powered by
o.   .o       _ _               __ _
Oo   Oo  ___ (_) | __ __  __ _ ' _) :_
oO   oO ' _ `| | |/ /  _)' _` | |_|  _)
oOo oOO| | | | |   (| | | (_) |  _) :_
 OoOoO ._, ._:_:_,\_._,  .__,_:_, \___)
                  Atlas 0.13.1~e467cdf6
((o) Duktape 2.4.0 (RELEASE-0.13.1-1-gd3381b5-dirty)
duk> 5 + 2
= 7
duk> a = 100
= 100
duk> Math.sqrt(a)
= 10
duk> 
```

Similarly, to close the QEMU Duktape server, use the `Ctrl+a x` keyboard shortcut.
