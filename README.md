<p align="center">
  <img src="http://i.imgur.com/1AwoVaN.png"/>
</p>

**Original code taken** from [https://github.com/AYastrebov/Generamba](https://github.com/AYastrebov/Generamba). Thanks to authors!!!

NOTE: Most command works as it was in Generamba.

[![Build Status](https://travis-ci.org/ladeiko/Viperaptor.svg?branch=develop)](https://travis-ci.org/ladeiko/Viperaptor)
[![Gem Version](https://badge.fury.io/rb/viperaptor.svg)](https://badge.fury.io/rb/viperaptor)

**Viperaptor** is a code generator made for working with Xcode. 
Primarily it is designed to generate code modules but it is quite easy to customize it for generation of any other classes (both in Objective-C and Swift).

![Viperaptor Screenshot](https://habrastorage.org/files/b98/770/b37/b98770b37dc54de98daf0e22fea38478.gif)

### Key features

- Supports work with *.xcodeproj* files out of the box. All generated class files are automatically placed to specific folders and groups of Xcode project.
- Can generate both code itself and tests adding them to right targets.
- Based on work with [liquid-templates](https://github.com/Shopify/liquid) that have plain and readable syntax in comparison with templates for Xcode.
- It is very easy to create a new module: `viperaptor gen [MODULE_NAME] [TEMPLATE_NAME]` or `viperaptor gen`. You do not need to input a bunch of data each time because each project corresponds to only one configuration file that holds standard file system and Xcode-project pathes, names of targets, information about the author.
- You can use multiple Rambafiles: Just should contain 'Rambafile' prefix.
### Installation

> Ruby 2.3 or later version is required. To check your current Ruby version run this command in terminal:
```bash
$ ruby --version
```
When necessary you can install the required Ruby version with the help of [`rvm`](http://octopress.org/docs/setup/rvm/) or [`rbenv`](http://octopress.org/docs/setup/rbenv/).

In your terminal run:

```bash
gem install viperaptor
```

### Usage
1. Run [`bundle exec viperaptor setup`](https://github.com/AYastrebov/Generamba/wiki/Available-Commands#basic-generamba-configuration) in the project root folder. This command helps to create [Rambafile](https://github.com/AYastrebov/Generamba/wiki/Rambafile-Structure) that define all configuration needed to generate code. You can modify this file directly in future.
2. Add all templates planned to use in the project to the generated [Rambafile](https://github.com/AYastrebov/Generamba/wiki/Rambafile-Structure). You can begin with one of the templates from our catalog: `{name: 'rviper_controller'}`.
3. Run [`bundle exec viperaptor template install`](https://github.com/AYastrebov/Generamba/wiki/Available-Commands#template-installation). All the templates will be placed in the '/Templates' folder of your current project.
4. Run [`bundle exec viperaptor gen [MODULE_NAME] [TEMPLATE_NAME]`](https://github.com/AYastrebov/Generamba/wiki/Available-Commands#module-generation) - It creates module with specific name from specific template.

### Additional info

Run `viperaptor help` to learn more about each of the Viperaptor features.

**Wiki:**
- [Command list](https://github.com/AYastrebov/Generamba/wiki/Available-Commands)
- [Understanding the Rambafile](https://github.com/AYastrebov/Generamba/wiki/Rambafile-Structure)
- [Understanding templates](https://github.com/AYastrebov/Generamba/wiki/Template-Structure)

**Other materials:**
- [Russian] Rambler.iOS V: Generamba and Code Generation ([Slides](http://www.slideshare.net/Rambler-iOS/viper-56423582) | [Video](http://www.youtube.com/watch?v=NXNiN9FaUnY))
- [Introduction to original Generamba](http://etolstoy.com/2016/02/10/generamba/)

### Authors

- Siarhei Ladzeika <sergey.ladeiko@gmail.com>
- Authors of original Generamba code: Egor Tolstoy, Beniamin Sarkisyan, Andrey Zarembo and the rest of [Rambler.iOS team](https://github.com/orgs/AYastrebov/teams/ios-team).

### License

MIT
