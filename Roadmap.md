# INPT Roadmap
Planned updates to INPT scripts

- CSV files
  - Checks on data input from CSV
    - Similar to typo checks for manual input. Use context like artist names found in artwork folder to serve as confirmation (instead of manual confirmation) where possible. 
- Documentation
  - Describe how files are organized, where functions are stored and which scripts call them
- Create DAMS ingest spreadsheet
  - Read applicable data from the artwork file’s Technical Info_Specs directory 
  - Place relevant metadata into spreadsheet that conforms with SI DAMS metadata template
- homebrew installation
  - create homebrew installation to be able to call scripts and functions with commands
- Preferences config
  - Store settings (for instance, to run typo checks) to toggle settings on/off
  - once installed with homebrew, these options could be assigned to flags instead
