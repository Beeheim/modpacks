# Modpack Manager

parse and manage modpacks for the beeheim server

## Responsibilities

Things that this modpack manager *must* do

### Ingest Modpacks
<!--  -->
- ingest modlist
  - server-side
  - greylist
  - whitelist
- retrieve download link
- parse dependencies
- version check
- generate modpacks
  - [ ] manifest.json
  - [ ] configs
  - [ ] readme
  - [ ] changelog
- store versioning information (changelog as database?)