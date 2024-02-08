# Zap YML Injector
- ⚠️ Environment Variable `API_KEY` must be set before running. This is used to authorise requests to the server.
- Optionally, the variable `WS_FILE_PATH` can be set to determine the location/name of the YML file. By default this is `./output.yml`.
- The variable `WS_PORT` can also be optionally set to determine port. By default this is `80`.

To start the server, run `npm run dev`.

## API Endpoints
### `POST /yaml`
This endpoint will save the resulting YML file to `FILE_PATH` and return the file path it was saved to as a JSON object under the parameter `filePath`.

Request Body (JSON):
```ts
{
  // Required
  urls: string[]

  // Optional
  username: string
  password: string
  loginUrl: string
  pollUrl: string
  loggedInRegex: string
  loggedOutRegex: string
}
```
It is recommended to provide all the optional variables including both regexes as sometimes ZAP will be unable to verify that its authenticated, and make a lot of unnecessary login requests.