# Testing Nashorn scripts with Netbeans IDE 8.2

Netbeans IDE allows you to run and debug your Nashorn scripts.

* [Requirements](#requirements)
* [Install](#install)
* [Create a new project](#create-a-new-project)

## Requirements
To run the latest version of Nashorn, we need to install JDK 1.8: http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html


## Install

You can download Netbeans IDE 8.2 from 
- [https://netbeans.org/downloads/](https://netbeans.org/downloads/)

Choose the Java EE edition because it includes JavaScript.

## Create a new project

Click File --> New Project..

Select **Java Application** and click **Next**.

![New project - step 1](../img/new_project1.PNG)

Deselect **Create Main Class** and click **Finish**.

![New project - step 2](../img/new_project2.PNG)

Add a new JavaScript file. Rightclick on **Source Packages**.
Choose **New** --> **Other**.

![New project - add file](../img/add_script.png)

Input a filename and click **Finish**.

![New project - create file](../img/add_js_file.PNG)

Now we can create our first Nashorn script. This line of code should work.

```javascript
print('Hello world');
```
Rightclick inside your file and click **Run File**.

![New project - run file](../img/run_script.png)
