# HMSG_auto Roadmap
Planned updates to HMSG_auto scripts

## HMSG_auto v1
- Change template of “varfile” to conform to a yaml file
- Further testing of the make_vars.sh, meta_files.sh and move_files.sh scripts to ensure functionality and ease of use. Especially with artist folders containing more than one artwork file.
- Integration of make_vars, meta_files and move_files scripts into README and HMSG documentation, including example workflows. 

HMSG_auto v2
- Config yaml file
  - Instead of iterating through prompts to define variables, variables will be recorded in a template yaml file prior to running the script
  - The script will read the yaml file and verify the variables and extrapolate the path, as well as other information, as they do in v1. 
  - If errors are encountered, script will fall back to prompts
    - For example, if the artist’s name is not found in the artwork file network drive location, the script will prompt the user for a path, as it currently does in the make_dirs.sh script
- Breakdown HMSG_auto.config 
  - Convert the many functions of HMSG_auto.config into separate, purpose specific scripts
  - Scripts can be strung together from reading of the config to making directories, to running metadata tools, but instead of all of these functions being contained in the same file, they will be broken out into many files. 
  - This will make updating functions simpler, only the necessary files will be updated, and the functions will be easier to locate.
- Remove dependency on IFI python script
  - Rewrite only necessary aspects of copyit.py and incorporate new file into HMSG_auto repo
- Create DAMS ingest spreadsheet
  - Read applicable data from the artwork file’s Technical Info_Specs directory 
  - Place relevant metadata into spreadsheet that conforms with SI DAMS metadata template
  - When provided to DAMS upon ingest, can’t reduce redundant metadata entered into SI DAMS manually
