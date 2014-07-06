Puppet-Reports-in-Powershell
============================

Powershell scripts to convert Puppet reports into other formats e.g. HTML or Teamcity Unit Tests

What's it for?
--------------
The [Puppet report YAML Puppet Report Format](http://docs.puppetlabs.com/puppet/3/reference/format_report.html) can be very confusing to read when there are a large number of resources.
Puppet Enterprise has a dashboard for this kind of investigation but when in running masterless, this feature is not available.  It is also difficult to integrate Puppet reports into other systems e.g. Continuous Integration systems.

This project aims to make converting the Puppet reports into different formats on Windows platforms;
* Easy to convert into multiple formats
* Does not require additional languages to be installed (e.g. Ruby, Python)
* Uses native PowerShell

Getting Started
---------------
### Download or install the dependencies

* Install PowerYaml via GitHub (git must be in the search path)

Execute `dependencies\InstallPowerYamlGithub.cmd`

* Install PowerYaml via Nuget (nuget must be in the search path)

Execute `dependencies\InstallPowerYamlNuget.cmd`

Example Transform files
------------------------
The transform files are XML Stylesheets which contain XML transformation functions.  They are located in the `transforms` directory.

#### basic.report.html

A simple HTML report with a table showing the resource status (e.g. Changed, Out of sync) and a count of the resources with that status.

#### detailed.report.html

A HTML report with a table showing the all resource statuses (e.g. Changed, Out of sync) and a count of the resources with that status and a summary of every resource in the report.

#### teamcity.tests.stdout
A console stdout report which lists every resource as a Teamcity test and includes duration time and failure information


Converting a Puppet Report
--------------------------

`.\parsereport.ps1 -Report <Reports> -Transform <Transforms> -OutputDir <Output Directory> [-OutputXML]`

#### Parameters

`-Report <Reports>`

The path to the reports to convert. This can be a single report or a list e.g. 'C:\Report1.yaml','C:\Report2.yaml'


`-Transform <Transforms>`

The names of the transforms to apply. This can be a single transform or a list e.g. 'basic.report.html','detailed.report.html'
The transforms must be located in the `<scriptdir>\transforms` directory and do not contain the XSL file extension.

`-OutputDir <Output Directory>`

The directory where the converted reports will be saved.  The filename is `<Report Name>.<Transform Name>`.
Note that transforms that end in `.stdout` will not be saved, but instead be output to the console.


`-OutputXML`

Optional parameter which when specified will also save the converted XML file to the Output directory as `<Report Name>.XML`


#### Example command line from a command prompt
`powershell "& { . '.\parsereport.ps1' -Report 'C:\ProgramData\PuppetLabs\puppet\var\reports\201407020852.yaml' -Transform 'basic.report.html','teamcity.tests.stdout' -OutputDir 'C:\PuppetReports'}"`


How does it work?
-----------------
1. Parse the Yaml puppet report using PowerYaml. This converts it into a PSCustomObject type
2. Convert the PSCustomObject into an XML document with some post processing e.g. calculating percentages and converting times to different formats.  The post processing makes it a bit easier to use XSL transforms.
3. Apply XSL transforms to the XML document
4. Save the transformed reports to the output directory, and optionally save the original XML documents as well

### Why convert Yaml to XML?
XML is easy to manipulate using XSL transforms and is searchable using XPath.  Also Windows natively supports XML document manipulation.


Dependencies
------------
This project uses the PowerYaml and Yaml.Net libraries

[PowerYaml on Github](https://github.com/scottmuc/PowerYaml)

[PowerYaml on Nuget](https://www.nuget.org/packages/PowerYaml/)

[YamlDotNet on GitHub](https://github.com/aaubry/YamlDotNet)
