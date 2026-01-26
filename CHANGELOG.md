## 0.1.0

- New:
  - Added ResponseData model with json, response and request.
  - Added new validation callback and parse callback (`validatorFunctionFromData` and `parserFunctionFromData`)
  which use ResponseData as argument.
- Update:
  - Exceptions:
    - Added request data for exceptions.
    - Wrapper automatically fills response and request. Also fills message and source if absent.
  - Check whether validators and parsers are more than one.
- Deprecated:
  - `validatorFunctionWithResponse` argument since it replaced with `validatorFunctionFromData`

## 0.0.7

- Fix: Corrected typos including class names

## 0.0.6

- Rework:
  - `parserFunction` are now nullable
- Fix:
  - Multipart post request
- Docs update:
  - Updated README
  - Added CHANGELOG
  - Added code documentation
  - Updated example

## 0.0.5

- Refactor: exceptions

## 0.0.4

- New: added `validatorFunctionWithResponse()` to obtain http.Response on validation

## 0.0.3

- Rework: core logic
- Now depricated:
  - Encoding. Define with request

## 0.0.2

- Fix: throw proper exceptions

## 0.0.1

- Initial version
