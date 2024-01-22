# INPT Roadmap
Planned updates to INPT scripts

- CSV files
  - Checks on data input from CSV
    - For example, if the artist’s name is not found in the artwork file network drive location, the script will prompt the user for a path, as it currently does in the make_dirs.sh script
- Documentation
  - Describe how files are organized, where functions are stored and which scripts call them
- Create DAMS ingest spreadsheet
  - Read applicable data from the artwork file’s Technical Info_Specs directory 
  - Place relevant metadata into spreadsheet that conforms with SI DAMS metadata template
  - When provided to DAMS upon ingest, can’t reduce redundant metadata entered into SI DAMS manually
- homebrew installation
  - create homebrew installation to be able to call scripts and functions with commands?
- Preferences config
  - Store settings (for instance, to run typo checks) in a config file to toggle settings on/off
