---
title: "Building Custom NixOS Images for the Raspberry Pi"
author: "Matt Rathbun"
slug: "building-nixos-rpi-images"
tags:
  - nix
  - nixos
  - raspberrypi
---

When installing NixOS on a computer, I've generally followed the same process:

1. Boot NixOS installer
2. Format and mount partitions
3. Copy `configuration.nix` into place
4. Run the installer
5. Reboot

This works fine for most of my computers, but with a Raspberry Pi you don't generally boot an installer off a USB stick. Instead, you install the operating system (like a Raspberry Pi OS image) directly to its SD card and boot that.

This is another place where NixOS _shines_. Let's talk about building custom NixOS images for the Raspberry Pi.

<!--more-->

## Nix configuration

First, you'll need a nix configuration to build. You don't need a whole lot to get something simple going:

```nix
{ pkgs, config, lib, ... }: {
  networking.hostname = "my-cool-rpi";

  users.users."my-user" = {
    isNormalUser = true;
    home = "/home/my-user";
    extraGroups = [ "wheel" ]; # wheel gives user access to sudo
    initialPassword = "changeme";
  };

  system.stateVersion = "22.05";
}
```

This makes a system with hostname "my-cool-rpi", which has a user named "my-user" with default password "changeme".

Now to create an SD card image from this, you add this import:

```nix
imports = [
  <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
];
```

You can also change some settings for the SD image builder. I like to disable compression (so I can get right to `dd`ing it onto a card) and to give it a custom name:

```nix
sdImage = {
  compressImage = false;
  imageName = "nixos-sd-image-my-cool-rpi.img";
};
```

All in all, your configuration might look like this:

```nix
{ pkgs, config, lib, ... }: {
  networking.hostname = "my-cool-rpi";

  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
  ];

  sdImage = {
    compressImage = false;
    imageName = "nixos-sd-image-my-cool-rpi.img";
  };

  users.users."my-user" = {
    isNormalUser = true;
    home = "/home/my-user";
    extraGroups = [ "wheel" ]; # wheel gives user access to sudo
    initialPassword = "changeme";
  };

  system.stateVersion = "22.05";
}
```

Now your configuration is ready to be turned into an SD card image! But first, we have to talk about how to build this.

## Multi-architecture builds

For most of us, the computer we're going to build this on is running on the `x86_64` CPU architecture. But this image is going to be run on a Raspberry Pi, which is `aarch64`. How are we going to do this?

### Option 1 - Cross-compilation

With cross-compilation, you're compiling for ARM on an x86 architecture. This sounds like what we want, but the problem is that it won't be able to use nix's binary cache. The binary cache matches on both the compiling _and_ target architecture. The ARM packages in Nix's binary cache are built on ARM. Nix will end up compiling _everything_, which takes a very long time.

### Option 2 - Emulation

The quicker option is to _emulate_ ARM. To nix, you're running an ARM build on an ARM processor so it'll use the binary cache and finish much quicker.

It's pretty straightforward to get up and running. Add these lines to the configuration of the NixOS system **running the build**:

```nix
boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
nix.settings.extra-platforms = [ "aarch64-linux" "arm-linux" ];
```

## Wrapping it up

With that sorted out, we can build the image. To build it, you would run something like this:

```nix
nix-build \
  '<nixpkgs/nixos>' \
  -A config.system.build.sdImage \
  --argstr system aarch64-linux \
  -I nixos-config="./path/to/configuration.nix"
```

When it's done, you'll find a `result/sd-image` directory containing the sd card image! 🎉🚀💃

### Pro-tip - Use make!

It's tricky to remember all those arguments so I use `make` for this. Here's an example `Makefile`:

```makefile
sd-image:
	nix-build \
		'<nixpkgs/nixos>' \
		-A config.system.build.sdImage \
		--argstr system aarch64-linux \
		-I nixos-config="./configuration.nix"
```

Now to build the image, you run:

```shell
make
```

Or if it's not the first entry in the Makefile:

```shell
make sd-image
```

## Bonus! Copy the configuration to /etc/nixos/configuration.nix

When you boot your new image, you'll find that there's no `/etc/nixos/configuration.nix`. How do you make changes to an image that's already been installed?

You might think that [this `system.copySystemConfiguration` option](https://search.nixos.org/options?channel=22.11&show=system.copySystemConfiguration) would do it. Close, but it only copies the configuration to the nix store. Here's how you can copy it right to `/etc/nixos`:

```nix
environment.etc."nixos/configuration.nix" = {
  # The './.' indicates that this is a relative path
  text = builtins.readFile (./. + "/configuration.nix");
};
```

Boot the resulting image, sync nix channels with:

```nix
sudo nix-channel --update
```

and now you can apply configuration changes like you would normally:

```shell
sudo nixos-rebuild switch
```

![ooh yeah](https://media.giphy.com/media/aq6Thivv9V9lu/giphy-downsized-large.gif)

## More examples

You can see some examples of this in action in a couple of my repositories:

* [mattbun/irberry](https://github.com/mattbun/irberry)
* [mattbun/nappa-cluster](https://github.com/mattbun/nappa-cluster)
