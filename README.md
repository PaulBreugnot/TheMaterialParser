# TheMaterialParser
*TheMaterialParser* is Rail based web application that allows you to *semi-automatically* extract material compositions from PDF documents.

![](https://github.com/PaulBreugnot/TheMaterialParser/blob/master/docs/first_process_iteration_example.png)

# About
This project that has been led in the context of a research project at the [Ecole Des Mines de Saint-Etienne](https://www.mines-stetienne.fr/en/), among the SMS research group.

Its original motivation is the fact that material manufacturers worldwide usually provide datasheets for their material products as unstandardized PDF datasheets. However, being able to gather and unify those data from different sources to be able to input them, for example, in statistical processes can be very important in the context of real experiments, because they are products that can be bought directly to providers.

Extract empirical material information from PDF publications and books can also be interesting.

This project is highly dependent on the [Tabula project](https://tabula.technology/). See [process section](#process).

# Features
- [x] Create and manage documents categories.
- [x] Upload PDF documents to the server.
- [x] Apply our Tabula-based process to datasheets subsets.
- [x] Save results to a relationnal database, and consult and dowload them as .csv.
- [ ] Support for properties other than composition.
- [ ] Support for other language to look for valid data.
- [ ] Auto-detect potential properties locations.

# Process
Our process is based directly on the [Tabula project](https://tabula.technology), and more precisely its [tabula-java](https://github.com/tabulapdf/tabula-java) core. Basically, you can perform several selections on any number of selected datasheets. The algorithm then tries to extract potential composition tables from all the datasheets with all the selections using Tabula. A composition is finally considered as valid if it is composed of valid elements from the periodic table. For now, only english element names (and official symbols) are supported.

# Run from source
## Clone project
Go to the directory in which you want to install TheMaterialParser, and run :
> git clone https://github.com/PaulBreugnot/TheMaterialParser

## Install jRuby
TheMaterialParser uses the *jRuby* implementation of `Ruby 2.5.0`. This allows us to call `tabula-java` from our Ruby code.

In order to install the good jRuby interpreter, you can use [rvm](https://rvm.io/). Check the [rvm documentation](https://rvm.io/rvm/install) to know how to install it.
Once installed, run :
> rvm install jruby-9.2.5.0

> rvm use jruby-9.2.5.0

## Build project
Go at the root of the directory that you previously cloned, and run the following command to install dependencies :
> jruby -S bundle install

Then, to create the sqlite3 embedded database :
> jruby -S rails db:create db:migrate

Finally, run :
> jruby -S rails server

The app will now be accessible from your web browser at http://localhost:3000.
When you need to re-launch the app, you just need to use this last command from the root directory of the project.

# License
Copyright 2019 Paul Breugnot. Available under MIT License. See [LICENSE](https://github.com/PaulBreugnot/TheMaterialParser/blob/master/LICENSE).
