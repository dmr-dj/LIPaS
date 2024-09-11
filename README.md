# LIPaS
the LUDUS Installer & Package Solver

## Packages configuration files
Most of the configuration for packages is achieved through simple *toml* configurations files with very few mandatory options.

An example can be taken from the default ones in pkgs-db.

### Retrieve section
The toml configuration file needs a retrieve section as for example:

```toml
[retrieve]
method="wget"
path="the.path.to_mypackage.com/zorglub"
```

The currently supported keys for *method* are: `wget` or `git`.

The path is a string that contains a working path for the methodology requested.

### Build section
The build section defines the automated method for building the package. It requires a little more information and some of the information depends on the method chosen.
A typical shortest possible example for the standard autotools method for installation is:

```toml
[build]
lang="CC"
method="autotools"
```

Currently the different possibilities are:
```toml
lang="CC|FF"
method="autotools|make"
```
If `make` is chosen, then an option `mkfile` should be provided with the only option so far
```toml
mkfile="ad-hoc"
```

If the Makefile is provided internally (because of tuning options of the original package making it not automatic) then an additional modifier can be provided as for example:

```toml
modifier="internal|make.inc"
```

This means an internal make.inc is provided and should be processed according to the LIPaS rules.