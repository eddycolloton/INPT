# HMSG_auto

This shell script is intended to automate several steps frequently performed by media conservators at the Hirshhorn Museum and Sculpture Garden (HMSG). 

When files are delivered to the museum on an external hard drive (or other digital carrier), the conservators generate metadata on the drive and its contents, then move the files to local storage where they are further assessed before being ingest into the Smithsonian Digital Asset Management System.  The metadata created prior to ingest is stored in multiple locations in the museum’s records: sidecar files on a shared drive on the museum's servers (the Artwork File), on local storage (the Staging Directory), and in the appendix to a condition report (appendix) which is attached to the museum’s collection management system upon completion of the report. 

In each of these locations, files are organized using a directory structure that incorporates the associated artist’s name and the accession number of the artwork. However, the directory naming convention is not uniform across the locations. Also, the artwork may have pre-existing directories containing descriptive information documented by other conservators, or this artwork may need to be nested within a parent directory containing the artist’s name. The script relies on user input to collect this information in order to deploy new metadata files created through automation. 

The workflow is currently organized in the following steps:
1. Determine if the Artwork File or Staging Directory exists, and establish the path to those locations
2. Create a checksum manifest, copy the files from the drive, and confirm that the checksums match
3. Generate metadata describing the external drive/carrier
4. Generate metadata describing the files (now on the Staging Directory)

The shell script has the following dependencies. Each of these is a CLI application that is available from the package manager Homebrew, and each is called by the script:
* Cowsay
* Disktype
* Exiftool
* Ffmpeg
* Figlet
* Mediainfo
* QCTools for CLI, aka QCLI
* Siegfried
* Tree

The script also takes advantage of the IFIscripts designed by Kieran O’Leary. Download the repo from [Kieran’s GitHub](https://github.com/kieranjol/IFIscripts). The HMSG script will call the [copyit.py script](https://github.com/kieranjol/IFIscripts/blob/master/copyit.py) which requires python. 

*Note:* This is my first foray into automated workflows, I have previously just used simple one or two line scripts to perform the tasks in this workflow individually. This is very much a first draft of the script, and I’m open to restructuring it.  
