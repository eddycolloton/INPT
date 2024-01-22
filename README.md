# INPT

# Description

These shell scripts are intended to automate several steps frequently performed by media conservators at the Hirshhorn Museum and Sculpture Garden (HMSG). 

When files are delivered to the museum on an external hard drive (or other digital carrier), the conservators generate metadata on the drive and its contents, then move the files to local storage where they are further assessed before being ingest into the Smithsonian Digital Asset Management System.  The metadata created prior to ingest is stored in multiple locations in the museum’s records: sidecar files on a shared drive on the museum's servers (the Artwork File), on local storage (the Staging Directory), and in the appendix to a condition report (appendix) which is attached to the museum’s collection management system upon completion of the report. 

In each of these locations, files are organized using a directory structure that incorporates the associated artist’s name and the accession number of the artwork. However, the directory naming convention is not uniform across the locations. Also, the artwork may have pre-existing directories containing descriptive information documented by other conservators, or this artwork may need to be nested within a parent directory containing the artist’s name. The script relies on user input to collect this information in order to deploy new metadata files.

# Installation

INPT has the following dependencies:
* Cowsay
* Disktype
* Exiftool
* Ffmpeg
* Figlet
* Md5deep
* Mediainfo
* QCTools for CLI, aka QCLI
* Siegfried
* Tree

Each of these is a CLI application that is available from the package manager Homebrew. 

To install all dependencies with Homebrew run dependency_check.sh

# Usage
INPT is divided into 2 stages: INPT and OUTPUT. The steps can be run independently or together. 

## INPT
**Collect information.**

`start_input.sh <optional input.csv> <optional output.csv>`

start_input identifies the following items:
- Artist's First Name 
- Artist's Last Name 
- Artwork Title 
- Accession Number 
- Path to Artwork File on T: Drive
- Staging Directory on DroBo 
- Path to hard drive 
- Path to Technical Info_Specs directory  
- Path to Technical Info_Specs/Sidecars directory  
- Path to Condition_Tmt Reports directory  
- Path Artwork Files parent directory 
- Path to the Time-based Media Artworks directory on the TBMA DroBo 

You can choose to input any of this information prior to running the script using a CSV. A template for the input.csv is here: csv_templates/input_template.csv

Any information not provided in the input.csv will be input manually in terminal through a series of prompts, or inferred based on provided infromation. 
For example once the artist's name has been input, the Artwork Files directory on the T:\ drive is searched for an existing artwork file. If one is found the user will not need to manually input the path to the artwork file. 

You can also provide the output.csv (described in the next section) to start_input. 

A populated input csv is output at the end when start_input.sh and can be provided to start_output to resume processing an artwork started by INPT.

Once start_input completes start_output begins automatically. 

## OUTPUT
**Create information.**

`start_output.sh <optional input.csv> <optional output.csv>`

start_output provides the following options:
- Move all files to staging directory
- Select files to move to staging directory
- Run all tools
- Run tree on volume
- Run siegfried on files in staging directory
- Run MediaInfo on video files in staging directory
- Run Exiftool on media files in staging directory
- Create framdemd5 output for video files in staging directory
- Create QCTools reports for video files in staging directory

Like with the first stage, you can choose to input any of your choices prior to running the script using a CSV. A template for the output.csv is here: csv_templates/output_template.csv

You can provide the input.csv to start_output.sh as well. 

