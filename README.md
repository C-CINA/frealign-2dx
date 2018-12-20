# frealign-2dx
## Overview
Source code of the modified FREALIGN v9.11 used for processing 2D crystal data as described in:

Righetto, R., Biyani, N., Kowal, J., Chami, M. & Stahlberg, H. _Retrieving High-Resolution Information from Disordered 2D Crystals by Single Particle Cryo-EM_. bioRxiv 488403 (2018). http://doi.org/10.1101/488403

Main differences to the original FREALIGN v9.11 program are the implementation of:

* Alignment with local restraints in X,Y,PSI,THETA,PHI (```calcfx.f```)
* Auto-refinement algorithm (```mult_refine_auto.com``` and ```mult_refine_auto_n.com```)
* Focussed reconstruction (```mask3dmerge.f```) , i.e. the spherical mask applied in 3D reconstruction now can be anywhere within the box. That is, the FSC and map filtering are calculated with respect to the focussed region only. Not to be confused with, albeit related to, _focussed classification_. 

New parameters are explained in the template ```mparameters``` file provided.

## Installing from provided binaries
At the desired installation location, run
```
git clone https://github.com/C-CINA/frealign-2dx.git
```
The provided binaries (```.exe``` files) located under the ```bin/``` directory should be visible via your ```PATH``` environment variable (e.g. in your ```.bashrc``` profile):
```
export PATH=<path-to-frealign-2dx>/bin:$PATH
```

## Compiling from source
For (statically) compiling the binaries using the PGI Fortran compiler (recommended):
```
cd src/
make -f Makefile_linux_amd64_pgi_static
make -f Makefile_linux_amd64_pgi_mp_static
```

For (statically) compiling the binaries using the GNU Fortran compiler:
```
cd src/
make -f Makefile_linux_amd64_gnu_static
make -f Makefile_linux_amd64_gnu_mp_static
```
## Using the program

To start a normal FREALIGN refinement run, run the command ```frealign_run_refine```. To use the auto-refiner, run ```frealign_run_refine_auto```.

For more usage information, please check:

Getting started: http://grigoriefflab.janelia.org/frealign_getting_started

Running FREALIGN: http://grigoriefflab.janelia.org/frealign_running_frealign

## Further reading
For detailed installation and usage instructions, please refer to the original FREALIGN documentation:

**Comprehensive reference:**
Grigorieff, N. _Frealign: An Exploratory Tool for Single-Particle Cryo-EM_. in (ed. Enzymology, B. T.-M. in) (Academic Press, 2016). http://dx.doi.org/10.1016/bs.mie.2016.04.013

**Official website:**
http://grigoriefflab.janelia.org/frealign

## Contact

For bug reports and feature requests, please use GitHub's [issue tracker](http://github.com/C-CINA/frealign-2dx/issues). For other information, please contact us at http://c-cina.org.
