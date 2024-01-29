# Zap YML Injector
- ⚠️ Environment Variable `API_KEY` must be set before running. This is used to authorise requests to the server.
- Optionally, the variable `FILE_PATH` can be set to determine the location/name of the YML file. By default this is `./output.yml`.

To start the server, run `npm start`.

## API Endpoints
### `POST /yaml`
This endpoint will save the resulting YML file to `FILE_PATH` and also return it in the response as a string.

Request Body (JSON):
```ts
{
  // Required
  username: string
  password: string
  url: string

  // Optional
  loginUrl: string
  pollUrl: string
  loggedInRegex: string
  loggedOutRegex: string
}
```
It is recommended to provide all the optional variables including both regexes as sometimes ZAP will be unable to verify that its authenticated, and make a lot of unnecessary login requests.