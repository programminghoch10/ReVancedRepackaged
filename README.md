
<div align=center>
   <h1>ReVancedRepackaged</h1>
   <img src=logo/logo_standalone.svg width=25%>
   <br>
   <b>
      <a href=https://github.com/revanced>ReVanced</a>, 
      but patched locally.
   </b>
   <br>
   <br>
   <div>
      <a href="https://github.com/programminghoch10/ReVancedRepackaged/releases/latest"><img src="https://img.shields.io/github/v/release/programminghoch10/ReVancedRepackaged?label=latest&logo=github&display_name=release" alt="GitHub Latest Release (by date)"></a>
      <a href="https://github.com/programminghoch10/ReVancedRepackaged/releases/latest"><img src="https://img.shields.io/github/release-date/programminghoch10/ReVancedRepackaged?logo=github" alt="GitHub Latest Release Date"></a>
      <br>
      <a href="https://github.com/programminghoch10/ReVancedRepackaged/releases"><img src="https://img.shields.io/github/downloads/programminghoch10/ReVancedRepackaged/total?logo=github" alt="GitHub Global Download Counter"></a>
      <a href="https://github.com/programminghoch10/ReVancedRepackaged/releases/latest"><img src="https://img.shields.io/github/downloads/programminghoch10/ReVancedRepackaged/latest/total?logo=github" alt="GitHub Latest Download Counter"></a>
      <br>
      <a href="https://github.com/programminghoch10/ReVancedRepackaged/stargazers"><img src="https://img.shields.io/github/stars/programminghoch10/ReVancedRepackaged?style=social" alt="GitHub Repo stars"></a>
      <a href="https://github.com/programminghoch10"><img src="https://img.shields.io/github/followers/programminghoch10?style=social" alt="GitHub followers"></a>
   </div>
</div>

This magisk module 
contains only the 
[ReVanced Patcher](https://github.com/revanced/revanced-cli). \
It will patch 
[any installed ReVanced compatible app](https://revanced.app/patches) 
right on your device during installation.

<a href="https://github.com/programminghoch10/ReVancedRepackaged/actions/workflows/build.yml"><img src="https://img.shields.io/github/actions/workflow/status/programminghoch10/ReVancedRepackaged/build.yml?logo=github%20actions&logoColor=white" alt="GitHub Workflow Build Status"></a>
<a href="https://github.com/programminghoch10/ReVancedRepackaged/actions/workflows/shellcheck.yml"><img src="https://img.shields.io/github/actions/workflow/status/programminghoch10/ReVancedRepackaged/shellcheck.yml?logo=github%20actions&logoColor=white&label=shellcheck" alt="GitHub Workflow ShellCheck Status"></a>
<br>
<a href="https://github.com/programminghoch10/ReVancedRepackaged/commits/main"><img src="https://img.shields.io/github/last-commit/programminghoch10/ReVancedRepackaged?logo=git&logoColor=white" alt="GitHub last commit"></a>
<a href="https://github.com/programminghoch10/ReVancedRepackaged/compare/"><img src="https://img.shields.io/github/commits-since/programminghoch10/ReVancedRepackaged/latest?logo=git&logoColor=white" alt="GitHub commits since last release"></a>

## Installation

1. Install the original variants of the apps you want to be patched.  
   *Make sure you have the correct versions installed before proceeding.*
1. Install the module and wait for it to patch every compatible app.  
   *This will take very long.*
   *Please refrain from doing anything else on your device in the meantime.*
1. Go into the Google Play Store and disable automatic app updates for all patched apps.
1. Reboot

## Concept

In most legislations it is illegal to redistribute modified software 
without consent of the copyright holder.

For example:  
The Windows modding community isn't allowed to distribute modified Windows ISOs
but is allowed to distribute a patcher, 
which the user can download to patch their geniune Windows ISO.

The same concept can be applied to ReVanced.  
Redistributing magisk modules with patched APKs is not legal.
But we are totally fine distributing the patcher 
and letting the user patch the original APK on his own.

This module automates exactly this.
You, the user, download the original apps yourself.
This module will patch the installed apps during installation
**right on your device**.

## Configuration

All configuration files can be placed into `/sdcard` or `/data/adb`.

### Blacklisting packages

All compatible apps installed on the device are patched by default.

If you want to exclude certain apps from being patched,
add their packagename into a config file called `revancedrepackaged-blacklist.txt`
and place it into the configuration directory.

## Issues and Support

You are welcome to 
[report issues](https://github.com/programminghoch10/ReVancedRepackaged/issues) 
and 
[ask questions](https://github.com/programminghoch10/ReVancedRepackaged/discussions) 
anytime.

Please ensure to only report bugs that belong here,
generic problems should be raised at 
[ReVanced](https://github.com/revanced)
directly.

Please provide as much information as possible rightaway
to save time of everybody investigating your issue.
