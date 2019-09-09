# homebrew-moose

### Note: The Homebrew modules found here, are in early production. These modules depend on Python3 (something we do not yet support in MOOSE). Please continue to follow our [Getting Started](https://mooseframework.org/getting_started/index.html) instructions instead. For the Python savvy, there is an idaholab/moose python-3 development branch, which is partially working.

If you wish to develop MOOSE-based appications by means of Homebrew, first [install Homebrew](https://brew.sh/), and then perform the necessary brew commands to 'tap' and install the MOOSE environment:

```bash
brew tap idaholab/moose
brew install moose
```

Follow the on-screen instructions. Which may contain quite a bit of noise explaining how to make use of everything being installed. Basically, you must perform the following::

``` bash
source /usr/local/opt/moose/moose_profile.sh
```

We recommend you add the above command to your ~/.bash_profile so as to enable the MOOSE environment automatically with each new terminal window opened:

``` bash
echo "source /usr/local/opt/moose/moose_profile.sh" >> ~/.bash_profile
```

# Peacock / GUIs

In order to use [Peacock](https://mooseframework.org/application_usage/peacock.html) (our graphical front end for MOOSE), additional python packages must be installed. Homebrew recommends python packages be maintained by `pip3`. Execute the following pip3 command to install the necessary python packages:

```bash
pip3 install numpy scipy matplotlib pandas
```

Once the above has been installed, close, and re-open your terminal windows. You should see 'peacock' as a listed module when performing `module list`:

```bash
#> module list
Currently Loaded Modulefiles:
 1) moose-dev-clang   2) peacock
```

## Updates

Periodically, there will be updates to MOOSE (such as libMesh, PETSc, etc). To install these updates, run `brew upgrade`. And then open a new terminal. This will upgrade all Homebrew modules. Once complete, it will be necessary to rebuild MOOSE as well as your application.
