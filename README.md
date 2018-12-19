# frealign-2dx
Source code of the modified FREALIGN v9.11 used for processing 2D crystal data as described in:

Righetto, R., Biyani, N., Kowal, J., Chami, M. & Stahlberg, H. _Retrieving High-Resolution Information from Disordered 2D Crystals by Single Particle Cryo-EM_. bioRxiv 488403 (2018). http://doi.org/10.1101/488403

Main differences to the original FREALIGN v9.11 program are the implementation of:

* Alignment with local restraints in X,Y,PSI,THETA,PHI (```calcfx.f```)
* Auto-refinement algorithm (```mult_refine_auto.com``` and ```mult_refine_auto_n.com```)
* Focussed reconstruction, i.e. the spherical mask applied in reconstruction can be anywhere within the box - not to be confused with, albeit related to, _focussed classification_ (```mask3dmerge.f```) 

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
The generated binaries (```.exe``` files) will be located under the ```bin/``` directory that should be appended to your ```PATH``` environment variable (e.g. in your ```.bashrc``` profile):
```
export PATH=<path-to-frealign-2dx>/bin:$PATH
```


For detailed installation and usage instructions, please refer to the official FREALIGN documentation & references:

Grigorieff, N. _Frealign: An Exploratory Tool for Single-Particle Cryo-EM_. in (ed. Enzymology, B. T.-M. in) (Academic Press, 2016). http://dx.doi.org/10.1016/bs.mie.2016.04.013

http://grigoriefflab.janelia.org/frealign
