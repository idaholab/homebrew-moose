# homebrew-moose

Note: The Homebrew modules found here, are in early production. Please continue to follow our [Getting Started](https://mooseframework.org/getting_started/index.html) instructions instead.

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

# Peacock

In order to use [Peacock](https://mooseframework.org/application_usage/peacock.html) (our graphical front end for MOOSE), additional python packages must be installed. Homebrew recommends python packages be maintained by `pip`. Execute the following pip command to install the necessary python packages, and then open a new terminal window:

```bash
pip install numpy scipy matplotlib pandas
```

## Updates

Periodically, there will be updates to MOOSE (such as libMesh, PETSc, etc). To install these updates, run `brew upgrade`. And then open a new terminal. This will upgrade all Homebrew modules. Once complete, it will be necessary to rebuild MOOSE as well as your application.
