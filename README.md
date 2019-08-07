# homebrew-moose

Note: The Homebrew modules found here, are in early production. Please continue to follow our [Getting Started](https://mooseframework.org/getting_started/index.html) instructions instead.

To use MOOSE by means of Homebrew, first tap Idaholab MOOSE, and then install our environment:

```bash
brew tap idaholab/moose
brew install moose
```

Follow the on-screen instructions. Which is explaining how to source an additional file to make it all work (assuming you installed Homebrew to it's default location of /usr/local):

``` bash
source /usr/local/opt/moose/moose_profile.sh
```

We recommend you add the above command to your ~/.bash_profile so as to enable the moose profile environment automatically with each new terminal window opened:

``` bash
echo "source /usr/local/opt/moose/moose_profile.sh" >> ~/.bash_profile
```

# Peacock

In order to use [Peacock](https://mooseframework.org/application_usage/peacock.html) (graphical front end for MOOSE), additional python packages must be installed. Homebrew recommends python packages be maintained by `pip`. Execute the following command to install the necessary python packages:

```bash
pip install numpy scipy matplotlib pandas
```

