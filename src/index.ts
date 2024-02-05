import express from 'express'
import dotenv from 'dotenv'
import { writeFile } from 'fs/promises'
import generateYaml from './generateYaml'
dotenv.config()
if (!process.env.API_KEY) throw new Error('\x1b[31mEnvironment variable "API_KEY" not set. This is required for authorising incoming requests.\x1b[0m')
if (!process.env.WS_FILE_PATH) throw new Error('\x1b[31mEnvironment variable "WS_FILE_PATH" not set. This is required for saving the YML file to a custom path.\x1b[0m')

const app = express()
app.use(express.json())

app.get('/', (req, res) => {
  return res.send('Healthy')
})

app.post('/yaml', async (req, res, next) => {
  // Check Authorization 
  if (req.headers.authorization !== process.env.API_KEY) {
    return res.sendStatus(401)
  }

  // Validate body
  const body = <YamlRequest>req.body
  if (!body.urls || !Array.isArray(body.urls)) {
    res.statusCode = 400
    return res.json({ message: `"urls" paramter wasn't supplied or wasn't supplied as an array.` })
  }

  const yml = await generateYaml(body).catch((e) => { console.log(e); next(e) } )
  if (!yml) return

  // Save to path set in environment variables
  await writeFile(process.env.WS_FILE_PATH || './output.yml', yml)
  .then(() => res.send(yml))
  .catch(e => { console.log(e); next(e) })
})

app.listen(process.env.WS_PORT ?? 80, () => {
  console.log(`Server running on ${process.env.WS_PORT ?? 80}`)
})

export interface YamlRequest {
  urls: string[]
  username?: string
  password?: string
  loginUrl?: string
  pollUrl?: string
  loggedInRegex?: string
  loggedOutRegex?: string
}