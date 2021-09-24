# UPGRADING
v0.x -> v1.0.0

## End of Support
Support for the following versions has been removed:
### Ruby:
- 2.4
- 2.5

### Rails:
- 5.0
- 5.1

## Breaking Changes
### Error Namespace
`RailsParam::InvalidParameter`:

`RailsParam::Param::InvalidParameterError` has had the `Param` namespace removed. Please update error handling to use the new error `RailsParam::InvalidParameterError` 
